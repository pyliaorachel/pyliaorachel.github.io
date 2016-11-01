---
layout: post
title:  "Memory Allocation"
categories: Blog Notes Optimization
tags: ["Optimization", "ECE454"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Dynamic Memory Allocation
	1. Memory Allocator
	2. Performance Goals
	3. Fragmentation
	4. Implementation
	5. Garbage Collection
2. Memory-Related Bugs

<!--more-->
---
## Dynamic Memory Allocation

### Memory Allocator

- __Explicit memory allocator__: `malloc` & `free`
- __Implicit memory allocator__: garbage collection
- Provides abstraction of memory as a set of blocks
- Constraints
	- Alignment
	- No compaction on allocated blocks
	- Only manipulate free memory
- Goal
	- Good time performance for `malloc` & `free`
	- Good space utilization
	- Good locality properties
		- Allocation close in time should be close in space

### Performance Goals

- __Throughput__: # of completed requests per unit time
- __Peak memory utilization__
	- Aggregate payload `Pk`
	- Current heap size `Hk`
	- Peak memory utilization `Uk = (max_i<k Pi) / Hk`

### Fragmentation

- __Internal fragmentation__
	- Depends on pattern of _previous_ requests
- __External fragmentation__
	- Depends on pattern of _future_ requests

### Implementation

```
| size | a | - header
| payload  |
| padding  |
| size | a | - footer
```

- Keep track of __size__
	- Overhead: size + allocated bit
- Keep track of __free blocks__
	1. Implicit list: length to link all blocks
	2. Explicit list: pointers to link free blocks
	3. Segregated free list
	4. Blocks sorted by size

#### Implicit List

- Placement policy
	- __First fit__
	- __Next fit__: fragmentation worse
	- __Best fit__: slower
- Coalescing policy
	- Join adjacent free blocks
	- __Immediate coalescing__
	- __Deferred coalescing__
		- Until `malloc` or external fragmentation reaches threshold

#### Explicit Free List

- Extra data space for link pointers
- Need boundary tags for coalescing
- Insertion policy
	- __LIFO__
	- __Address-ordered__

#### Segragated Free List

- Each size class  has own collection of blocks
	- Separate size class for small sizes
	- Typically size classes for power of 2

### Garbage Collection

#### Mark and Sweep Collecting

- __Mark__: scan over blocks, mark all reachable memory
- __Sweep__: scan over blocks, free blocks not marked

## Memory-Related Bugs

- Dereferencing bad pointers 
	- `scanf("%d", val)`
- Reading uninitialized memory 
- Overwriting memory
	- Allocating wrong sized object
	- Off-by-one error
	- Not checking max string size
	- Referencing a pointer instead of the object it points to: `*size--`
	- Pointer arithmetic: `p += sizeof(int)`
- Referencing nonexistent variables 
	- Return pointer to local variable
- Freeing blocks multiple times 
- Referencing freed blocks
- Failing to free blocks





