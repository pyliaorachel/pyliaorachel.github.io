---
layout: post
title:  "Memory Optimization"
categories: Blog Notes Optimization
tags: ["Optimization", "ECE454"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Data Representation & Alignment
2. Cache Performance
	1. Cache Organization
	2. Cache Performance Metrics
	3. Code Scheduling
	4. Blocking/Tiling
	5. The Memory Moutain
3. Virtual Memory
	1. Virtual Memory Access
	2. Page Table & TLB
4. Prefetching
	1. H/W Prefetching
	2. S/W Prefetching
5. Machine-Dependent Optimizations
	1. Pointer Code
	2. Instruction-Level Parallelism
	3. Parallel Loop Unrolling

<!--more-->
---
## Data Representation & Alignment

- Primitive data type requires K bytes -> address must be multiple of K
- Structures align with the _largest alignment requirement of any element_

## Cache Performance

- Keep working set small (temporal locality)
- Use small strides (spacial locality)

### Cache Organization

```
address: | tag | index | offset |
cache block: | v | tag | data |
S - 2^s sets
E - 2^e blocks/lines per set
B - 2^b bytes per cache block

Cach size = S * E * B bytes
```
### Cache Performance Metrics

- Miss rate
- Hit time
	- isLineInCache? + deliver block to CPU (+virtual memory translation)
- Miss penalty

### Code Scheduling

- Factors
	- Reordering of loops
	- # of read/write operations

### Blocking/Tiling

- Traverse array in blocks
- Imporves __temporal locality__

### The Memory Moutain

- Measure __read throughput__ as a function of __spatial & temporal locality__

![Memory Mountain](http://cfile22.uf.tistory.com/image/112730164AC0AFAB36962C)

## Virtual Memory

- Why virtual memory?
	- Capacity/Portability
	- Security
	- Sharing

### Virtual Memory Access

- Type of cache misses
	- Cold/compulsory miss
	- Conflict miss
		- Avoided by _set-associative caches_
	- Capacity miss *
		- Keep working set within on-chip cache capacity
- Write
	- Write-back (on write-hit)
	- Write-allocate (on write-miss)
	- Write-through

### Page Table & TLB

- MMU keep mapping of VA to PA in __page table__
	- Page table kept in main memory, can be cached
- __Translation lookaside buffer (TLB)__: cache for page table
	- TLB hit: `CPU -> MMU -> TLB -> MMU -> Mem`
	- TLB miss: `CPU -> MMU -> TLB -> Mem -> TLB -> MMU -> Mem`
	- TLB reach: `(# TLB entries) * (page size)`
- __Working set__ : a set of active virtual pages
	- Page miss: `(working set size) > (main mem size)` -> __thrashing__
	- TLB miss: `(# working set pages) > (# TLB entries)`

## Prefetching

- Bring into cache elements expected to be accessed in future
- Effective is:
	- Spare memory bandwidth
	- Accurate
	- Timely
	- Doesn't displace other in-use data
	- Latency hidden by prefetched outweighs their cost

### H/W Prefetching

- Prefetch adjacent block
- Recognize a _stream_: addresses separated by a _stride_
- Prefetch within a page boundary

### S/W Prefetching

- Insert special `prefetch` instructions into code
	- Patterns that H/W wouldn't recognize e.g. linked list

## Machine-Dependent Optimizations

### Pointer Code

- Not necessarily better than array code; some compilers do better job optimizing array code

### Instruction-Level Parallelism

- Limiting factor
	- Latency of instructions
	- # of functional units available
		- 1 load
		- 1 store
		- 2 int (1 may be branch)
		- 1 FP add
		- 1 FP mul/div

### Parallel Loop Unrolling

1. Accumulate in 2 different products, combine at end
	- `(1 * x2 * ... * xn) * (1 * x1 * ... * x_n-1)`
2. Dual product 
	- `(1 * x1) * (x2 * x3) * ... * (x_n-1 * xn)`

- Limitations
	- Need lots of registers to hold sums/products








