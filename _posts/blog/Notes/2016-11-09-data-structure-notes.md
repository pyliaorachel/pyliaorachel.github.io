---
layout: post
title:  "Data Stucture Notes"
categories: Blog Notes Competition
tags: ["competition", "data structure"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

Data stucture notes for coding competitions.

<!--more-->
---
## BST

- `map`
	- Dictionary
	- Insertion, deletion, searching 
- `lower_bound`, `upper_bound`
	- Find element in range

http://acm.timus.ru/problem.aspx?space=1&num=1613
http://poj.org/problem?id=2418

## Monotone Queue

- 3 basic operations
	- `push` in `O(1)`
	- `pop` in `O(1)`
	- `max`/`min` in `O(1)`
- Implementation

```
Insert(k):
	while (queue not empty) and (tail element >= k):
		discard tail
	append k to tail

Min():
	return head of queue
```

http://poj.org/problem?id=2823

## Block List

- Structure
	- Partition indices into `O(sqrt(n))` segments, each of length `O(sqrt(n))`
- 3 basic operations
	- `insert`
	- `delete`
	- Range operation on `[i,j]` in `O(sqrt(n))`
- Implementation

```
Insert(x):
	# invariant: each segment has elements >= L and < 3L; OR only one segment < 3L

	locate segment S # O(sqrt(n))
	brute force insertion on S # O(L)
	if size(S) == 3L:
		evenly split into 2 segments

Delete(x):
	locate segment S # O(sqrt(n))
	brute force deletion on S # O(L)
	if size(S) == L and S has adjacent segment:
		combine 2 segments
		evenly split into 2 segments

# range operation
# change & sum as example

## change [i,j] to x
Change(i, j, x):
	if i == l and j == r: # O(1)
		b = true
		y = x
		s = x * (r - l + 1)
	else: # O(L)
		if b == true:
			set every element in [l,r] to y
			b = false
		set every element in [i,j] to x
		calculate s

## query [i,j]
Query(i, j):
	if i == l and j == r: # O(1)
		return s
	else: # O(L)
		if b == ture:
			set every element in [l,r] to y
			b = false
		set every element in [i,j] to x
		calculate s
		return s
```

http://poj.org/problem?id=3580

## Merge-find Set

[Wiki](https://en.wikipedia.org/wiki/Disjoint-set_data_structure)

- Structure
	- A ground set `S`
	- A collection `C` of subsets of `S` where 2 different elements in `C` are disjoint
- 3 basic operations
	- `union`: union 2 subsets
	- `find`: find the subset a specific elememt is in
	- `test`: test where 2 elements are in the same subset
- Implementation (linear)

```
P: P[i] = parent of i in S
F(P): forest difined by P

Find(x):
	while P[x] != x:
		x = P[x]
	return x # root

Union(x):
	P[Find(x)] = Find(y)

Test(x, y):
	return Find(x) == Find(y)
```

- Implementation (optimized)

```
R: rank of element; init R = {0}

Find(x): # path compression
	if P[x] != x:
		P[x] = Find(P[x])
	return x

Union(x): # union by rank
	x' = Find(x)
	y' = Find(y)
	if R[x'] < R[y']:
		P[x'] = y'
	elif R[x'] > R[y']:
		P[y'] = x'
	else:
		P[x'] = y'
		R[y']++
```

### Extension 1: Maintaining the Difference

For each element `i`, `V[i]` is the underlying unknown integer. Information `V[j] - V[i] = k` comes.

- Problem
	1. Consistent with previously known information?
	2. If consistent, record the information
	3. `V[j] - V[i]` uniquely determined?
	4. If unique, answer the value
- Implementation

```
D: difference; D[i] = V[i] - V[P[i]]; init D = {0}

Find(x):
	if P[x] != x:
		(P[x],d) = Find(P[x])
		D[x] += d
	return (x, D[x])

Union(i, j, k): # V[i] - V[j] = k
	(x',D[i]) = Find(i)
	(y',D[j]) = Find(j)
	if R[x'] < R[y']:
		P[x'] = y'
		D[x'] = D[j] - D[i] - k
	elif R[x'] > R[y']:
		P[y'] = x'
		D[y'] = D[i] - D[j] - k
	else:
		P[x'] = y'
		D[x'] = D[j] - D[i] - k
		R[y']++r

```

- Apply the data structure

	- Provided `V[j] - V[i] = k`: `Union(i,j,k)`
	- Answer `V[j] - V[i]`: if `Test(i,j)` then `return D[j] - D[i]`  

http://acm.hdu.edu.cn/showproblem.php?pid=3038

### Extension 2: XOR

http://acm.hdu.edu.cn/showproblem.php?pid=3234
















