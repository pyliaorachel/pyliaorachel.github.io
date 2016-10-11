---
layout: post
title:  "Greedy Algorithm Notes"
categories: Blog Notes Algorithm
tags: ["greedy", "algorithm", "CSC384"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

>## Content
>1. Minimum Spanning Tree
>2. Huffman Encoding

<!--more-->

# Greedy Algorithms

### What is greedy?

Take the best move at the moment without worrying about future outcomes.

## Minimum Spanning Tree

- A graph, connecting all nodes with edges that cost the least in total.
- No cycle

># Definition
>- _Input_: An undirected graph G = (V, E); edge weights we  
>- _Output_: A tree T = (V,E'), with E' ⊆ E, that minimizes weight(T) = Σ(e ⊆ E')we

<!-- -->
>### Trees
> Undirected graph, connected & acyclic  
>
>- Removing a cycle edge cannot disconnect a graph
>- A tree with `n` nodes has `n-1` edges
>- Any connected, undirected graph with `|E| = |V| - 1` is a tree.
>- An undirected graph is a tree <-> there's a unique path between any pair of nodes

### Kruskal's MST Algorithm

1. Start with empty graph
2. Add the next lightest edge that doesn't produce a cycle
3. Do until all nodes connected

>## The Cut Property
>- Cut: any partition of vertices into 2 groups `S` & `V-S`
>- Let `X` be subset of MST not crossing between `S` & `V-S`
>- Pick `e` to be the lightest edge connecting `S` & `V-S`
>- `X ∪ {e}` is MST

<!-- -->
>## Implementation
>	```
>	Kruskal(G, w):
>	# Input: A connected undirected graph G = (V, E) with edge weights we 
>	# Output: A minimum spanning tree defined by the edges X
>
>		for all u ∈ V : # => O(|V|)
>			makeset(u) # create a singleton set containing just u
>
>		X = {}
>		Sort the edges E by weight # => O(|E|log|V|) where log|E| ~ log|V|
>		for all edges {u, v} ∈ E, in increasing order of weight: # => O(|E|log|V|)
>			# find sets to which u & v belong
>			if find(u) != find(v):
>				add edge {u, v} to X 
>				union(u, v) # merging sets
>	```

<!-- -->
>## Data Structure for Disjoin Sets
>- Directed tree
>- Root element as identifier
>
>	```
>	# π = parent pointer
>	# rank = height of subtree hanging from that node
>
>	makeset(x): # => O(1)
>		π(x) = x
>		rank(x) = 0
>
>	find (x): # => O(logn)
>		while x != π(x): 
>			x = π(x) 
>		return x
>
>	union(x, y)  # => O(logn)
>		rx = find(x)
>		ry = find(y)
>		if rx = ry: 
>			return 
>		if rank(rx) > rank(ry):
>			π(ry) = rx  # make root of y-tree point to root of x-tree
>		else:
>			π(rx) = ry
>			if rank(rx)=rank(ry): 
>				rank(ry)=rank(ry)+1
>	```
>
>- Any root node of rank `k` has at least `2^k` nodes in its tree
>- So if `n` elements overall, at most `n/(2^k)` of rank `k`
>- => max rank = `log(n)` (upper bound of `find` & `union`)

<!-- -->
>## Optimization - Path Compressin
>	```
>	find(x):
>		if x != π(x): 
>			π(x) = find(π(x)) 
>		return π(x)
>	```

### Prim's Algorithm

1. Start with empty graph
2. Add any vertex to `S`
3. Add a min-weight edge from `S` to `V-S`
4. Repeat until done

>## Pseudocode
>	```
>	X = { } (edges picked so far) 
>	repeat until |X| = |V| − 1:
>		pick a set S ⊂ V for which X has no edges between S and V−S
>		let e ∈ E be the minimum-weight edge between S and V − S
>		# cost(v) = min(u ∈ S) w(u, v)
>		X = X ∪ {e}
>	```

<!-- -->
>## Implementation
>	```
>	Prim(G, w):
>	# Input: A connected undirected graph G = (V, E) with edge weights we 
>	# Output: A minimum spanning tree defined by the array prev
>		for all u ∈ V: 
>			cost(u) = ∞
>			prev(u) = nil
>		Pick any initial node u0 
>		cost(u0) = 0
>		
>		H = makequeue (V) # priority queue, using cost-values as keys 
>		while H is not empty:
>			v = deletemin(H) 
>			for each {v, z} ∈ E:
>				if cost(z) > w(v, z): 
>					cost(z) = w(v, z) 
>					prev(z) = v 
>					decreasekey(H, z)
>	```

<!-- -->
>## Difference with Dijkstra's Algorithm
>- Key by with priority queue is ordered
>	- __Prim's__: lightest incoming edge from set S
>	- __Dijkstra's__: length of path from start to that node

## Huffman Encoding

- Encode a string of length T over alphabet Γ

>## Prefix-free Encoding
>- No codeword can be a prefix of another
>- Can be represented by a _full_ binary tree
>- Leaves: symbols
>- Path from root to leaf: codeword, left = 0, right = 1

<!-- -->
>## Optimal Coding Tree
> A tree whose leaves each correspond to a symbol  
> Min overall length of encoding  
> `cost of tree = Σ(i=1, n) fi * di`  
> Or, combine freq of 2 decendants into freq of parent:  
> `cost of tree = Σ(leaves) fi + Σ(internal nodes) fi` 

<!-- -->
>## Construction
> Implication: nodes with smallest freq @ bottom of tree  
> Greedy construction:
>
>	1. Find 2 smallest freq nodes
>	2. Combine into new node, `f = f1 + f2`
>	3. Replace 2 nodes with new node
>	4. Repeat

>## Implementation
>	```
>	Huffman(f):
>	# Input: An array f [1 · · · n] of frequencies 
>	# Output: An encoding tree with n leaves
>
>		let H be a priority queue of integers, ordered by f 
>		for i = 1 to n: 
>			insert(H,i)
>		for k = n + 1 to 2n − 1:
>			i = deletemin(H), j = deletemin(H)
>			create a node numbered k with children i, j 
>			f[k] = f[i] + f[j]
>			insert(H, k)
>	```
> => Binary heap: `O(nlogn)`

<!-- -->
>#### References
>* Dasguptap, S., Papadimitriou, C.H., & Vazirani, U.V. Algorithms. Chapter 5.1-5.2.