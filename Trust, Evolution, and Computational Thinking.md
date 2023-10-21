---
title: Trust, Evolution, and Computational Thinking
submitted abstract: |-
  This study presents an agent based model of an iterated prisoners’ dilemma with evolution. The model demonstrates that even a very simple game can result in complex and unstable dynamics when dealing with learning, heterogeneous agents.

  Given the importance of trust and reciprocity, as well as the fast-changing nature of the world our students are graduating into, it is argued that economists should make a greater effort to teach computational methods as a means to help our students think more clearly about complex systems—even if they don’t go on to use the specific technological skills they develop in such classes.
theme: solarized
date: Oct 21, 2023
enableTimeBar: "true"
---
<style>

```css
@media print {
  hr {
    page-break-after: always;
  }
}
```

.color-text{
color: #993300;
}


	.footnote{font-size: large}

</style>

# Trust, Evolution, and Computational Thinking

---

This slide and materials are available at https://github.com/RickWeber/NYSEA2023

---
# Part I: relevance for *you and me*
---

## What do you remember from your undergrad experience?

* facts
* skills
* beliefs
* modes of thinking
---
## What are we really providing our students?
- A mix of skills, beliefs, and ways of thinking are the lasting contribution of our schooling. 
	- They can look up the facts as they need them.
- Hopefully we’re helping them learn to think more clearly about complex systems.

---

<!-- slide bg="https://upload.wikimedia.org/wikipedia/commons/0/04/Keynes_1933.jpg" -->

<style>


.color-text{
color: #993300;
}


</style>


> Economics is a method rather than a doctrine, an apparatus of the mind, a technique of thinking which helps its possessor to draw correct conclusions. <!-- element class="color-text" -->


---

<!-- slide bg="https://upload.wikimedia.org/wikipedia/commons/0/04/Keynes_1933.jpg" -->

<style>


.color-text{
color: #993300;
}


</style>


> The master-economist must possess a rare combination of gifts .... He must be mathematician, historian, statesman, philosopher... [computer scientist, statistician, etc.] <!-- element class="color-text" -->

---

<!-- slide bg="https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Vulpes_vulpes_ssp_fulvus.jpg/1280px-Vulpes_vulpes_ssp_fulvus.jpg" -->

## Ways of thinking
* The Economic way of thinking is incredibly powerful.
* There are lots of ways of thinking, and they're often complementary. (Mathematical thinking, statistical thinking, design thinking, etc.)
* Pluralism is good. And **we can replicate it our own heads.**

---

## Computational Thinking
(Many) computer scientists are basically economists asking questions about how to manage a scarcity of:
- data availability and quality
- storage size
- storage reliability
- computational capacity
- network capacity


---

## Evolutionary thinking

- Markets are evolutionary processes
	- but students often have a limited handle on the concept of evolution beyond the over-simplified "survival of the fittest".  
- Computational models often lend themselves to the use of the Genetic Algorithm.
	- Simulator’s prerogative: stop/start/inspect the model 
	- See the evolutionary process unfold in real time


---

## Covering Neoclassical Blindspots

- A common trope among scholars of Emergence[^1] is how [ants](https://www.youtube.com/watch?v=16W7c0mb-rE) are individually stupid but collectively brilliant. 
- Neoclassical economics runs into the opposite problem: individually brilliant individuals who get trapped in Prisoners’ Dilemmas

[^1]: Not all of them know it, but they're implicitly thinking computationally already

---

### Econ students need computer science
#### Even if we have to ditch the computer

- [Computational thinking is more about thinking than computing](https://link.springer.com/article/10.1007/s41979-020-00030-2)
- Students should learn computer skills, but the bigger value is how it lets you see the underlying logic of a situation
- All of the coding skills I’ve learned and forgot are still useful because they’ve expanded my thinking tool kit.

---

## How can we get some of that in Principles?

- [One place to start](https://github.com/RickWeber/SnD) is playing around with computational versions of a model we already know and love.
- Bonus: the descriptive stories we tell about (e.g.) shortages are really computational stories.
	- People get signals about the state of the world, adjust their behavior, and change the state of the world through their actions.
	- (I'm guessing Clair Smith will tell us this story in session D1.)

---
## Okay, so what are we doing?
- 2.5-minute crash course in computational thinking.
- See a small sample of economic issues that Computer Science sheds light on.
- Then we'll look at a computational model of trust.


---
# Part II: Crash course in computation


---
### What is computation?

From *The Art of Computer Programming*'s index:

![[IMG_5194 1.jpeg]]

---
## Computation is just data-in-data-out

There are abstract models of computation like *Turing Machines* and *Lambda Calculus*. 

For our purposes:
+ take some input,
+ process it according to some rules, and
+ ultimately[^1] generate output (e.g. some change within the computer or the world it occupies).

[^1]: Many possible computations might take longer than the lifespan of the universe to finish computing. <!-- element class="footnote" -->

---
<!-- slide bg="https://blog.datawrapper.de/wp-content/uploads/2021/06/game-of-life-loop-cropped.gif" -->
## Computational Equivalence

Even incredibly simple systems like Cellular Automata can be used for sophisticated calculations like [computing prime numbers](https://www.wolframscience.com/nks/p640--computations-in-cellular-automata/).

Any system that is "Turing complete"[^2] is [Turing equivalent](https://www.wolframscience.com/nks/chap-11--the-notion-of-computation/) to any other Turing complete system: given enough time, any Turing complete system is capable of simulating any other. 

[^2]: which turns out to be a [surprisingly low bar](https://www.youtube.com/watch?v=uNjxe8ShM-8&pp=ygUacG93ZXJwb2ludCB0dXJpbmcgY29tcGxldGU%3D). <!-- element class="footnote" -->

---
### Computational irreduceability

One of the early findings of Computer Science is that we can't count on finding a shortcut for any but the simplest programs. **We just have to run through "the program"** to see what happens.

---
### Caveat
When we create a computational model, we're inventing a little world and hoping it corresponds to the real world, just like when we're using equation-based models. As always, buyer beware!

---
## But Humans aren't just computers!
+ [We probably are](https://www.scotthyoung.com/blog/2023/07/25/the-mind-is-a-computer/).
+ Even so, we can get started and hold constant the ineffable while we continue learning how the human mind works. 
+ "any system whatsover--can be viewed as performing a computation that determines what its future behavior will be." ([Wolfram](https://www.wolframscience.com/nks/p641--computations-in-cellular-automata/))

---

## Computational Biology

> **Earth** was a giant supercomputer designed to find the Ultimate Question of Life, the Universe and Everything. Designed by Deep Thought and built by the Magratheans, it was commonly mistaken for a planet, especially by the ape descendants who lived on it. It was situated far out in the uncharted backwaters of the unfashionable end of the Western Spiral Arm of the Galaxy).

[The Hitchhiker's Guide to the Galaxy](https://hitchhikers.fandom.com/wiki/Earth)

---
### Question: could a powerful enough  computer realize LaPlace's vision?
![Portrait of LaPlace linked from Wikipedia](https://upload.wikimedia.org/wikipedia/commons/3/39/Laplace%2C_Pierre-Simon%2C_marquis_de.jpg)

--

### Question: could a powerful enough  computer realize LaPlace's vision?

+ Yes, but the computer would have to be bigger than the universe it's modeling. 
+ It's like Borges' cartographers but worse! (but it might be a smaller problem than those of [Borges' library](https://libraryofbabel.info/bookmark.cgi?library_of_babel_wikipedia_entry))

+ **Moral of the story:** no matter how much we learn, there's always room for mystery. 

---

# Part III: parallels in econ

---

## Examples

- The Socialist Calculation Debate
	- Markets are "computationally irreducible"
	- You have no way to compute equilibrium faster or more effectively than the market itself (a distributed parallel computer that calculates the relative scarcity of exchangeable goods).
	- Econ's parallel to Turing's Halting Problem and Godel's Undecidability Proof.

---

## Examples

- Markets as a discovery procedure (entrepreneurship as “search” in a many-dimensional space)
- Bounded rationality (e.g. modeling heuristics-based behavior rather than optimization)
	- (Seeing a simple case of machine learning with a simple agent is a valuable inoculant for AI snake oil sales pitches) 

---
## Examples
- Strategic interactions (e.g. Industrial Organization)
- [Finance](https://www.santafe.edu/research/results/working-papers/technical-trading-creates-a-prisoners-dilemma-resu) with heterogeneous agents (answering question: why do people keep doing technical investing instead of fundamental analysis?)
- Evolution of cooperation (i.e. computational political economy)

---

# Part IV: Evolution of Cooperation

---

## Prisoners' Dilemma
- The Prisoners' Dilemma (PD) is as concise a formulation of civilization as I could hope for: 
	- variable-sum game that requires two people to choose between cooperation and conflict. 

---

## One-shot solution

### DEFECT, DEFECT

+ But life isn't one-shot, it's iterated!

---

## Iterated solution

- It depends... but [it's probably tit-for-tat](https://en.wikipedia.org/wiki/The_Evolution_of_Cooperation).

---
## Let’s see it in action

- We'll see a NetLogo implementation that you're free to mess with at home.
- Nicky Case has a great (simpler) version in the form of an [interactive webpage](https://www.santafe.edu/research/results/working-papers/technical-trading-creates-a-prisoners-dilemma-resu) at ncase.me/trust

---

### Evolutionary Dynamics in a Prisoners' Dilemma

![[Pasted image 20231020140255.png]]
Lindgren, 1992 ([p. 303](https://www.researchgate.net/profile/Kristian-Lindgren-2/publication/258883366_Evolutionary_Phenomena_in_Simple_Dynamics/links/0046352950fda06713000000/Evolutionary-Phenomena-in-Simple-Dynamics.pdf))

---
# Part IV: Where now?

---

## What have we seen?

- Computation is a relatively abstract property--we don't need sophisticated computers to do sophisticated computation.
- Social systems (e.g. markets) are computational systems in their own right.

---
## What have we seen?

- Computational modeling can help build understanding about processes that affect economic life.
- This understanding is critical for students to understand the world they’re graduating into.

---
## Explore/Exploit
When knowledge is scarce, start by exploring. Once you've got the lay of the land, exploit that knowledge to whatever your ends are.

---

## Recommended reading

- [Evolution of Trust interactive web app](ncase.me/trust)
- [*The Selfish Gene*](https://en.wikipedia.org/wiki/The_Selfish_Gene)
- [*Algorithms to Live By*](https://algorithmstoliveby.com/)
- [*Complex Adaptive Systems*](https://press.princeton.edu/books/paperback/9780691127026/complex-adaptive-systems) 
+ [*The Hitchhiker's Guide to the Galaxy* ](https://en.wikipedia.org/wiki/The_Hitchhiker%27s_Guide_to_the_Galaxy)
	- It's a beach read, but try reading it after some of the others. 


---

#### Diving Deeper
- [A New Kind of Science](https://www.wolframscience.com/nks/p231--four-classes-of-behavior/) by Stephen Wolfram
- [Leigh Tesfatsion's webpage](https://www2.econ.iastate.edu/tesfatsi/ace.htm)
- [Complexity Explorer](https://www.complexityexplorer.org/courses/101-introduction-to-agent-based-modeling) from [the Santa Fe Institute](https://santafe.edu/research/projects)

---

#### This presentation including links and model

* https://github.com/RickWeber/NYSEA2023

---

# Thank you

### Questions/comments: 

weberr@farmingdale.edu

https://github.com/RickWeber/NYSEA2023