---
layout: post
title:  "Competition Cheatsheet"
categories: Blog Notes Competition
tags: ["competition"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

Cheatsheet for coding competitions.

<!--more-->
---
## Complexity Limit

### TLE

`10^8` int operations/`10^7` floating point operations in a for loop run in around __1 sec__.

- n = 20: exponential ok
- n = 100: `O(n^3)` ok
- n = 1000: `O(n^2)` ok
- n = 10^4: `n*polylog(n)` ^ `n*sqrt(n)` ok
- n = 10^5: `nlogn` ok
- n = 10^6: `O(n)` ok
- n = 10^9: `O(logn)` ok

## STL

- `vector` in `<vector>`
- `priority_queue` in `<queue>`
- `sort` in `<algorithm>`
- `binary_search` in `<algorithm>`
- `next_permutation` in `<algorithm>`
- `lower_bound`, `upper_bound` in `<algorithm>`
- `set`, `multiset` in `<set>`
- `map`, `multimap` in `<map>`




















