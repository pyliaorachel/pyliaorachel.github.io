---
layout: post
title:  "NP-Complete Problems"
categories: Blog Notes Algorithm
tags: ["np-complete", "algorithm", "CSC373"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Search Problems
	1. Satisfiability Problem (SAT)
	2. Traveling Salesman Problem (TSP)
	3. Integer Linear Programming (ILP)
		- Zero-One Equations (ZOE)
	4. Three-Dimensional Matching (3D Matching)
	5. Independent Set
	6. Clique
	7. Knapsack Problem
2. NP-Complete Problems
3. Reductions
	1. Generalization/Special Case
	2. Rudrata Path -> Rudrata Cycle
	3. 3SAT -> Independent Set
	4. SAT -> 3SAT
	5. Independent Set -> Vertex Cover
	6. Independent Set -> Clique
	7. 3SAT -> 3D Matching
	8. 3D Matching -> ZOE
	9. ZOE -> Subset Sum
	10. ZOE -> Rudrata Cycle
	11. Rudrata Cycle -> TSP
	12. Any Problem in NP -> SAT
	
<!--more-->
---
## Search Problems

- Components
	- __Instance I__: input data specifying the problem
	- __Solution S__: object meeting particular specification
	- __Algorithm C__ s.t. `C(I,S) = true` <=> `S` is a solution to `I`; _quick checking_ <=> `C` runs in polynomial-time in `|I|`
- Can be reduced to/from __optimization problems__


#### Satisfiability Problem (SAT)

Boolean formula in conjunctive normal form (CNF), find a set of assignments s.t. every clause contains a literal that is `true`.

#### Traveling Salesman Problem (TSP)

Given `n` vertices and all connected with a cost `c`, find a permutation of vertices s.t. the total cost is at most the budget `b`.

- Search problem is polynomial-time checkable:
	- Each vertex is visited exactly once
	- Total cost <= `b`
- CANNOT check optimality
	- __Binary search__ to find optimum cost

#### Integer Linear Programming (ILP)

Given a set of linear inequalities `Ax ≤ b`, where `A` is an `m × n` matrix and `b` is an `m-vector`; an objective function specified by an `n-vector` `c`; and finally, a goal `g`. Find a nonnegative integer `n-vector` `x` such that `Ax ≤ b` and `cx ≥ g`.

##### Zero-One Equations (ZOE)

Find a vector `x` of 0's and 1's satisfying `Ax = 1`, where `A` is an `m × n` matrix with 0−1 entries and `1` is the `m-vector` of all 1's.

#### Three-Dimensional Matching (3D Matching)

Find a matching (`n` disjoint edges) between 3 sets of `n` nodes.

#### Independent Set

Given a graph and an integer `g`, find `g` vertices that are independent, i.e. no edges between them.

- Dual: __vertex cover__
	- Special case of __set cover__

#### Clique

Given a graph and a goal `g`, find a set of `g` vertices such that the induced subgraph is complete.

#### Knapsack Problem

Given integer weights `w1,...,wn` and integer values `v1, ..., vn` for `n` items. Find a set of items with total weight <= `W` and total value >= `g`

- __Unary knapsack__: encode integers in unary
- __Subset sum__: item's value equals its weight
	- Find a subset of items that adds up to exactly `W`

## NP-Complete Problems

|Hard problems (NP-complete)|Easy problems (in P)|
|:-------------------------:|:-------------------|
|3SAT|2SAT, HORN SAT|
|TRAVELING SALESMAN PROBLEM|MINIMUM SPANNING TREE|
|LONGEST PATH|SHORTEST PATH|
|3D MATCHING|BIPARTITE MATCHING|
|KNAPSACK|UNARY KNAPSACK|
|INDEPENDENT SET|INDEPENDENT SET on trees|
|INTEGER LINEAR PROGRAMMING|LINEAR PROGRAMMING|
|RUDRATA PATH|EULER PATH|
|BALANCED CUT|MINIMUM CUT|

NP-complete problems can be reduced to/from any of the others.

#### P, NP, NP-Complete

- __NP__: class of search problems s.t. any proposed solution can be quickly checked for correctness
- __P__: class of search problems that can be solved in polynomial time, and correctly reports no solution if so
- __NP-complete__: search problem where all other search problems reduce to it

```
|--------NP-------|
|P|...|NP-complete|
	  |-------NP Hard-------|
```

## Reductions

```
# f, h are polynomial transformation algorithms

	|----------------Algorithm for A-----------------|
I ---> f --f(I)--> Algorithm for B --S of f(I)--> h --> h(S) of I
								   -------------------> No solution to I
```
```
Reduction from A to B:
	A --> B
If we know A is hard, then B is hard as well. All problems in NP reduce to B via A.

If A --> B and B --> C, then A --> C
```
```
								All NP
								   |
								  SAT
								   |
								  3SAT
								  ⬋  ⬊
					Independent Set  3D Matching
						⬋  ⬊			|
			Vertex Cover	Clique	   ZOE
									 ⬋  |  ⬊
							Subset Sum ILP Rudrata Cycle
												|
											   TSP
```

#### Generalization/Special Case

- __Circuit SAT__ is a generalization of __SAT__
- __SAT__ is a generalization of __3SAT__
- __Set cover__ is a generalization of __vertex cover__ and __3D matching__
- __ILP__ is a generatlization of __ZOE__

#### Rudrata Path -> Rudrata Cycle

Given a graph, is there a path starting at s and ending at t that goes through each vertex exactly once?  
-> Is there a cycle that passes through each vertex exactly once?

- Reduce `G` in rudrata path to `G'` in rudrata cycle:
	- Add vertex `x` and edges `(s,x)`, `(x,t)`

#### 3SAT -> Independent Set

-  Graph `G` has a triangle for each clause (or an edge if clause of two literals), with vertices labeled by the clause's literals
- Add edges between any two vertices that represent opposite literals
- Goal `g` is the number of clauses

#### SAT -> 3SAT

-  Any clause with > 3 literals in instance `I` of SAT, transform:  
	`(a1 ∨ a2 ∨ ... ∨ ak)  -> (a1 ∨ a2 ∨ y1)(~y1 ∨ a3 ∨ y2)...(~yk−3 ∨ ak−1 ∨ ak)`
- Further restriction: no variable appears in `k` > 3 clauses
	- Replace variable `x` with `x1, x2, ..., xk`
	- Add clauses `(~x1 ∨ x2)(~x2 ∨ x3)...(~xk ∨ x1)`

#### Independent Set -> Vertex Cover

- Independent set `S`, vertex cover `V - S`

#### Independent Set -> Clique

- Map instance `(G, g)` of independent set to complement graph `(~G, g)` of clique

#### 3SAT -> 3D Matching

[CMU Notes](https://www.cs.cmu.edu/~ckingsf/bioinfo-lectures/3dm.pdf)

#### 3D Matching -> ZOE

Given an `m × n` matrix `A` with 0−1 entries, and we must find a 0−1
vector `x = (x1, ..., xn)` such that the `m` equations `Ax = 1` are satisfied.

- Let columns of `A` be triples in 3D matching
- Let rows of `A` be all matching items
- `Aij` is 1 if the triple includes the item
- Choose a set of triples `X` to be 1 s.t. the resulting column is all 1 (i.e. all items chosen once)

#### ZOE -> Subset Sum

- Let columns of `A` be representations of (n+1)-ary integers
- Choose a set of integers s.t. sum is 11...1 (won't be affected by _carry_ because base `n+1`)

#### ZOE -> ILP

- For `Ax = b`, rewrite each equation as 2 inequalities
- Add for each variable `xi` inequalities `xi ≤ 1` and `−xi ≤ 0`

#### ZOE -> Rudrata Cycle

1. ZOE -> Rudrata cycle with paired edges
	- Each variable `xi` => two parallel edges (xi = 1 and 0)
	- Each equation `xj1 + ... + xjk = 1`involving `k` variables => `k` parallel edges
	- Every equation and every variable xi appearing in it, add to `C` the pair `(e,e')`, `e` = the edge `xi` in that equation, `e'` = the edge xi = 0

2. Rudrata cycle with paired edges -> Rudrata cycle
	- Replace every pair `(e,e')` as `({a,b},{c,d})`with:
		![gadget](http://i40.tinypic.com/1pfazb.png)
	- Every other pair involving `{a,b}`, set it to be `{a,f}` and repeat the replacement

#### Rudrata Cycle -> TSP

- `V` = set of cities
- Distance between `u` and `n` is `1` if `{u,v}` is an edge; otherwise `1 + α` for some `α > 1`
- Budget = `|V|`

1. `α = 1`
	- TSP satisfies triangle inequality `dij + djk ≥ dik`
	- Can be approximated
2. `α` is large
	- Solution either has cost `n` or less, or has cost at least `n + α` (__gap property__)

#### Any Problem in NP -> SAT

- Circuit SAT

	Given a circuit, find a truth assignment for the unknown inputs s.t. the output gate evaluates to T, or report that no such assignment exists.  

	```
	- AND/OR gates: indegree 2
	- NOT gates: indegree 1
	- Known input gates: no incoming edges, labeled F/T
	- Unknown input gates: no incoming edges, labeled '?'
	```

1. SAT -> Circuit SAT
	- Clause: OR of literals
	- Joining clauses: AND of clauses

2. Circuit SAT -> SAT

	```
	T: g
	F: ~g
	OR: (g v ~h1)(g v ~h2)(~g v h1 v h2)
	AND: (~g v h1)(~g v h2)(g v ~h1 v ~h2)
	NOT: (g v h)(~g v ~h)
	```

3. Any Problem in NP -> Circuit SAT
	- Problem in NP is a search problem `A`
	- Solution checking is polynomial-time
	- Polynomial algorithm can be rendered as a circuit
	- Given instance `I` and solution `S` of problem `A`, construct a polynomial-time circuit with known inputs the bits of `I`, unknown inputs the bits of `S` s.t. output is T

#### Resources
* [Harvard Notes](http://www.fas.harvard.edu/~libcs124/CS/lec7.pdf)
* [What are the differences between NP, NP-complete, and NP-hard?](http://stackoverflow.com/questions/1857244/what-are-the-differences-between-np-np-complete-and-np-hard)
* [mlnotes](http://mlnotes.com/2013/04/29/npc.html)
* [USTC Notes](http://staff.ustc.edu.cn/~csli/graduate/algorithms/book6/chap36.htm)


















