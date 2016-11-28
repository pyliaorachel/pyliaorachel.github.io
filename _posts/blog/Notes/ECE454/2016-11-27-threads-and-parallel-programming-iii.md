---
layout: post
title:  "Threads & Parallel Programming III"
categories: Blog Notes Optimization
tags: ["Optimization", "ECE454"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Big Picture of Architecture & Memory Access
	1. Virtual Memory
		- Memory Access
	2. Multithreading Basics
		- Parallelism within Processor
	3. Connection between Memory Access, Memory Allocation and Cache Efficiency
2. Cache Coherence
	1. Cache Coherence Overview
	2. CC Protocols
	3. Locality in Parallel Programming
	4. True & False Sharing

<!--more-->
---
## Big Picture of Architecture & Memory Access

### Virtual Memory

- __Protection__: each process has its own private memory space
- __Sharing__: processes can share physical memory frames
- __Hide fragmentation__: can run if not enough total/contiguous memory

#### Memory Access

![memory access](http://wdxtub.com/images/14583140218329.jpg)

1. Processor sends VA to MMU
2. MMU fetches PTE from PT in memory
3. PTE absent, MMU triggers _page fault exception_
4. Handler identifies victim page (if dirty, page it out to disk)
5. Handler pages in new page; update PTE
6. Handler returns to original process; restart faulting instruction

### Multithreading Basics

![thread x throughput](https://docs.adobe.com/content/docs/en/aem/6-0/manage/capacity-guide/capacity-guide/_jcr_content/par/image_7.img.png/1346079308000.png)

`linear increase -> increase slowdown -> degrade`

#### Parallelism within Processor

- Example
	`x = x * (data[i] * data[i+1])`
- Limitations
	- # of functional units
	- Latency of operation causing dependency
	- # of registers to hold temporaries

### Connection between Memory Access, Memory Allocation and Cache Efficiency

- Dynamic memory allocation
	- Space utilization
	- Time complexity on malloc/free
	- __Memory-wall__: growing desparity of CPU & RAM speeds	
		- Caching effectiveness important
		- Padding not cache-friendly: avoid internal fragmentation
- __False sharing__: occurs when >= 2 processors access different data in _same cache line_, and at least one of them writes
	- __Memory arenas__: 1 thread only use memory from a single arena (continuous blocks of memory)

## Cache Coherence

### Cache Coherence Overview

- Shared memory machines
	- Small # of processors: shared memory with coherent caches (SMP)
	- Large # of processors: distributed shared memory with coherent caches (CC-NUMA)
- Caches in multiprocessors
	- Same line appears in >= 2 caches, one write, others read

### CC Protocols

#### MSI Protocol

```
# Input/Action
				PrWr/BuRdX
	⬈-----------------------------------⬊
	  PrRd/BuRd		PrRd/-	PrWr/BuRdX
I ------------------> S ------------------> M
  <------------------   <------------------
  	  BuRdX/-		BuRd/-	BuRd/Flush
	⬉-----------------------------------⬋
				BuRdX/Flush
```

- Assumption: bus based architecture
	- Bus is reliable, ordered broadcast bus (snooping bus)
- States of a cache line
	- __Invalid__
	- __Shared__: one of many cached copies
	- __Modified__: sole valid copy
- Processor events
	- __PrRd__
	- __PrWr__
- Bus Transactions
	- __BusRd__: simply asks for copy
	- __BusRdX__: asks for copy to modify
	- __Flush__: updates memory
- Actions
	- Update state, perform bus transaction, flush value onto bus
- Problem
	- Reading & modifying data is 2 bus xactions (BusRd(I->S) + BusRdX)
	- A write to _shared__ will generate invalidation request

#### MESI Protocol

- One more state
	- __Exclusive/Exclusive-clean__: only this cache has copy but not modified
	- A write to _exclusive__ will not generate invalidation request
- Typically built on write-back caches

### Locality in Parallel Programming

- Cache-aware access
	- Cache invalidation traffic important
- Awareness of data placement in memory
	- Important for CC-NUMA because long memory latencies for non-local memory access
- Awareness of data assignment to threads when load balancing

```
for (i = 0; i < n; i++) 
	a[i] = i;
#pragma omp parallel for
for (i = 0; i < n; i++)
	b[i] = f(a[i-1], a[i]);

-> better locality
#pragma omp parallel for
for (i = 0; i < n; i++) 
	a[i] = i;
#pragma omp parallel for
for (i = 0; i < n; i++)
	b[i] = f(a[i-1], a[i]);
```

### True & False Sharing

- __True sharing__: 2 threads accessing __same__ locations on one block
- __False sharing__: 2 threads accessing __distinct__ locations on one block
	- Block will ping-pong
		- Ensure they map to separate cache blocks e.g. insert padding
	- Example

		```
		# processor = 2, cache line fit 8 elements
		#pragma omp parallel for schedule(cyclic) 
		for (i = 0; i < n; i++)
			a[i] = b[i];
		```










