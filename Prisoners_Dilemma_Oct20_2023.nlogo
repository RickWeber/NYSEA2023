extensions [rnd]
turtles-own [strategy partner-history history memory-length wealth]

to setup
  clear-all
  ;random-seed 12345 ; Hey! That's the combination for my luggage!
  crt population [
    setxy random-xcor random-ycor
    set memory-length 1
    set strategy random-strategy memory-length
    set history n-values (2 ^ (1 + length strategy)) [1]; assume initial cooperation. Can change this later
    set partner-history []
  ]
  reset-ticks
end

to go
  ask turtles [
    repeat interactions-per-round [
      play-n-rounds 50 one-of other turtles ; They should play a few rounds with a few different turtles
    ]
    resolve-costs
    risk-mutation
  ]
  genetic-algorithm
  tick
end

to play-n-rounds [ n partner ]
  let my-total-payoff 0
  let partner-total-payoff 0
  repeat n [
    ;; note: the first round will be affected by the previous partner.
    let my-move make-move strategy history
    set my-move ifelse-value (random-float 1 < error-prob) [my-move] [abs (my-move - 1)] ; some chance of mis-moves
    let partner-move 0
    ask partner [
      set partner-move make-move ([strategy] of partner) ([history] of partner)
      set partner-move ifelse-value (random-float 1 < error-prob) [partner-move] [abs (partner-move - 1)]
    ]
    set history fput partner-move fput my-move sublist history 0 (min list (length history) (memory-length + 1))
    ask partner [
      set history fput my-move fput partner-move sublist history 0 (min list (length history) (memory-length + 1))
    ]
    ; determine payoffs
    let payoffs compute-payoffs my-move partner-move
    let my-payoff first payoffs
    let partner-payoff last payoffs
    ; update payoffs
    set my-total-payoff my-total-payoff + (my-payoff / n)
    set partner-total-payoff partner-total-payoff + (partner-payoff / n)
  ]
  ; update metadata
  set partner-history fput partner partner-history
  set wealth wealth + my-total-payoff
  ask partner [
    set partner-history fput myself partner-history
    set wealth wealth + partner-total-payoff
  ]
end

to resolve-costs
  let complexity-cost (memory-length * cost-of-memory-linear) + ((memory-length ^ 2) * cost-of-memory-quadratic)
  set wealth (wealth - cost-of-existence - complexity-cost) ; deal with cost of memory and burden of existence
end

to genetic-algorithm
  let turnover-count turnover-rate * population
  let min-wealth min [wealth] of turtles
  ask turtles [
    set wealth wealth - min-wealth
  ]
  foreach rnd:weighted-n-of-with-repeats turnover-count turtles [wealth] [
    agent ->
    ask agent [
      hatch 1 [
        rt random 90
        fd 1
      ]
    ]
  ]
  ifelse deterministic-death? [
    ask min-n-of turnover-count turtles [wealth] [ die ] ; least successful turtles die
  ] [
    foreach (list rnd:weighted-n-of turnover-count turtles [ 1 / wealth ] ) [
      agent ->
      ask agent [
        die
      ]
    ]
  ]
  ; occasionally give an agent a new random strategy
  if (wildcard-prob > random-float 1) [
    ask one-of turtles [
      set strategy random-strategy memory-length
      setxy random-xcor random-ycor
      set color random-color
    ]
  ]
  ; reset wealth each tick
  ifelse wealth-reset? [
    ask turtles [
      set wealth 0
    ]
  ] [
    ask turtles [
      set wealth 0.5 * wealth ; shrink wealth proportionately
    ]
  ]

end

to risk-mutation
  if random-float 1 < point-prob [
    point-mutate
  ]
  if random-float 1 < split-prob and memory-length > 1 [ ; don't let them lose their memory altogether. Unless I replace it with some default behavior.
    split-mutate
  ]
  if random-float 1 < duplication-prob [
    duplicate-mutate
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;
; Probability Reporters ;
;;;;;;;;;;;;;;;;;;;;;;;;;

to-report probability [finetune-var magnitude-var]
  report finetune-var / (10 * magnitude-var)
end

to-report error-prob
  report probability error-finetune error-magnitude
end

to-report wildcard-prob
  report probability wildcard-finetune wildcard-magnitude
end

to-report point-prob
  report probability point-finetune point-magnitude
end

to-report split-prob
  report probability split-finetune split-magnitude
end

to-report duplication-prob
  report probability duplicate-finetune duplicate-magnitude
end

;;;;;;;;;;;;;
; Mutations ;
;;;;;;;;;;;;;

to point-mutate
  let i random length strategy
  let Xi item i strategy
  set strategy replace-item i strategy (abs (Xi - 1))
end

to split-mutate
  set strategy ifelse-value random-float 1 < 0.5 [first-half strategy][second-half strategy]
  set memory-length memory-length - 1
  set history sublist history 0 memory-length
end

to duplicate-mutate
  set strategy sentence strategy strategy
  set memory-length memory-length + 1
end

;;;;;;;;;;;;;
; Reporters ;
;;;;;;;;;;;;;

to-report trimmed-history [ mem-length hist ]
  report sublist hist 0 mem-length
end

to-report binary-to-decimal [ lst ]
  if length lst < 1 [report 0]
  report reduce + (map [[l b] -> l * b] lst (map [b -> 2 ^ b] reverse range length lst))
end

to-report random-strategy [ mem-length ]
  report n-values (2 ^ mem-length) [(ifelse-value (random-float 1 < 0.5) [1][0])]
end

to-report make-move [ strat hist ]
  report item (binary-to-decimal sublist hist 0 memory-length) strat
end

to-report first-half [ lst ]
  report sublist lst 0 (length lst / 2)
end

to-report second-half [ lst ]
  report sublist lst (length lst / 2) (length lst)
end

to-report unique-strategies
  let all-strategies [strategy] of turtles
  report remove-duplicates all-strategies
end

to-report one-strategy-count [ this-strategy ]
  report count turtles with [strategy = this-strategy]
end

to-report strategy-count
  ; count each unique strategy
  let strategy-counts map [this-strategy -> one-strategy-count this-strategy] unique-strategies
  ; sort in descending order of frequency
  let sorted-counts sort-by > strategy-counts
  ; sort by strategy length
  let length-sorted-strategies sort-by [[x y] -> length x < length y] unique-strategies
  ; sort by the decimal value of a strategy
  let numerical-sorted-strategies sort-by [[x y] -> binary-to-decimal x < binary-to-decimal y] length-sorted-strategies
  ; resort strategies by popularity
  let sorted-strategies sort-by [[x y] -> one-strategy-count x > one-strategy-count y] numerical-sorted-strategies
  report (list sorted-strategies sorted-counts)
end

to-report random-color
  report 5 + 10 * round random-float 14
end

to-report compute-payoffs [ row-move col-move ]
  report ifelse-value (row-move = col-move) [
    ifelse-value (row-move = 1) [list win-win-payout win-win-payout][list lose-lose-payout lose-lose-payout]
  ][
    ifelse-value (row-move = 1) [list lose-win-payout win-lose-payout][list win-lose-payout lose-win-payout]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
443
27
880
465
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
26
295
198
328
population
population
2
1000
137.0
5
1
NIL
HORIZONTAL

SLIDER
1290
91
1462
124
win-win-payout
win-win-payout
0
100
79.0
1
1
NIL
HORIZONTAL

SLIDER
1468
128
1643
161
lose-lose-payout
lose-lose-payout
0
100
35.0
1
1
NIL
HORIZONTAL

SLIDER
1288
255
1500
288
cost-of-memory-linear
cost-of-memory-linear
-20
20
-1.0
1
1
NIL
HORIZONTAL

SLIDER
1287
294
1528
327
cost-of-memory-quadratic
cost-of-memory-quadratic
-5
5
2.0
1
1
NIL
HORIZONTAL

SLIDER
1286
332
1466
365
cost-of-existence
cost-of-existence
-20
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
1281
435
1453
468
turnover-rate
turnover-rate
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1468
92
1640
125
win-lose-payout
win-lose-payout
0
100
88.0
1
1
NIL
HORIZONTAL

SLIDER
1290
128
1462
161
lose-win-payout
lose-win-payout
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
924
89
1096
122
error-finetune
error-finetune
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
923
129
1097
162
error-magnitude
error-magnitude
1
100
4.0
1
1
NIL
HORIZONTAL

MONITOR
1136
97
1217
142
NIL
error-prob
4
1
11

SLIDER
922
173
1102
206
wildcard-finetune
wildcard-finetune
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
923
215
1120
248
wildcard-magnitude
wildcard-magnitude
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
922
259
1094
292
point-finetune
point-finetune
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
922
297
1097
330
point-magnitude
point-magnitude
1
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
920
344
1092
377
split-finetune
split-finetune
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
920
383
1092
416
split-magnitude
split-magnitude
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
920
430
1108
463
duplicate-finetune
duplicate-finetune
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
920
468
1125
501
duplicate-magnitude
duplicate-magnitude
1
100
100.0
1
1
NIL
HORIZONTAL

MONITOR
1135
181
1237
226
NIL
wildcard-prob
17
1
11

MONITOR
1137
271
1217
316
NIL
point-prob
17
1
11

MONITOR
1138
357
1213
402
NIL
split-prob
17
1
11

MONITOR
1141
440
1259
485
NIL
duplication-prob
17
1
11

BUTTON
23
13
96
46
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
22
56
85
89
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
20
100
167
133
NIL
repeat 5 [ go ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
16
150
195
183
NIL
show strategy-count
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1296
34
1509
64
Prisoners' Dilemma parameters
12
0.0
1

TEXTBOX
1292
197
1442
227
Agents' cost parameters
12
0.0
1

TEXTBOX
937
35
1087
65
Randomness parameters
12
0.0
1

SLIDER
26
359
245
392
interactions-per-round
interactions-per-round
1
100
27.0
1
1
NIL
HORIZONTAL

BUTTON
194
102
318
135
go and show
repeat 50 [\n  go\n  show strategy-count\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
237
155
361
188
go and show
go\nshow strategy-count
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
41
203
208
236
NIL
inspect one-of turtles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
31
405
181
490
More interactions mean agents get a more representative sample of the population, but also slows the simulation.
12
0.0
1

TEXTBOX
1293
385
1443
419
Genetic algorithm parameters
12
0.0
1

SWITCH
1281
478
1469
511
deterministic-death?
deterministic-death?
0
1
-1000

SWITCH
1282
524
1425
557
wealth-reset?
wealth-reset?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

This is a model of strategic evolution in a context where agents play a non-zero-sum game (a Prisoner's Dilemma). 

In effect, it models the evolution of trust (or the lack thereof).

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)
A population of agents play iterated prisoners' dilemmas with one another, setting their action each round based on their strategy and the history of past interactions. Over time the population adapts via a genetic algorithm which selects agents to reproduce/die based on their success so far. 

Agents with a more complicated strategy might be more robust to other strategies, but also face increased costs. This tradeoff can be adjusted with the cost-of-memory parameters.

## HOW GENOMES WORK

Genomes take the form of a binary string that maps an agent's history to an action. That is, genomes embody the strategy an agent follows. 

The history is another binary string where every other bit represents whether the partner cooperated and the rest represent whether the agent in question cooperated. For example, if an agent's history is `[1 1 0 1]` it means they and their partner in the previous round cooperated, but in the round before that this agent cooperated, but their partner didn't.

This history, interpretted as a binary number (13, in this example), is used to select which element of the genome to select as a move in the current round. In this case, an agent with `memory-length` of 4 would have a `strategy` with 16 bits and would cooperate (defect) if the 13th bit is 1 (0).

## INTERPRETTING GENOMES

Interpretting larger genomes can be cumbersome, but basically, the more 1s, the more likely this agent is to cooperate. Since a history of cooperation creates a higher binary number, more 1s at the end of the strategy imply that cooperation is more likely to be conditional on cooperation from their partner. 

For example `[0 1]` is the 'tit-for-tat' strategy for an agent with a `memory-length` of 1. They only see if their partner cooperated or not in the previous round, so the history can only take values of 0 or 1. If they cooperated, history = 1 and we select element 1 from the strategy, otherwise we select element 0. 

A strategy of `[0 1 0 1]` will look at the last two elements of an agent's history, the partner's last action and this agent's last action. The possible histories in this case would be 00, 01, 10, or 11 (with the first bit representing the partner's action). 

- 00 means neither cooperated last round, and this agent won't cooperate this round (because element 0 of their strategy has a value of 0).
- 01 means the agent cooperated, but their partner defected. Given their strategy, they cooperate this round.
- 10 (2 in decimal form) means the agent defected on a cooparative partner and will defect this round.
- 11 (3) means both cooperated and this agent will cooperate in this round.

In otherwords, this agent only cooperates if they cooperated before. 

## INTERPRETTING HISTORY

In this iteration, agents can't identify or distinguish partners. A history with an uncooperative partner can affect an agent's cooperation with their next partner. In effect, the genetic algorithm is tuning agents' strategies for having a high average effectiveness when playing with a random agent from the population. The model could be extended to allow selective interactions and the creation of sub-groups, exclusion, etc.

## MUTATIONS AND RANDOMNESS

This model has randomness built in to several places, including a chance of making errors, and a chance of mutations. 

The error probability creates the possibility that an agent's action is flipped (e.g. a decision to cooperate based on their strategy turns into an "accidental" defection).

Mutations take four forms:

- point mutations flip one bit in an agent's strategy (e.g. "1001" --> "1101")
- split mutations cut an agent's strategy in half and reduces their memory length by one (e.g. "1101" --> "11").
- duplication mutations increase an agent's memory by one and duplicates their existing strategy (e.g. "11" --> "1111")
- wildcard mutations take an agent and replaces their current strategy with a randomly generated strategy of the same length.

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)
Randomness comes into play during interactions (e.g. an agent might try to cooperate but accidentally defect), and the evolutionary process.

## THINGS TO TRY

Try playing around with sliders affecting the cost of memory (but be aware that larger memories will slow down the model due to increased computational cost) to see what sort of sophisticated strategies you might discover.


## EXTENDING THE MODEL

Try making the probability of mutation a `turtles-own` variable to see how evolvability evolves in this environment.

A particularly important extension would be giving agents some agency over who they interact with. You might add some signals (e.g. by having agents approach agents with probability weighted by such signals), or have agents do some sort of "research" into potential partners (e.g. by allowing agents to report some score on each interaction, then allowing them to poll other agents' histories. 

The `deterministic-death?` and `wealth-reset?` switches don't currently work as intended (and should be set to On and On, for now). See if you can figure out how to make them work so that the worst performers have some probability of survival and the best performers in one round can take some of their wealth into the next round.


## CREDITS AND REFERENCES

This model is a reimplimentation and extension of one created by Kristian Lindgren. Any mistakes are my own.

Lindgren, K. "Evolution phenomena in simple dynamics." Artificial Life II: 295-312.

```
@article{lindgrenevolution,
  title={Evolution phenomena in simple dynamics},
  author={Lindgren, K},
  journal={Artificial Life II},
  pages={295--312}
}
```
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="try-lots" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>strategy-count</metric>
    <enumeratedValueSet variable="point-magnitude">
      <value value="1"/>
      <value value="10"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="split-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wildcard-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duplicate-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="error-magnitude">
      <value value="1"/>
      <value value="10"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="win-lose-payout">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="point-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lose-win-payout">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="error-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-of-memory-linear">
      <value value="-1"/>
      <value value="0"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-of-existence">
      <value value="-5"/>
      <value value="0"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="split-magnitude">
      <value value="1"/>
      <value value="10"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-of-memory-quadratic">
      <value value="-1"/>
      <value value="0"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wildcard-magnitude">
      <value value="1"/>
      <value value="10"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lose-lose-payout">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duplicate-magnitude">
      <value value="1"/>
      <value value="10"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turnover-rate">
      <value value="0.05"/>
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="win-win-payout">
      <value value="80"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="long-runs" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50000"/>
    <metric>strategy-count</metric>
    <enumeratedValueSet variable="point-magnitude">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="split-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wildcard-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duplicate-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="error-magnitude">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="win-lose-payout">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="point-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lose-win-payout">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="error-finetune">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-of-memory-linear">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-of-existence">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="split-magnitude">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-of-memory-quadratic">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wildcard-magnitude">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lose-lose-payout">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duplicate-magnitude">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turnover-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="win-win-payout">
      <value value="80"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
