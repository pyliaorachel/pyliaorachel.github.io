---
layout: post
title:  "Coping with NP-Complete Problems"
categories: Blog Notes Algorithm
tags: ["np-complete", "algorithm", "CSC373"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Intelligent Exhaustive Search
	1. Backtracking
	2. Branch-and-Bound
2. Approximation Algorithms
	1. Vertex Cover
	2. Clustering
	3. TSP
	4. Knapsack
	5. Approximability Hierarchy
<!--more-->
---
## Intelligent Exhaustive Search

### Backtracking

```
Start with some problem P0
Let S = {P0}, the set of active subproblems 
Repeat while S is nonempty:
	choose a subproblem P ∈ S and remove it from S 
	expand it into smaller subproblems P1, P2, ..., Pk 
	For each Pi:
		If test(Pi) succeeds: halt and announce this solution
		If test(Pi) fails: discard Pi
		Otherwise: add Pi to S # uncertainty
Announce that there is no solution
```

### Branch-and-Bound

```
Start with some problem P0
Let S = {P0}, the set of active subproblems bestsofar = ∞
Repeat while S is nonempty:
	choose a subproblem (partial solution) P ∈ S and remove it from S 
	expand it into smaller subproblems P1, P2, ..., Pk
	For each Pi:
		If Pi is a complete solution: update bestsofar
		else if lowerbound(Pi) < bestsofar: add Pi to S
return bestsofar
```

- [TSP example](http://www.jot.fm/issues/issue_2003_05/column7/)

## Approximation Algorithms

Minimize `αA = max_I(A(I)/OPT(I))`, where `αA` is the __approximation ratio__ of algorithm `A`.  

### Vertex Cover

```
Input: undirected graph G = (V, E)
Output: a subset of the vertices S ⊆ V that touches every edge
Goal: Minimize |S|
```

1. Greedy algorithm (used for __set cover__ problem)

	Repeatedly include the highest degree in the vertex cover.  
	=> factor `O(logn)`

2. Matching

	A subset of edges that have no vertices in common.  
	If `S` is the set containing both endpoints of each edge in maximal matching `M`, then `S` is vertex cover.
	- Any matching is a __lower bound__ on `OPT`
	- Maximal matching with `M` edges provides `2M` __upper bound__ on `OPT`

	```
	Find a maximal matching M ⊆ E
	Return S = {all endpoints of edges in M }
	```

	=> factor `2`

### Clustering

```
Divide some data into groups. Distances between data points are defined:

1. d(x,y) ≥ 0 for all x,y
2. d(x,y) = 0 iff x = y
3. d(x,y) = d(y,x)
4. (Triangle inequality) d(x,y) ≤ d(x,z) + d(z,y)

k-CLUSTER:

Input: points X = {x1, ..., xn} with underlying distance metric d(·,·); integer k 
Output: a partition of points into k clusters C1, ..., Ck
Goal: minimize diameter of the clusters,
		max_j(max_xa,xb∈Cj(d(xa,xb))
```

- Farthest-first traversal

	Pick k of the data points as cluster centers one at a time and always pick the next center to be as far as possible from the centers chosen so far.

	```
	Pick any point μ1 ∈ X as the first cluster center 
	for i = 2 to k:
		Let μi be the point in X that is farthest from μ1, ..., μi−1 (i.e. maximizes min_j<i(d(·,μj)))
	Create k clusters: Ci = {all x ∈ X whose closest center is μi}
	```

	=> factor `2`

	```
	# Argument

	1.
	Let x ∈ X be the point farthest from μ1, ..., μk
	Let r be its distance to closest center
	=> every point in X must be within distance r of its cluster center
	=> every cluster has diameter <= 2r

	2.
	{μ1, ..., μk, x} are all at distance >= r
	=> any partition into k clusters must put 2 of them in same cluster
	=> diameter at least r
	```

### TSP

- MST for metric TSP

	`TSP cost ≥ cost of this path ≥ MST cost`

	From MST, going through each edge twice ends up with a TSP, so `length <= 2 * MST cost <= 2 * TSP cost`.

	Further skip any city about to revisit and instead move directly to the next new city.

- General TSP -> Rudrata Path

	```
	For an instance I(G, C) of the TSP:
		If G has a Rudrata path, then OPT(I(G,C)) = n
		If G has no Rudrata path, then OPT(I(G,C)) ≥ n + C
	``` 
	```
	Given any graph G:
		compute I(G,C) (with C = n * αA)
		run approximation algorithm A for TSP on it 
		if the resulting tour has length ≤ nαA:
			G has a Rudrata path 
		else: 
			G has no Rudrata path
	# can find the path by calling procedure polynomial number of times
	```
	
	If TSP has a polynomial-time approximation algorithm, then there is a polynomial algorithm for Rudrata path problem. So unless P = NP, there cannot exist an efficient approximation algorithm for TSP.

### Knapsack

```
1. Change O(nW) algorithm into O(nV)
2. Scale v'i = ⌊vi * n/εvmax⌋
3. Since rescaled values v'i are all at most n/ε, DP runs in O(n^3/ε)

Discard any item with weight > W
Let v_max = max_i(vi)
Rescale values v'i = ⌊vi * n/εvmax⌋
Run DP with values {v'i} 
Output the resulting choice of items

Let K* be the total value of the original optimal solution.

sum_i∈S(v'i) = sum_i∈S(⌊vi * n/εvmax⌋) >= sum_i∈S(vi * n/εvmax - 1) >= K* * (n/εvmax) - n

Scaling back:

sum_i∈S'(vi) >= sum_i∈S'(v'i * εvmax/n) >= (K* * (n/εvmax) - n)* εvmax/n = K* - εvmax >= K* * (1-ε)
```

### Approximability Hierarchy

1. No finite approximation ratio possible (TSP)
2. Approximation ratio possible, but with limits (Vertex Cover, k-Cluster, Metric TSP)
3. Approximation ratio possible with no limits (Knapsack)
4. Approximation ration about `logn` (Set Cover)

#### Resources
* [UCSD Notes on Clustering](https://cseweb.ucsd.edu/~dasgupta/291-geom/kcenter.pdf)









