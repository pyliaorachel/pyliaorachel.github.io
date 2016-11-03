---
layout: post
title:  "Dynamic Programming"
categories: Blog Notes Algorithm
tags: ["DP", "algorithm", "CSC373"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Shortest Paths in DAGs
2. Longest Increasing Subsequences
3. Edit Distance
4. Knapsack Problem
5. Chain Matrix Multiplication
6. Shortest Paths
	1. Shortest Reliable Paths
	2. All-Pairs Shortest Paths
	3. The Traveling Salesman Problem
	4. Independent Sets in Trees

<!--more-->
---
- Comparison to _divide-and-conquer_
	- __Divide-and-conquer__: subproblems _substantially smaller_
	- __DP__: subproblems _slightly smaller_
	- So __recursion__ works well with _DAC_ but not _DP_
- Define a collection of subproblems which follows:
	- There is an __ordering__ on the subproblems, and a __relation__ that shows how to solve a subproblem given the answers to "smaller" subproblems, that is, subproblems that appear earlier in the ordering.
- Relation with DAGs
	- Node: subproblem
	- Incoming edges: subproblems needed to be pre-solved (precedence constraints)
- Common subproblems

	```
	1.  
		O(n)
		[x1, x2, ..., xi], ..., xn
	2. 
		O(mn)
		[x1, x2, ..., xi], ..., xn
		[y1, y2, ..., yj], ..., ym
	3. 
		O(n^2)
		x1, ..., [xi, ..., xj], ..., xn
	4. 
					x1
				   /  \
				  x2  x3
				 . 	     .
				. 		  .
			   xi 	...   xn

		Subproblem - rooted subtree
	```

### __Shortest Paths in DAGs__

- __DAG__: directed acyclic graph
- Nodes can be __linearized__

	```
	    A -> B					__________
	  ➚        ➘			   ➚           ➘
	S   ↑    ↓   D		S -> C -> A -> B -> D -> E
	  ➘        ➚		 ➘_______➚      ➘_______➚
	    C -> D
	```
- Pseudocode

	```
	initialize all dist(·) values to ∞ 
	dist(s) = 0

	for each v ∈ V\{s}, in linearized order:
		dist(v) = min_(u,v)∈E { dist(u) + l(u,v) }
	```

### __Longest Increasing Subsequences__

Given a sequence of numbers, find a subset taken in order in which the numbers are getting strictly larger.

#### Viewing LIS as DAG

- Node `i`: element `i` in the sequence
- Directed edge `(i,j)`: if element `j` > element `i`
- Subproblem:  
	`L(j) = length of LIS ending at j`
- Solution to subproblems:  
	`L(j) = 1 + max{L(i): (i,j) ∈ E}`
- Pseudocode

	```
	for j = 1..n:
		L(j) = 1 + max{L(i): (i,j) ∈ E}
	return max_j L(j)
	```

- Runtime: `O(|E|) = O(n^2)` 

### __Edit Distance__

For 2 strings, the _cost_ of an alignment between them is the # of _edits_ (insertion, deletion, substitution) needed to transform string 1 to string 2. Find the _min_ cost.

- Strings `x, y`
- Subproblem:  
	`E(i,j) = edit distance between x[1..i] & y[1..j]`
- Solution to subproblems:  
	`E(i,j) = min{ 1+E(i−1,j), 1+E(i,j−1), diff(i,j)+E(i−1,j−1) }`
- Pseudocode

	```
	for i = 0..m: 
		E(i,0) = i
	for j = 1..n: 
		E(0,j) = j
	for i = 1..m: 
		for j = 1..n:
			E(i,j) = min{ E(i − 1,j) + 1, E(i,j − 1) + 1, E(i − 1,j − 1)+diff(i,j) }
	return E(m,n)
	```
- Runtime: `O(mn)` 

### __Knapsack Problem__

`n` items of weight `w1, ..., wn` and value `v1, ..., vn`, what is the most valuable combination of items that the total weight is at most `W` pounds?

#### Allows Repetition

- Subproblem:  
	`K(w) = max value achievable with knapsack of capacity w`
- Solution to subproblems:  
	`K(w) = max_i:wi<=w { K(w−wi)+vi }`
- Pseudocode

	```
	K(0) = 0
	for w = 1 to W:
		K(w) = max { K(w−wi)+vi: wi ≤w } 
	return K(W)
	```

>#### Memoization
> ```
> A hash table, initially empty, holds values of K(w) indexed by w
> function knapsack(w):
> 	if w is in hash table: 
> 		return K(w) 
> 	K(w) = max { knapsack(w−wi) + vi: wi≤w } 
>	insert K(w) into hash table, with key w 
>	return K(w)
> ```
> Only store information needed, unlike DP storing all

#### No Repetition

- Subproblem:  
	`K(w,j) = max value achievable with knapsack of capacity w and items 1..j`
- Solution to subproblems:  
	`K(w,j) = max { K(w−wj,j-1) + vj, K(w,j-1) }`
- Pseudocode

	```
	Initialize all K(0, j) = 0 and all K(w, 0) = 0 
	for j = 1 to n:
		for w = 1 to W:
			if wj > w: 
				K(w,j) = K(w,j−1)
			else: 
				K(w,j) = max { K(w,j−1),K(w−wj,j−1) + vj }
	return K(W,n)
	```

### __Chain Matrix Multiplication__

Four matrices `A x B x C x D`, find the way of chaining that uses the least computations.

- Abstraction
	- __Binary trees__: `node = product of children`  

	```
	Ex.
			[]
		   /  \
		  []   D
		 /  \
		[]   C
	   /  \
	  A	   B	

	(((A x B) x C) x D)
	```

- Subproblem:  
	`C(i,j) = min cost of multiplying Ai..Aj`
- Solution to subproblems:  
	`C(i,j) = min_i<=k<j { C(i,k) + C(k+1,j) + m_i-1 * mk * mj }`
- Pseudocode

	```
	fori = 1 to n: 
		C(i,i) = 0 
	for s=1 to n−1:
		for i=1 to n−s: 
			j = i + s
			C(i,j) = min { C(i,k) + C(k+1,j) + m_i−1 * mk * mj: i ≤ k < j } 
	return C(1,n)
	```

- Runtime: `O(n^3)`

### __Shortest Paths__

#### Shortest Reliable Paths

Find the shortest path in a graph from `s` to `t` using at most `k` edges.

- Subproblem:  
	`dist(v,i) = length of shortest path from s to v using i edges`
- Solution to subproblems:  
	`dist(v,i) = min_(u,v)∈E { dist(u,i−1) + l(u,v) }`
- Initial values:  
	`dist(v, 0) = infinity, dist(s, 0) = 0`

#### All-Pairs Shortest Paths

_Floyd-Warshall algorithm_

- Subproblem:  
	`dist(i,j,k) = length of shortest path from i to j using only nodes {1..k}`
- Solution to subproblems:  
	`dist(i,j,k) = min { dist(i,k,k−1) + dist(k,j,k−1), dist(i,j,k−1) }`
- Pseudocode  

	```
	for i = 1 to n: 
		for j = 1 to n:
			dist(i,j,0) = ∞
	for all (i,j) ∈ E: 
		dist(i,j,0) = l(i,j)
	for k = 1 to n: 
		for i = 1 to n:
			for j = 1 to n:
				dist(i,j,k) = min{ dist(i,k,k−1) + dist(k,j,k−1), dist(i,j,k−1) }
	```

#### The Traveling Salesman Problem

Find a min cost path in a graph that starts and end at 1 and goes through all nodes exactly once.

- Subproblem:  
	`C(S,j) = length of shortest path visiting nodes in S exactly once, starting at 1 and ending at j`
- Solution to subproblems:  
	`C(S,j) = min_i∈S:i!=j { C(S-{j}, i) + dij }`  
- Pseudocode

	```
	C({1},1) = 0
	for s = 2 to n:
		for all subsets S ⊆ {1..n} of size s and containing 1: 
			C(S,1) = ∞
			for all j ∈ S, j != 1: 
				C(S,j) = min { C(S−{j},i) + dij: i∈S,i!=j}
	return min_j { C({1..n},j) + dj1 }
	```

- Runtime: `O(n^2*2^n)`
	- `2^n*n` subproblems, each `O(n)` time

#### Independent Sets in Trees

_Independent sets_: for graph `G = (V,E)`, a subset of nodes `S ⊂ V` is an independent set if there are no edges between them.

- Subproblem:  
	`I(u) = size of largest independent set of subtree hanging from u`
- Solution to subproblem:  
	`u` is either included in the largest independent set or not  
	`I(u) = max { 1 + sum_grandchildren_w_of_u I(w), sum_children_w_of_u I(w) }`















