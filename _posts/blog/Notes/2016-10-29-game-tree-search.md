---
layout: post
title:  "Game Tree Search"
categories: Blog Notes AI
tags: ["AI", "CSC384", "search"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Game Overview
	1. Game Properties
2. Two-Player Zero-Sum Game
	1. Definition
	2. Intuition
	3. MiniMax Strategy
	4. Real-Time/Online search

<!--more-->
---
## Game Overview

- Generalization of Search Problems
	- __Game tree__: actions of >= 1 players/agents
	- Agents acting to __maximize their profits__
	- Others' profits might not have positive effect on yours
- Key Features of Game
	- Each player has different goal
	- Different paths/states assigned different costs
	- Each player tries to alter the world to best benefit itself

### Game Properties

- Two-player
- Discrete: game states or decision can be mapped on discrete values
- Finite: a finite # of states/decisions can be made
- Zero-sum (Fully Competitive): A gains = B loses
	- Strategic/normal form game: one shot e.g. rock-paper-scissors
	- Extensive form game: turn-taking, multiple moves
- Deterministic: no chance involved
- Perfect Information: all aspects of the state are fully observable

## Two-Player Zero-Sum Game

### Definition

- 2 players: `A`(Max), `B`(Min)
- States `S`
- Initial state `I`
- Terminal positions `T`
- Successor functions
	- Input: a state
	- Return: a set of possible next states
- Utility/Payoff function `V: T -> R`
	- Mapping showing how good each terminal state is for A/how bad for B

### Intuition

- Game ends when terminal `t ∊ T` reached
- Game state: state-player pair
- `A` gets `V(t)`, `B` gets `-V(t)`

### MiniMax Strategy

1. Build full game tree
	- Root: start state
	- Edges: possible moves
	- Leaves: terminals (utilities U(t) labeled)
2. Back balues up the tree
	- `U(n) = min{ U(c): c is a child of n if n is Min node }
	- `U(n) = max{ U(c): c is a child of n if n is Max node }

- `O(b^d)` space

#### Depth-First Implementation

- To avoid expanding the tree exponentially in size
- Need __finite depth__

```
DFMiniMax(n, Player): //return Utility of state n given that Player is MIN or MAX

	If n is TERMINAL:
		Return V(n) //Return terminal states utility (V is specified as part of game)

	//Apply Player s moves to get successor states. 
	ChildList = n.Successors(Player)

	If Player == MIN:
		return minimum of DFMiniMax(c, MAX) over c ∈ ChildList
	Else: //Player is MAX
		return maximum of DFMiniMax(c, MIN) over c ∈ ChildList
```

#### Pruning

- α-cuts(max node) & β-cuts(min node)

```
AlphaBeta(n,Player,alpha,beta): //return Utility of state 
	
	If n is TERMINAL:
		return V(n) //Return terminal states utility 

	ChildList = n.Successors(Player)

	If Player == MAX:
		for c in ChildList:
			alpha = max(alpha, AlphaBeta(c,MIN,alpha,beta)) 
			If beta <= alpha:
				break 
	return alpha

	Else: //Player == MIN 
		for c in ChildList:
			beta = min(beta, AlphaBeta(c,MAX,alpha,beta)) 
			If beta <= alpha:
				break 
	return beta

// Initial call: AlphaBeta(START_NODE, PLAYER, -infinity, infinity)
```

- `O(b^d)` space if no pruning, `O(b^(d/2))` if optimal pruning
	- Branching factor of 1st layer: B; 2nd: 1; 3rd: B; ...
- In practice, must make __heuristic estimates__ of the terminal nodes -> __evaluation function__

### Real-Time/Online search

1. Run A* until out of memory
2. Use __evaluation function__ to decide which path looks best
3. Make the move
4. Restart search at the node reached (can be cached)












