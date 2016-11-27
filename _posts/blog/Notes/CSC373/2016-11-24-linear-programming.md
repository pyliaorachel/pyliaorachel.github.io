---
layout: post
title:  "Linear Programming"
categories: Blog Notes Algorithm
tags: ["linear programming", "algorithm", "CSC373"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Linear Programming & Reduction Overview
2. Duality
3. Simplex Algorithm
4. Circuit Evaluation

<!--more-->
---
## Linear Programming & Reduction Overview

```
LP & Reductions ---> Flows & matching
				---> Duality			---> Games
				---> Simplex
```

#### Linear Programming

- Objective function
	- Line
	- __Maximization__ or __minimization__
- Constraints
	- Feasible region
	- __Equations__ or __inequalities__
- Optimum achieved at a __vertex of feasible region__
	- __Simplex method__: _hill-climbing_ on vertices
		- Local = global optimality for linear functions

#### Reduction

If any subroutine for task Q can also be used to solve P, we say __P reduces to Q__.

```
x ---> Preprocess --y-> Algorithm for Q --Q(y)--> Postprocess ---> P(x)
```

#### Variants of Linear Programming

Reduction of variants into _standard form_:  

- Maximization to minimization:
	- Coefficients * (-1)
- Inequality to equation:
	- `sum_i_to_n(ai*xi) <= b` <=> `sum_i_to_n(ai*xi) + s <= b && s >= 0`
	- `s` = slack variable
- Equation to inequality:
	- `ax = b` <=> `ax <= b && ax >= b`
- Unsigned variables to signed:
	- `x` <=> `x+ - x-` where `x+, x- >= 0`

`min cTx s.t. Ax = b and x ≥ 0`

#### Matrix-Vector Notation

```
Objective function:
	c^Tx
	c = [c1, c2, ...], x = [x1, x2, ...]
Constraints:
	Ax <= b
	A = [[c11, c12, ...], [c21, c22, ...], ...], b = [b1, b2, ...]
x >= 0
```

## Duality

```
# Primal LP:
max cTx 
Ax ≤ b 
x ≥ 0

# Dual LP:
min yTb 
yTA ≥ cT 
y ≥ 0
```
```
# Primal LP:
max c1x1 +···+cnxn 
ai1x1+···+ainxn ≤ bi for i ∈ I (inequalities)
ai1x1+···+ainxn = bi for i ∈ E (equalities)
xj ≥ 0 for j ∈ N

# Dual LP:
min b1y1 +···+bmym 
a1jy1+···+amjym ≥ cj for j ∈ N 
a1jy1+···+amjym = cj for j !∈ N 
yi ≥ 0 for i ∈ I # equalities can have unrestricted variables (signed)
```

#### Duality Theorm

If a linear program has a bounded optimum, then so does its dual, and the two optimum values coincide.

#### Duality in Shortest-Path Problem

[StackExchange](http://math.stackexchange.com/questions/861079/shortest-path-problem-dual-formulation-and-proof-of-total-unimodularity)  
[Wiki](https://en.wikipedia.org/wiki/Shortest_path_problem#Linear_programming_formulation)

```
max xs - xt
|xu - xv| <= w_uv for all edges {u,v}
```

## Simplex Algorithm

#### Visualization

```
let v be any vertex of the feasible region
while there is a neighbor v' of v with better objective value:
	set v = v'
```
```
x1, ..., xn variables -> n-tuple in n-dimensional space
A linear equation 	  -> hyperplane in R^n
A linear inequality	  -> half-space in R^n
Linear program		  -> convex polyhedron in R^n; intersection of all half-spaces
```
```
Vertex: 
	Pick a subset of the inequalities. A vertex is a unique point that satisfies them with equality, and this point happens to be feasible.

Each vertex is specified by a set of n inequalities. (n linear equations to uniquely identify a point)

Neighbor:
	Two vertices are neighbors if they have n-1 defining inequalities in common.
```

#### Algorithm

```
max cTx 
Ax ≤ b 
x ≥ 0

1. Set origin to be current vertex.
2. Check whether the current vertex is optimal, i.e. coordinates of local cost vector (c) all <= 0.
3. If so, halt. Else, determine where to move next by increasing some xi for which ci > 0 until we hit some other constraint.
4. Transform the next vertex into origin and repeat.
```

##### Transformation into Origin

```
For inequality ai*x ≤ bi, to turn into yi ≥ 0:
	yi = bi - ai*x

Cost function:
	max cu + (c')^T y, cu = value of objective function at u, c' = transformed cost vector
```

#### Issues

1. How to find the starting vertex?

	General LPs won't always have inequalities with positive right-hand sides.

	```
	1. Rewrite LP into standard form:
		min cTx s.t. Ax = b and x ≥ 0
	2. Make sure right-hand sides of equations are nonnegative:
		if bi < 0, multiply both sides of the ith equation by -1
	3. Create new LP:
	   	- Create m new artificial variables z1, ..., zm >= 0
	   	- Add zi to left-hand side of the ith equation
	   	- Objective function: minimize z1+...+zm
	4. Starting vertex for new LP:
		zi = bi for all i, other variables 0
	5. Run simplex on new LP

	If zi+...+zm = 0:
		Optimum vertex of new LP = starting feasible vertex of original LP
	Else:
		Original LP not feasible
	```

2. Degeneracy?

	An LP is __degenerate__ if in a basic feasible solution, one of the basic variables takes on a zero value.

	In geometry, this means there is an intersection of more than `n` faces of the polyhedron.  
	- Problem:
		- May return __suboptimal__ degenerate vertex, because all neighbors are identical and no better objective
		- May __loop forever__, bacause if modify simplex, continue to hop from vertex to vertex without improvement  
	- __Perturbation__: change each `bi` by a tiny random amount to `bi += εi`  

3. Unboundedness?

	Objective function can be arbitrarily large/small.  

	Simplex will discover it: when exploring the neighborhood of a vertex, taking out an inequality and adding another leads to underdetermined system of equations that has infinite solutions.

#### Running Time

```
Generic LP:
	max cTx s.t. Ax ≤ 0 and x ≥ 0
```

- A vertex is where `n` inequality constraints are satisfied with equality
- Each of its neighbors shares `n-1` inequalities => `n * m` neighbors
- Finding cost `O(1)`
- Checking whether is a true vertex - solving `n` equations in `n` unknowns:
	- Gaussian elimination `O(n^3)` => total `O(nb^4)`
	- Use __move to origin__:
		- `O((m+n)n)` overhead to rewrite
		- `max cu + (c')^T y`, pick any `c'i > 0` to move to
		- `O(mn)` in total
- `C(m+n,n)` vertices => upper bound on # of iterations
- So __simplex is exponential__; but in practice not exponential

##### Gaussian Elimination

```
Gauss(E,X):
	# Input: A system E = {e1,...,en} of equations in n unknowns X = {x1,...,xn}:
	e1: a11x1 + a12x2 +···+ a1nxn = b1; ···; en: an1x1 + an2x2 +···+ annxn = bn 
	# Output: A solution of the system, if one exists

	if all coefficients ai1 are zero:
		halt with message "either infeasible or not linearly independent"
	if n = 1: return b1/a11

	choose the coefficient ap1 of largest magnitude, and swap equations e1, ep 
	for i = 2 to n:
		ei = ei  − (ai1/a11) * e1
	(x2, . . . , xn) = Gauss(E − {e1}, X − {x1}) 
	x1 = (b1 − sum_j>1(a1j * xj))/a11
	
	return (x1,...,xn)
```

## Circuit Evaluation

The most general problem solvable in polynomial time.  

```
|true| xg = 1
|false| xg = 0
|OR|  <- h	 xg >= xh, xg >= xh'
	  <- h'  xg <= xh + xh'
|AND| <- h	 xg <= xh, xg <= xh'
	  <- h'  xg >= xh + xh'	- 1
|NOT| <- h	 xg = 1 - xh
```

#### Resources
* [The Simplex Method](https://www.utdallas.edu/~scniu/OPRE-6201/documents/LP4-Simplex.html)
* [Yale LP Notes](http://www.cs.yale.edu/homes/aspnes/pinewiki/LinearProgramming.html)
* [Pitt LP Notes](http://www.pitt.edu/~kaveh/Lin-programming-notes.pdf)
* [MIT LP Notes](http://courses.csail.mit.edu/6.854/06/scribe/s15.pdf)
* [UBalt Flow Notes](http://home.ubalt.edu/ntsbarsh/opre640a/partIII.htm#rsppr)
* [The Diet Problem](https://neos-guide.org/content/diet-problem)
















