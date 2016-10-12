---
layout: post
title:  "Divide and Conquer Notes"
categories: Blog Notes Algorithm
tags: ["convex hull", "divide and conquer", "algorithm", "CSC384"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Convex Hull

<!--more-->
---
## Convex Hull
- Graham's scan: `O(nlogn)`

### _Divide and Conquer Convex Hull_
- Generalization of __MergeSort__

#### Pseudocode

```
# Presort points by x coordinate => O(nlogn)
# Assume linked list of hull vertices

MergeHull(HA, HB):
	Compute upper & lower tangents for HA & HB
	Discard all points lying between 2 tangents
	return MergedH

Hull(S):
	If |S| <= 3:
		Compute convex hull by brute force # => O(1)
		return H
	Else:
		Partition S into A (lowest x) & B (highest x) # => O(n)
		HA = Hull(A)
		HB = Hull(B)
		H = MergeHull(HA, HB) # => O(n)
		return H
```
=>	```
	T(n) = 1 		   if n <= 3
		   n + 2T(n/2) otherwise
	```
=> `O(nlogn)`

#### Computing Tangents

```
# Walking procedure

LowerTangent(HA, HB):
	Init a = rightmost point of HA
	Init b = leftmost point of HB

	# Orientation test of a, b, and neighboring vertices 
	While ab not a lower tangent for HA & HB:
		While ab not a lower tangent for HA:
			a = a - 1 # move clockwise
		While ab not a lower tangent for HB:
			b = b - 1 # move counterclockwise
	Return ab
```
=> `O(|HA| + |HB|) <= O(|A| + |B|) = O(n)`

### _Quickhull_
- Generalization of __QuickSort__
- `O(nlogn)` ~ `O(n^2)`
- No obvious way to convert it into randomized algorithm with `O(nlogn)` expected running time; but still performs well

#### Idea
- Discard points not on the hull as quickly as possible

#### Steps
1. Find max & min x, y coordinates
2. Draw a bounding rectangle -> those lying within discarded => `O(n)` by now
3. Classify remaining points into 4 corners -> if no remaining, then done
4. For each corner, find a point `c` that lies on the hull. May choose `c` by the most perpendicular distance.
5. Discard those in the triangle, and split remaining points into 2 subsets (classify them by 2 orientation tests).
6. Add the 2 corners in buckets, and recurse.

#### Running Time
- Depends on how evenly the points are split  
=> 	```
	T(n) = 1 			 if n = 1
		   T(n1) + T(n2) where n1 + n2 <= n
	```  
=> `O(nlogn)` if evenly distributed (`n1 ~= n2`; `max(n1, n2) <= a * n` for some constant `a < 1`)  
=> `O(n^2)` otherwise

### _Gift Wrapping and Jarvis's March_
- Variation of __SelectionSort__
- `O(n^2)`

#### Steps
1. Find any point on convex hull, e.g. lowest point
2. Say start with `p(0) = (Inf, 0)`, `p(1) = lowest point`
2. Assume `p(k)` & `p(k-1)` were the last 2 points added, find the next one `q` s.t. `angle[p(k-1), p(k), q]` is maximized => `O(n)`
3. Repeat `h` times, return back to starting point

#### Running Time

`O(nh)`, where n is the input size, h is the output size

- If h = o(logn), then faster than Graham's!

### _Chan's Algorithm_
- Combination of __Graham's scan__ & __Jarvis's march__
- Aims to be `O(nlogh)` (lower bound)

#### Steps
1. Partition points into groups of equal size `m` points, total `r` groups
2. For each group, compute its hull using __Graham's scan__ => total `O(rmlogm)` = `O(nlogm)`
3. Run __Jarvis's march__ on the groups. Computing tangent between a point & a convex `m` takes `O(logm)` time (binary search)  
	=> total `O(rlogm)` for `r` groups  
	=> `h` steps of Jarvis's march, total `O(hrlogm)` time
4. Combining, we get `O((n + hn/m) logm)` time
5. If set `m = h`, running time `O(nlogh)`

#### Tricks
- How do we know what `m` is if we don't know `h` in advance?
	- Guess the value: try `m = 1, 2, ...`, until `m >= h` => too long!
	- Binary search => but if `m = n/2`, stuck to `O(nlogn)` time
	- __Doubling search__:
		Start with small `m` and increase it rapidly (say, squaring it) => `O(nlogh)`

#### Pseudocode

```
PartialHull(P, m):

	Let r = ceil(n/m)
	Partition P into disjoint subsets P(1),P(2),... P(r), each of size at most m
	
	For i = 1 to r do:
		Compute Hull(P(i)) using Graham's scan
		Store the vertices in an ordered array
	
	Let p0 = (-Inf, 0)
	Let p1 be the bottommost point of P

	For k = 1 to m do: # => O(hrlogm) where we assume h = m
		For i = 1 to r do: # => O(rlogm)
			Compute point q in P(i) that maximizes the angle[p(k-1), p(k), q] # => O(logm)
		Let p(k+1) be the point q in q(1),q(2),...q(r) that maximizes the angle[p(k-1), p(k), q]
		If p(k+1) = p(1):
			Return {p(1), p(2), ... p(k)}

	Return "m was too small, try again."

Hull(P):

	For t = 1.. do: # stop when 2^2^t >= h, or t = ceil(lglgh)
		Let m = min(2^(2^t), n)
		Let L = PartialHull(P, m)
		If L != "try again":
			Return L

```

#### Running Time

```
The t-th iteration takes O(nlog2^2^t) = O(n*2^t) time
Sum(t = 1..lglgh) n*2^t =
	n * Sum(t = 1..lglgh) 2^t <= 
	n * 2^(1+lglgh) = 
	2nlgh = 
	O(nlogh)
```

## References
* http://www.cs.wustl.edu/~pless/506/l3.html