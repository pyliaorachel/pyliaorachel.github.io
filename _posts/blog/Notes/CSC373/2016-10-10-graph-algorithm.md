---
layout: post
title:  "Graph Algorithm"
categories: Blog Notes Algorithm
tags: ["dijkstra's", "bellman-ford", "graph", "data structure", "algorithm", "CSC373"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Dijkstra's Algorithm
2. Shortest Paths with Negative Edges
	1. Bellman-Ford Algorithm
3. Shortest Paths in DAGs

<!--more-->
---
## Dijkstra's Algorithm
- Shortest path problem
- Adapted from BFS with edge lengths positive

#### Tricks
- Replace edges with len  1 with multiple edges of len 1 & dummy nodes  
- Then run BFS  
- Not efficient with more nodes!  

#### Implementation

```
Dijkstra(G, l, s):
# Input: Graph G = (V, E), directed or undirected;
		 positive edge lengths {le : e ∈ E}; vertex s ∈ V
# Output: For all vertices u reachable from s, dist(u) is set to the distance from s to u

	for all u ∈ V : 
		dist(u) = ∞
		prev(u) = nil 
	dist(s) = 0

	H = makequeue(V) # using dist-values as keys 
	while H is not empty:
		u = deletemin(H) # = |V| times
		for all edges (u, v) ∈ E:
			if dist(v)  dist(u) + l(u, v): 
				dist(v) = dist(u) + l(u, v) 
				prev(v) = u 
				decreasekey(H, v) # = |V| + |E| times
```
```
# Alternative

Initialize dist(s) to 0, other dist(·) values to ∞ 
R = { } # the "known region"
while R != V:
	Pick the node v !∈ R with smallest dist(·) 
	Add v to R
	for all edges (v, z) ∈ E:
		if dist(z)  dist(v) + l(v, z): 
			dist(z) = dist(v) + l(v, z)
```
=> Binary heap: `O((|V| + |E|)log|V|)`

#### Update Operation
`dist(v) = min{dist(v), dist(u) + l(u, v)}` 
 
1. Correct distance to v where u is second-last in shortest path & dist(u) is correct  
2. Never make dist(v) too small (i.e. never underestimate) = safe

#### Analysis - Heaps & Array  

| Implementation | deletemin | insert/decreasekey | &#124;V&#124;xdeletemin + (&#124;V&#124;+&#124;E&#124;)xinsert |
|:---|:---|:---|:---|
| Array | O(&#124;V&#124;) | O(1) | O(&#124;V&#124;^2) |
| Binary heap | O(log&#124;V&#124;) | O(log&#124;V&#124;) | O((&#124;V&#124; + &#124;E&#124;)log&#124;V&#124;) |
| d-ary heap | O(dlog&#124;V&#124;/log d) | O(log&#124;V&#124;/log d) | O(&#124;V&#124;*d + &#124;E&#124;log&#124;V&#124;/logd) |
| Fibonacci heap | O(log&#124;V&#124;) | O(1) (amortizes) | O(&#124;V&#124;log&#124;V&#124; + &#124;E&#124; |  

- If G sparse - heap (|E| ~ |V|)  
- If G dense - array (|E| ~ |V|^2)

#### Priority Queue Implementations
1. Array  
	- insert/decreasekey: `O(1)`  
	- deletemin: `O(n)`  
2. Binary Heap
	- complete binary tree (filled in from left to right, full)
	- key value <= childrens'
	 	- insert/decreasekey: `O(log n)`  
		- deletemin: `O(log n)`  
	- array representation: parent @ `floor(j/2)`, children @ `2j` & `2j+1`
3. d-ary heap
	- nodes have d children
	- h(T) = `Θ(log d n)` = `Θ((log n)/(log d))`
		- insert: `Θ((log n)/(log d))`
		- deletemin: `Θ(d * log d n)`
	- array representation: parent @ `(j-1)/d`, children @ `{(j-1)d+2, ..., min{n, (j-1)d+d+1}}`

## Shortest Paths with Negative Edges

### _Bellman-Ford Algorithm_

Update _all_ edges `|V|-1` times!

#### Implementation

```
Shortest-paths(G, l, s):
# Input: Directed graph G = (V, E);
		 edge lengths {le : e ∈ E} with no negative cycles; 
		 vertex s ∈ V
# Output: For all vertices u reachable from s, dist(u) is set to the distance from s to u
	for all u ∈ V : 
		dist(u) = ∞
		prev(u) = nil
	
	dist(s) = 0
	repeat |V | − 1 times:
		for all e ∈ E: 
			update(e)
```
=> `O(|V|*|E|)`

#### Termination
1. No update occurred (assume no __negative cycles__)
2. After `|V|-1` times of iterations, apply 1 extra round. If some `dist` reduced <- negative cycle

#### Proofs

[Proofs](https://www.cs.princeton.edu/~wayne/kleinberg-tardos/pdf/06DynamicProgrammingII.pdf)

- If some path from `v` to `t` contains a negative cycle, then there does not exist a cheapest path from `v` to `t`.
- If `G` has no negative cycles, then there exists a cheapest path from `v` to `t` that is simple (and has ≤ `n – 1` edges).
- `dist(v)` is the cost of some `v-t` path; after the `ith` pass, `dist(v)` is no larger than the cost of the cheapest `v-t` path using ≤ `i` edges.
- If the successor graph contains a directed cycle, then it is a negative cycle.

#### Features v.s. Dijkstra's

- Handles __negative weights__
- Only need __local information__ [StackOverflow](http://stackoverflow.com/questions/16273092/difference-between-bellman-ford-and-dijkstras-algorithm)

## Shortest Paths in DAGs

In any path of a DAG, the vertices appear in __increasing linearized order__.

#### Implementation

```
Dag-shortest-paths(G, l, s):
# Input: DagG = (V,E);
		 edge lengths { le: e ∈ E };
		 vertex s ∈ V
# Output: For all vertices u reachable from s, dist(u) is set to the distance from s to u

for all u ∈ V: 
	dist(u) = ∞
	prev(u) = nil

dist(s) = 0
Linearize G # DFS
for each u ∈ V, in linearized order:
	for all edges (u, v) ∈ E: 
		update(u, v)
```

## References
* Dasguptap, S., Papadimitriou, C.H., & Vazirani, U.V. Algorithms. Chapter 4.1-4.7.




















