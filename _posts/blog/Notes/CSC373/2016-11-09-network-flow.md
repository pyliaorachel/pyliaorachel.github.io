---
layout: post
title:  "Network Flow"
categories: Blog Notes Algorithm
tags: ["network flow", "algorithm", "CSC373"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Flow Network Overview
2. Maximum-Flow Problem
	1. Residual Graph
	2. Implementation (Ford-Fulkerson Algorithm)
	3. Analysis
	4. Max-Flow Min-Cut Theorem
	5. Choosing Good Augmenting Paths
3. Extensions to Max-Flow Problem
	1. Circulations with Demands
	2. Circulations with Demands & Lower Bounds
4. Bipartite Matching
5. Image Segmentation
6. Project Selection
7. Baseball Elimination

<!--more-->
---
### __Flow Network Overview__

- Components
	- __Capacities__
	- __Source nodes__
	- __Sink nodes__
	- __Traffic__
- Graph representation

	```
	G = (V,E)
	edge ce = capacity where ce >= 0
	source node s ∈ V
	sink node t ∈ V
	internal nodes = all other nodes
	```

- Assumptions
	- No edge enters `s` & no edge leaves `t`
	- At least 1 edge incident to each node
	- `c` is int
- Flow conditions & notations
	- `f(e)` satisfies:
		1. `0 <= f(e) <= ce` for all edges
		2. `sum_e_into_v(f(e)) = sum_e_outof_v(f(e))` for all internal nodes
	- `v(f)` denotes __amount of flow generated at source__
		- `sum_e_outof_s(f(e))`
	- `f_out(v)` = `sum_e_outof_v(f(e))`; `f_in(v)` = `sum_e_into_v(f(e))` 

### __Maximum-Flow Problem__

Given a flow network, find a flow of max possible value.

#### Residual Graph

- A graph indicating additional possible flow. If there is a path from source to sink in residual graph, then it is possible to add flow. 
- Every edge of a residual graph has a value `residual capacity = original capacity of the edge - current flow`. Residual capacity is basically the current capacity of the edge.

#### Implementation (Ford-Fulkerson Algorithm)

[Video](https://www.youtube.com/watch?v=-8MwfgB-lyM)

1. Initial flow `f` = 0
2. Find an augmenting path `P` from `s` to `t`
3. Augment the path `P` with flow `f`, return new flow `f'`
	1. Let `b = bottleneck(P,f)`
	2. For each edge `e = (u,v)` of `P`:
		- If _forward edge_, `f(e) += b`
		- If _backward edge_, `f(e=(v,u)) -= b`
	3. return updated f
4. Update `f` to `f'`
5. Update residual graph `Gf` to `Gf'`
	1. Node set the same
	2. For each edge `e = (u,v)` of `Gf`, `f(e) < ce`:
		- Push `e = (u,v)` with capacity `ce - f(e)` (_forward edges_)
		- Push `e' = (v,u)` with capacity `f(e)` (_backward edges_)
6. Repeat until no path found

```
augment(f,P):
	Let b = bottleneck(P,f) 
	For each edge (u,v) ∈ P:
		If e = (u,v) is a forward edge: 
			increase f(e) in G by b
 		Else: # ((u, v) is a backward edge, and let e = (v, u))	
 			decrease f(e) in G by b
	Return f

Max-Flow():
	Initially f(e) = 0 for all e in G
	While there is an s-t path in the residual graph Gf:
		Let P be a simple s-t path in Gf
		f' = augment(f,P)
		Update f to be f'
		Update the residual graph Gf to be Gf'
	Return f
```

#### Analysis

- Termination
	- At every intermediate stage of the Ford-Fulkerson Algorithm, the flow values {`f(e)`} and the __residual capacities in Gf are integers__.
	- The flow value strictly increases when we apply an augmentation, since we add `bottleneck > 0`.
	- Upper bound: `f_out(s)`.
	- Hence the algorithm runs for at most `f_out(s)` iterations.
- Runtime
	- Let `m = |E|`, `n = |V|`, `C = f_out(s)`
	- `m >= n/2` since all nodes have at least 1 incident edge, so `O(m+n) = O(m)`
	- BFS/DFS: `O(m+n) = O(m)`
	- `augment`: `O(n)`
	- Build new residual graph: `O(m)`
	- Overall `O(mC)`

#### Max-Flow Min-Cut Theorem

In every flow network, the maximum value of an s-t flow is equal to the minimum capacity of an s-t cut.

- Cut
	- Divide nodes into 2 sets `A` & `B` s.t. `s ∈ A` and `t ∈ B`. Any flow going from `s` to `t` must cross from `A` into `B` at some point and use up some of the edge capacity from `A` to `B`.
	- __Cut__ puts bound on max flow
		- __Minimum cut__: the minimum capacity of any division, which equals the max flow
- Facts
	1. Let `f` be any s-t flow, and `(A, B)` any s-t cut. Then  
		`v(f) = f_out(A) − f_in(A)` and  
		`v(f) = f_in(B) − f_out(B)`

		```
		v(f) = f_out(s) - f_in(s)
			 = sum_v_in_A(f_out(v) - f_in(v)) # f_out(v) - f_in(v) = 0 for internal nodes
			 = sum_e_outof_A(f(e)) - sum_e_into_A(f(e))
			 = f_out(A) - f_in(A)
		f_out(A) = f_in(B); f_in(A) = f_out(B)
		```
	2. Let `f` be any s-t flow, and `(A,B)` any s-t cut. Then  
		`v(f) <= c(A,B)`, where `c(A,B) = sum_e_outof_A(ce)`
		
		```
		v(f) = f_out(A) − f_in(A)
			 ≤ f_out(A) # f_in(A) >= 0
			 = sum_e_outof_A(f(e))
			 ≤ sum_e_outof_A(ce)
			 = c(A,B)
		```

		=> Any flow is upper-bounded by the capacity of every cut
	3. Let `f` be an s-t flow s.t. no s-t path in the residual graph `Gf`. Then there is an s-t cut `(A*,B*)` in `G` where `v(f) = c(A*,B*)`.  

		```
		Let A* be a set of nodes in G where there is a s-v path in Gf
		Let B* = V - A*
		v(f) = f_out(A*) − f_in(A*)
			 = sum_e_outof_A*(f(e)) − sum_e_into_A*_f(e)
			 = sum_e_outof_A*(ce) - 0 # f(e) = ce
			 = c(A*,B*)
		```
	4. The flow `f` returned by Ford-Fulkerson is max flow.  

		```
		Let f* be max flow, (A*,B*) be min cut
		Then there exists a flow f s.t. v(f) = c(A,B) by 3.
		And by 2., v(f) = c(A,B) <= c(A*,B*)
		Hence A = A*, B = B* because c(A*,B*) should be minimum
		And by 2., v(f*) <= c(A*,B*) = v(f)
		Hence f = f* because v(f*) should be maximum
		```

	- Given a max flow, we can compute an s-t min cut in `O(m)` time by constructing the residual graph and perform BFS/DFS to find `A*` & `B*`.
	- If all capacities in the flow network are integers, then there is a max flow `f` where every flow value `f(e)` is an integer.

##### Notes

- With __rational numbers__:
	- Multiply all by least common multiple of all capacities
- With __real numbers__:
	- May not terminate, since the progress we make at each iteration can be small
	- __Max-flow min-cut theorm__ still holds

#### Choosing Good Augmenting Paths

##### Idea 1

Find the path with `large bottleneck capacity`.  
Maintain a __scaling parameter `sp`__ and look for paths having bottleneck of _at least `sp`_.  

- Implementation

	```
	Scaling Max-Flow():
		Initially f(e) = 0 for all e in G
		Initially set sp = largest power of 2 <= max_e_outof_s(ce) 

		While sp >= 1:
			While there is an s-t path in the graph Gf(sp):
				Let P be a simple s-t path in Gf(sp)
					f' = augment(f,P)
					Update f to be f'
					Update Gf(sp)
			sp /= 2
		Return f
	```

- Runtime
	- Outer `While` loop (scaling phase): at most `1 + logC` where `C = sum_e_outof_s(ce)`
	- During the scaling phase, each augmentation increases the flow by at least `sp`
	- `v(f) >= max flow - m*sp` where `f = flow at the end of scaling phase` and `m = |E|`  

		```
		f(e) > ce - sp for e = (u,v) which u ∈ A and v ∈ B
		f(e) ≥ sp for e = (u,v) which u ∈ B and v ∈ A

		v(f) = sum_e_outof_A(f(e)) − sum_e_into_A(f(e))
			 ≥ sum_e_outof_A(ce - sp) - sum_e_into_A(sp)
			 = c(A,B) - m*sp
		```

	- \# of augmentations in a scaling phase is at most `2m`

		```
		v(f*) <= v(f_prev) + m*sp = v(f_prev) + 2m*sp_prev
		Each augmentation increases the flow by >= sp_prev
		So at most 2m augmentations
		```

	- Augmentation: `O(m)` time; `1 + logC` scaling phases; `2m` augmentations each phase => `O(m^2 logC)`
	- Scaling: polynomial in size of input (# of edges & numerical representation of capacities)  
	  Original: polynomial in magnatude of capacities

##### Idea 2

Choose path with __fewest number of edges__.

### __Extensions to Max-Flow Problem__

#### Circulations with Demands

Multiple sources & sinks with fixed supply/demand values.

- Demands
	- `dv > 0`: `v` wish to receive `dv` more flow than it sends out (__sink__)
	- `dv < 0`: `v` wish to send out `dv` more flow than it receives (__source__)
	- `dv = 0`: not source nor sink
- Conditions
	1. `0 <= f(e) <= ce` for all edges
	2. `sum_e_into_v(f(e)) = sum_e_outof_v(f(e))` for all internal nodes
	3. __All demands satisfied__
	4. Total supply = total demand  
		`sum_v(dv) = sum_v(f_in(v)) - sum_v(f_out(v)) = 0`  
		`sum_v_dv>0(dv) = sum_v_dv<0(-dv)`
- Conversion to Max-Flow Problem
	- Create super-source `s*` connecting each node in `S`; create super-sink `t*` connecting each node in `T`
	- For each node in `S` (`dv < 0`), add `(s*,v)` with capacity `-dv`; for each node in `T` (`dv > 0`), add `(v,t*)` with capacity `dv`
	- A feasible circulation is found iff max s*-t* flow has value `D`, where `D = max capaxity from s* to t*` (saturating edges connected to `s*` and `t*`)
	- Graph G has a feasible circulation with demands `{dv}` if and only if for all cuts (A,B):  
		`sum_v_in_B(dv) <= c(A,B)`

#### Circulations with Demands & Lower Bounds

Enforce flow to use certain edges - place __lower bounds__ on edges.

- Conditions
	1. `le <= f(e) <= ce` for all edges, where `le` is the lower bound
	2. `sum_e_into_v(f(e)) = sum_e_outof_v(f(e))` for all internal nodes
	3. __All demands satisfied__
	4. Total supply = total demand  
		`sum_v(dv) = sum_v(f_in(v)) - sum_v(f_out(v)) = 0`  
		`sum_v_dv>0(dv) = sum_v_dv<0(-dv)`
- Conversion to Max-Flow Problem
	- Let capacities of edges be `ce - le`
	- Let demands of nodes be `dv - Lv`, where `Lv = sum_e_into_v(le) - sum_e_outof_v(le)`
	- There is a feasible circulation in `G` iff there is a feasible circulation in `G'`, where `G` is the original graph, `G'` is the converted one

### __Bipartite Matching__

- Max-flow problem property: __if all edge capacities are integers, then the optimal flow found by our algorithm is integral.__
- Idea
	- Connect nodes from 1 set to `s` with capacity 1
	- Connect nodes from another set to `t` with capacity 1
	- Find max flow

### __Image Segmentation__

Separate the foreground and background of an image.

- Goal
	- Let `ai` be likelihood to foreground for pixel `i`
	- Let `bi` be likelihood to background for pixel `i`
	- Let `pij` be separation penalty
	- Maximize `q(A,B) = sum_i_in_A(ai) + sum_j_in_B(bi) - sum_(i,j)_in_diff_set(pij)`

- 3 problems
	1. The goal is seeking to maximize an objective
		- Maximize   
		  `q(A,B) = sum_i_in_A(ai) + sum_j_in_B(bi) - sum_(i,j)_in_diff_set(pij)`  
		   <=> Minimize  
		  `q'(A,B) = sum_i_in_A(bi) + sum_j_in_B(ai) + sum_(i,j)_in_diff_set(pij)`
	2. No source & sink
		- Create super-source `s*` for foreground & super-sink `t*` for background
	3. Undirected graph
		- Model neighboring pair with 2 directed edges

- Graph representation

	```
	Edges (s,j), where j ∈ B; capacity = aj
	Edges (i,t), where i ∈ A; capacity = bi
	Edges (i,j), where i ∈ A and j ∈ B; capacity = p_ij

	c(A,B) = q'(A,B)
	```

### __Project Selection__

A set of projects `P` has _revenue_ `pi` being either positive or negative. Certain projects have _prerequisites_ for other projects. Find a set of projects that maximizes the profits.

- Graph representation

	```
	Edges (s,i), where pi > 0; capacity = pi
	Edges (i,t), where pi < 0; capacity = -pi
	Edges (i,j), where i depends on j; capacity = inf

	Max flow C = sum_i_pi>0(pi)
	Min cut (A',B'), where if i ∈ A has edge (i,j), j ∈ A
	Set of projects: A'-{s}, optimal
	```

- Optimality analysis

	Prove the min cut in `G'` determines the optimum set of projects.  
	
	- Capacity of cut `(A',B')` is `c(A',B') = C − sum_i_in_A(pi)`
	- If `(A', B')` is a cut with capacity <= C, then set `A = A' − {s}` satisfies the precedence constraints
	- Hence `c(A',B') = C - profit(A)` and small cuts imply big profits

### __Baseball Elimination__

A set of teams `S`, each has `wi` wins. Some games `g_xy` left. Check if team `z` has been eliminated.

- Averaging argument

	```
	Suppose z has indeed been eliminated. 
	Then:

	- z can finish with at most m wins.
	- There is a set of teams T ⊆ S s.t. 
		sum_x_in_T(wx) + sum_x,y_in_T(gxy) > m|T|

	Hence one of the teams in T must end with > m wins.

	```

- Graph representation

	```
	Let u_xy be some games left between x & y
	Let m be w_z + remaining_games_of_z
	Let g* be total number of games left

	Edges (s,u_xy), capacity = g_xy
	Edges (u_xy,vx), capacity = inf
	Edges (vx,t), capacity = m - wx

	Eliminate x iff max flow in G < g* # else after g* games every team will have wins not exceeding m
	```

- Analysis
	- If both `x`, `y` belong to `T`, then `u_xy ∈ A`
	- `(A, B)` is a min cut: `u_xy ∈ A` iff both `x, y ∈ T`
	- `T` can be used in the averaging argument   

		```
		c(A,B) = sum_x_in_T(m-wx) + sum_{x,y}_!in_T(g_xy)
			   = m|T| - sum_x_in_T(wx) + (g* - sum_x,y_in_T(g_xy))
		m|T| - sum_x_in_T(wx) - sum_x,y_in_T(g_xy) < 0 # c(A,B) = g' < g*

		sum_x_in_T(wx) + sum_x,y_in_T(g_xy) > m|T|
		```

## References
* [GeeksForGeeks](http://www.geeksforgeeks.org/ford-fulkerson-algorithm-for-maximum-flow-problem/)





















