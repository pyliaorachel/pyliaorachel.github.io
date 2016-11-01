---
layout: post
title:  "Threads & Parallel Programming"
categories: Blog Notes Optimization
tags: ["Optimization", "ECE454"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Parallelism Overview
	1. Standard Models of Parallelism
	2. Speedup
	3. Dependence
2. Threads & Processes
	1. Pthreads
	2. Synchronization

<!--more-->
---
## Parallelism Overview

### Standard Models of Parallelism

- Shared memory (pthreads)
- Shared memory + data parallelism (OpenMP)
- Message passing (MPI)
- Transactional memory (TM)

### Speedup

- `speedup on problem = sequential execution time of best known sequential algorithm / execution time on p processors`
	- Avoids picking easily parallelizable algorithm with poor sequential execution time
- Linear speedup is best to be achieved
	- Sub-linear speedup: due to overhead of _startup_, _synchronization_, _communication_, ...
	- Super-linear speedup
		- Cache/memory effects
		- Nondeterminism in search problems
- __Amdahl's Law__: if `1/s` of program is sequential, speedup will not be better than `s`

### Dependence

- __True dependence__
	- `S2` reads a value written by `S1`
- __Anti dependence__
	- `S2` writes a value read by `S1`
- __Output dependence__
	- `S2` writes a value written by `S1`
- __Loop carried dependence__
	- Statements are part of the execution of a loop
	- e.g. `a[i] = f(a[i-1]) + 1;`
	- Prevents loop iteration parallelization
	- Level of loop carried dependence: nesting depth of loop that carries dependence
	- <-> __Loop independent dependence__

## Threads & Processes

- Similarities
	- Own logical control flow
	- Run concurrently with others
- Differences
	- Threads share code & data, processes don't
	- Process control & context switches more expensive than thread control & thread switches

### Pthreads

- User has to:
	- Decompose computation into parallel parts
	- Create/destroy threads
	- Add synchronization to ensure dependences covered
- Functions
	- `pthread_create()`
	- `pthread_exit()`
	- `pthread_join()`

### Synchronization

#### Parallelization Options

- __Course-grained locking__: 1 big lock for critical section
	- Limited parallelism
	- Easy to implement
- __Fine-grained locking__: 1 lock per variable used in critical section
	- Good parallelism: less dependencies
	- Hard to implement
		- Deadlock, fault tolerance, priority inversion, ...
- __Semaphores__
- __Fork-Join__
- __Barriers__
- __Reductions__
















