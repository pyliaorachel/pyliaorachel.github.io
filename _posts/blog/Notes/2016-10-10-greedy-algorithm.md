---
layout: post
title:  "Greedy Algorithm"
categories: Blog Notes Algorithm
tags: ["minimum spanning tree", "huffman encoding", "interval scheduling", "greedy", "algorithm", "CSC373"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Minimum Spanning Tree
2. Huffman Encoding
3. Interval Scheduling

<!--more-->
---
# Greedy Algorithms

### What is greedy?

Take the best move at the moment without worrying about future outcomes.

## Minimum Spanning Tree

- A graph, connecting all nodes with edges that cost the least in total.
- No cycle

#### Definition

- _Input_: An undirected graph G = (V, E); edge weights we  
- _Output_: A tree T = (V,E'), with E' ⊆ E, that minimizes weight(T) = Σ(e ⊆ E')we

#### Trees

Undirected graph, connected & acyclic  

- Removing a cycle edge cannot disconnect a graph
- A tree with `n` nodes has `n-1` edges
- Any connected, undirected graph with `|E| = |V| - 1` is a tree.
- An undirected graph is a tree <- there's a unique path between any pair of nodes

### _Kruskal's MST Algorithm_

1. Start with empty graph
2. Add the next lightest edge that doesn't produce a cycle
3. Do until all nodes connected

#### The Cut Property

- Cut: any partition of vertices into 2 groups `S` & `V-S`
- Let `X` be subset of MST not crossing between `S` & `V-S`
- Pick `e` to be the lightest edge connecting `S` & `V-S`
- `X ∪ {e}` is MST

#### Implementation

```
Kruskal(G, w):
# Input: A connected undirected graph G = (V, E) with edge weights we 
# Output: A minimum spanning tree defined by the edges X

	for all u ∈ V : # => O(|V|)
		makeset(u) # create a singleton set containing just u

	X = {}
	Sort the edges E by weight # => O(|E|log|V|) where log|E| ~ log|V|
	for all edges {u, v} ∈ E, in increasing order of weight: # = O(|E|log|V|)
		# find sets to which u & v belong
		if find(u) != find(v):
			add edge {u, v} to X 
			union(u, v) # merging sets
```

#### Running Time

`O(|E|log|V|)`

#### Data Structure for Disjoin Sets

- Directed tree
- Root element as identifier

```
# π = parent pointer
# rank = height of subtree hanging from that node

makeset(x): # = O(1)
	π(x) = x
	rank(x) = 0

find (x): # = O(logn)
	while x != π(x): 
		x = π(x) 
	return x

union(x, y)  # = O(logn)
	rx = find(x)
	ry = find(y)
	if rx = ry: 
		return 
	if rank(rx)  rank(ry):
		π(ry) = rx  # make root of y-tree point to root of x-tree
	else:
		π(rx) = ry
		if rank(rx)=rank(ry): 
			rank(ry)=rank(ry)+1
```

- Any root node of rank `k` has at least `2^k` nodes in its tree
- So if `n` elements overall, at most `n/(2^k)` of rank `k`
- => max rank = `log(n)` (upper bound of `find` & `union`)

#### Optimization - Path Compression
	
```
find(x):
	if x != π(x): 
		π(x) = find(π(x)) 
	return π(x)
```

### _Prim's Algorithm_

1. Start with empty graph
2. Add any vertex to `S`
3. Add a min-weight edge from `S` to `V-S`
4. Repeat until done

#### Pseudocode

```
X = { } (edges picked so far) 
repeat until |X| = |V| − 1:
	pick a set S ⊂ V for which X has no edges between S and V−S
	let e ∈ E be the minimum-weight edge between S and V − S
	# cost(v) = min(u ∈ S)(w(u, v))
	X = X ∪ {e}
```

#### Implementation

```
Prim(G, w):
# Input: A connected undirected graph G = (V, E) with edge weights we 
# Output: A minimum spanning tree defined by the array prev
	for all u ∈ V: 
		cost(u) = ∞
		prev(u) = nil
	Pick any initial node u0 
	cost(u0) = 0
	
	H = makequeue (V) # priority queue, using cost-values as keys 
	while H is not empty:
		v = deletemin(H) 
		for each {v, z} ∈ E:
			if cost(z) > w(v, z): 
				cost(z) = w(v, z) 
				prev(z) = v 
				decreasekey(H, z)
```

#### Running Time

`O(|E|log|V|)`

#### Difference with Dijkstra's Algorithm

- Key by with priority queue is ordered
	- __Prim's__: lightest incoming edge from set S
	- __Dijkstra's__: length of path from start to that node

## Huffman Encoding

Encode a string of length T over alphabet Γ

#### Prefix-free Encoding

- No codeword can be a prefix of another
- Can be represented by a _full_ binary tree
- Leaves: symbols
- Path from root to leaf: codeword, left = 0, right = 1

#### Optimal Coding Tree

- A tree whose leaves each correspond to a symbol  
- Min overall length of encoding  
	`cost of tree = Σ(i=1, n) fi * di`  
- Or, combine freq of 2 decendants into freq of parent:  
	`cost of tree = Σ(leaves) fi + Σ(internal nodes) fi` 

#### Construction

- Implication: nodes with smallest freq @ bottom of tree  
- Greedy construction:
	1. Find 2 smallest freq nodes
	2. Combine into new node, `f = f1 + f2`
	3. Replace 2 nodes with new node
	4. Repeat

#### Implementation

```
Huffman(f):
# Input: An array f [1 · · · n] of frequencies 
# Output: An encoding tree with n leaves

	let H be a priority queue of integers, ordered by f 
	for i = 1 to n: 
		insert(H,i)
	for k = n + 1 to 2n − 1:
		i = deletemin(H), j = deletemin(H)
		create a node numbered k with children i, j 
		f[k] = f[i] + f[j]
		insert(H, k)
```
=> Binary heap: `O(nlogn)`

## Interval Scheduling

### _Max Compatible Interval Scheduling_

A set of requests {1, 2, ..., n}; the ith request starts at s(i) and ends at f(i). Schedule the most intervals.

#### Attempts

1. Earliest starting time
	- Earliest request takes long?

2. Smallest interval

		|-------------|    |--------------|
					|----------|

3. Fewest conflicts

		|------|  |-------|  |-------|  |-------|
			|-------|   |-------|  |-------|
			|-------|   		   |-------|
			|-------|   		   |-------|

#### Solution

Base on earliest finish time.

```

# Initially let R be the set of all requests, and let A be empty 

While R is not yet empty
	Choose a request i ∈ R that has the smallest finishing time
	Add request i to A
	Delete all requests from R that are not compatible with request i
EndWhile
Return the set A as the set of accepted requests

```

#### Proof

1. Let `O` be an optimal set of compatible intervals. Prove that `A` contains the same # of intervals as `O`.

	```
	Let A = {i1, ..., ik}, O = {j1, ..., jm}. Prove k = m.

	From our algo: f(i1) <= f(j1) # we 'stay ahead'
	Now prove for each r = 1, f(ir) <= f(jr)
	```
2. For all indices r <= k, we have `f(ir) <= f(jr)`

	```
	Prove by induction.

	For r = 1, true.
	Let r  1. Assume f(i_r-1) <= f(j_r-1).
	We know f(j_r-1) <= s(jr), since O has compatible intervals.
	= f(i_r-1) <= f(j_r-1) <= s(jr)
	Thus jr is in set R of available intervals when our algorithm selects ir, hence f(ir) <= f(jr) so that we didn't choose it.
	```
	=> for each r, the rth interval we select finishes at least as soon as the rth interval in O.
3. `A` is optimal.

	```
	Prove by contradiction.

	Assume A not optimal, then m  k. # O schedules more than A
	By 2., there is request j_k+1 in O.
	This request starts after request jk ends & hence after ik ends.
	So R still contains j_k+1, which is valid to be put into A.
	- Contradiction -
	```

#### Running Time

`O(nlogn)`

#### Extension

Consider cost of rejecting an interval = __Weighted Interval Scheduling Problem__

### Schduling All Intervals

Partition all intervals across multiple resources = __Interval Partitioning/ Coloring Problem__

#### Lowerbound

In any instance of interval partitioning, `# of resources needed = depth of set of intervals`.

#### Pseudocode

```
# Sort the intervals by their start times, breaking ties arbitrarily 

Let I1, I2, . . . , In denote the intervals in this order
For j=1,2,3,...,n
	For each interval Ii that precedes Ij in sorted order and overlaps it 
		Exclude the label of Ii from consideration for Ij
	Endfor
	If there is any label from {1, 2, . . . , d} that has not been excluded then
		Assign a nonexcluded label to Ij 
	Else
		Leave Ij unlabeled 
	Endif
Endfor
```

#### Proof

1. Every interval will be assigned a label. No 2 overlapping intervals receive the same label

	```
	1. No interval unlabeled.

	Consider Ij, suppose t intervals precedes it and overlap it.
	These t intervals + Ij = t+1 intervals all passes over s(Ij), so 
		t+1 <= d
		t <= d-1
	Hence there will be a label to assign to Ij.

	2. No 2 overlapping intervals assigned the same label.

	I precedes I', and when I' is considered, we will not assign the label of I to I' from our algorithm.
	```

2. You will hence never reach a point where all labels are currently in use, which matches the lower bound and is optimal.

### _Minumum Maximum Lateness_

A set of n requests, resource available from time s, requiring t to finish, and deadline d. Schedule all requests while minimizing lateness.

#### Attempts

1. In order of increasing length ti
	- t1 = 2, d1 = 100; t2 = 10, d2 = 10?

2. In order of increasing _slack_ time `di - ti`
	- t1 = 1, d1 = 2; t2 = 10, d2 = 10?

#### Solution

Base on earlier deadlines.

```
# Order the jobs in order of their deadlines
# Assume for simplicity of notation that d1 ≤ ... ≤ dn 

Initially, f = s
Consider the jobs i = 1, ..., n in this order
	Assign job i to the time interval from s(i) = f to f(i) = f + ti 
	Let f = f + ti
End
Return the set of scheduled intervals [s(i), f (i)] for i = 1, . . . , n
```

#### Proof

1. Schedule has no __gaps__, i.e. no idle time.
2. There is an optimal schedule with no idle time.

	```
	Prove by exchange argument.

	Suppose schedule A' has an inversion if job i with di scheduled before job j with dj, but dj < di. Our algorithm has no inversions.
	```

3. All schedules with no inversions & no idle time have the same max lateness.

	```
	2 schedules with these properties can only differ in the order in which jobs with the same deadlines are scheduled.

	Let such deadline be d. There are some jobs with deadline d and scheduled consecutively. Among them, the latest scheduled one has the greatest lateness. This lateness does not depend on the order of the jobs!
	```

4. There is an optimal schedule with no inversions and no idle time.

	```
	a. If O has an inversion, there is a pair of jobs i & j s.t. j is schedules immediately after i, but dj < di.
	b. Swapping i, j, we get a schedule with one less inversion.
	c. The new max lateness <= original lateness.

		Assume each request r is scheduled [sr, fr] with lateness lr. Let L = max_r(lr).

		Let O' be the swapped schedule.

		= fi = sj, f'j = s'i

		All other jobs remain finishing at the same time after the swap, since t(i)+t(j) is the same.

		Job j will not have lateness increased, since it is put forward.

		For job i:
			If i not delayed, we're done.
			If i delayed:
				l'i = f'i - di = fj - di. Since di  dj:
					l'i = fj - di < fj - dj = lj
		
		Since L = lj  l'i, the swap doesn't increase max lateness.
	```

5. An optimal schedule with no inversions exists. And all such schedules have the same max lateness. Hence algorithm optimal.

#### Extension
- Includes release time?

## References
* Dasguptap, S., Papadimitriou, C.H., & Vazirani, U.V. Algorithms. Chapter 5.1-5.2.
* Kleinberg, J., Tardos, E. Algorithm Design. Chapter 4.1-4.2.