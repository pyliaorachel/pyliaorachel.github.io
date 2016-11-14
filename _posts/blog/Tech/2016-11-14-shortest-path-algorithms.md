---
layout: post
title:  "Shortest Path Algorithms"
categories: Blog Notes Algorithm
tags: ["dijkstra's", "bellman-ford", "floyd–warshall", "data structure", "algorithm", "CSC373"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Dijkstra's Algorithm
2. Bellman-Ford Algorithm
3. Floyd–Warshall Algorithm
4. Shortest Paths in DAGs

<!--more-->
---
## Dijkstra's Algorithm

[GeeksForGeeks](http://www.geeksforgeeks.org/greedy-algorithms-set-6-dijkstras-shortest-path-algorithm/)  
[Wiki](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)

#### Features

- Only handles positive edges
- Need __global information__
- Similar to [Prim's](http://www.geeksforgeeks.org/greedy-algorithms-set-5-prims-minimum-spanning-tree-mst-2/)

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
			if dist(v) > dist(u) + l(u, v): 
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
		if dist(z) > dist(v) + l(v, z): 
			dist(z) = dist(v) + l(v, z)
```

#### Runtime

- Binary heap: `O(|E|log|V|)`
- Array: `O(|V|^2)`

## Bellman-Ford Algorithm

[GeeksForGeeks](http://www.geeksforgeeks.org/dynamic-programming-set-23-bellman-ford-algorithm/)  
[Wiki](https://en.wikipedia.org/wiki/Bellman%E2%80%93Ford_algorithm)

#### Features

- Handles __negative edges__
- Only need __local information__ [StackOverflow](http://stackoverflow.com/questions/16273092/difference-between-bellman-ford-and-dijkstras-algorithm)

#### Implementation

```
Bellman-Ford(G, l, s):
# Input: Directed graph G = (V, E);
		 edge lengths {le : e ∈ E} with no negative cycles; 
		 vertex s ∈ V
# Output: For all vertices u reachable from s, dist(u) is set to the distance from s to u

	for all u ∈ V : 
		dist(u) = ∞
		prev(u) = nil
	
	dist(s) = 0
	repeat |V| − 1 times:
		for all e ∈ E: 
			update(e)
```

#### Runtime

`O(|V||E|)`

#### Negative Cycle Detection

After `|V|-1` times of iterations, apply 1 extra round. If some `dist` reduced, then there is negative cycle.

## Floyd-Warshal Algorithm

[GeeksForGeeks](http://www.geeksforgeeks.org/dynamic-programming-set-16-floyd-warshall-algorithm/)  
[Wiki](https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm)

#### Features

- Handles __negative edges__
- Find shortest paths between __all pairs of vertices__
- No __negative cycles__

#### Implementation

```
Floyd-Warshal(G, l, s):

	for all u ∈ V: 
		dist(u,u) = 0
	for all (u,v) ∈ E:
		dist(u,v) = l(u,v)

	for k = 1..|V|:
		for i = 1..|V|:
			for j = 1..|V|:
				if dist(i,j) > dist(i,k) + dist(k,j)
					dist(i,j) = dist(i,k) + dist(k,j)
```

#### Runtime

`O(|V|^3)`

## Shortest Paths in DAGs

#### Features

- Vertices appear in __increasing linearized order__ in any paths

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





















