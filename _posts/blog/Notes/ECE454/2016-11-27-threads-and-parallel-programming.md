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
3. Data Parallelism
	1. Matrix Multiplication (Regular)
	2. SOR (Regular)
	3. Molecular Dynamics (Irregular)
4. Task Parallelism
	1. PIPE (Pipelines)
	2. TSP (Task Queue)

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

## Data Parallelism

Processors do the same thing on different data.  

- __Regular__: linear indexing
	- All arrays accessed through linear expressions of loop indices, known at compile time
- __Irregular__: non-linear indexing
	- Some arrays accessed through non-linear expressions of loop indices, some only known at runtime
	- Difficult for parallelism based on _data distribution_
	- Not difficult for parallelism based on _iteration distribution_

### Matrix Multiplication (Regular)

```
for (i = 0; i < n; i++) 
	for (j = 0; j < n; j++)
		c[i][j] = 0.0; 
for (i = 0; i < n; i++)
	for (j = 0; j < n; j++)
		for (k = 0; k < n; k++)
			c[i][j] += a[i][k] * b[k][j];
```

- No loop-carried dependences on i-/j- loop
	- Can run in parallel
- __Loop-carried dependence__ on k-loop
- Data Distribution
	- __Block distribution__
	- __Block distribution by row__
	- __Block distribution by column__
	- __Cyclic distrubution by column__
	- __Block cyclic__
	- __Combinations__

### SOR (Regular)

```
for some number of timesteps/iterations {
	for (i = 1; i < n; i++)
		for (j = 1; j < n; j++)
			temp[i][j] = 0.25 *
				(grid[i-1][j] + grid[i+1][j] + grid[i][j-1] + grid[i][j+1]);
	for (i = 1; i < n; i++)
		for (j = 1; j < n; j++)
			grid[i][j] = temp[i][j];
}
```

- No dependences between 1st `(i,j)` loop nest
	- Can run in parallel
- No dependences between 2nd `(i,j)` loop nest
	- Can run in parallel
- __Anti-dependence__ between 1st & 2nd loop nest in the same timestep
	- Fork-join
- __True-dependence__ between 2nd & 1st loop nest of next timestep
	- Fork-join

### Molecular Dynamics (Irregular)

```
for some number of timesteps { 
	for all molecules i
		for all nearby molecules j
			force[i] += f(loc[i], loc[j]);
	for all molecules i
		loc[i] = g(loc[i], force[i]);
}

for each molecule i
	number of nearby molecules count[i]
	array of indices of nearby molecules index[j] // 0 <= j < count[i]

for some number of timesteps { 
	for (i = 0; i < num_mol; i++)
		for (j = 0; j < count[i]; j++)
			force[i] += f(loc[i], loc[index[j]]);
	for (i = 0; i < num_mol; i++)
		loc[i] = g(loc[i], force[i]);
}
```

- No loop-carried dependences in 1st i-loop
	- Can run in parallel
	- May have __load balancing__ problem
- __Loop-carried dependence (reduction)__ on j-loop
- No loop-carried dependences in 2nd i-loop
	- Can run in parallel
- __True-dependence__ between 1st & 2nd i-loop
	- Fork-join between loops

## Task Parallelism

Processors do different tasks.

### PIPE (Pipelines)

1. Case 1

	```
	for (i =0 ; i < num_pic, read(in_pic[i]); i++) { 	
		int_pic_1[i] = trans1(in_pic[i]); 
		int_pic_2[i] = trans2(int_pic_1[i]); 
		int_pic_3[i] = trans3(int_pic_2[i]); 
		out_pic[i] = trans4(int_pic_3[i]);
	}
	```
	```
	// Assign each transformation to a processor
	// Processor 1
	for (i = 0; i < num_pics, read(in_pic[i]); i++) { 
		int_pic_1[i] = trans1(in_pic[i]); 
		signal(event_1_2[i]);
	}
	// Processor 2
	for (i = 0; i < num_pics; i++) {
		wait(event_1_2[i]);
		int_pic_2[i] = trans1(int_pic_1[i]);
		signal(event_2_3[i]);
	}
	// Processor 3
	...
	// Processor 4
	for (i = 0; i < num_pics; i++) {
		wait(event_3_4[i]);
		out_pic[i] = trans1(int_pic_3[i]); 
	}
	```
	- Problem
		- Each stage (transformation) may take different time to finish
		- Stages take a variable amount of time
	- Use __semaphore_wait/signal__ with `pthread`

2. Case 2

	```
	for (i =0 ; i < num_pic, read(in_pic[i]); i++) { 	
		int_pic_1 = trans1(in_pic); 
		int_pic_2 = trans2(int_pic_1); 
		int_pic_3 = trans3(int_pic_2); 
		out_pic = trans4(int_pic_3);
	}
	```
	- Anti-dependence between stages -> no parallelism
		- __Privatization__
		- __Buffer__ between stages; block when buffers are full/empty

### TSP (Task Queue)

```
init_q(); init_best();
while ((p = de_queue()) != NULL) {
	for each expansion by one city { 
		q = add_city(p);
		if (complete(q)) { update_best(q) } 
		else { en_queue(q) }
	}
}
```

Balance between __granularity for load balance__ and __overhead for synchronization__.

1. Each process one expansion
2. Each process do expansion of one partial path

	```
	en_queue()/de_queue() {
		pthreads_mutex_lock(&queue);
		...;
		pthreads_mutex_unlock(&queue);
	}
	update_best() {
		pthreads_mutex_lock(&best);
		...;
		pthreads_mutex_unlock(&best);
	}
	de_queue() {
		while ((q is empty) and (not done)) {
			waiting++;
			if (waiting == p) {
				done = true;
				pthreads_cond_broadcast(&empty, &queue);
			}
			else {
				pthreads_cond_wait(&empty, &queue);
				waiting--; 
			}
		}
		if (done) return null; 
		else remove and return head of the queue; 
	}
	```

3. Each process do expansion of multiple partial path

#### Busy Waiting

```
initially: flag = 0;
P1: produce data; flag = 1;
P2: while (!flag); consume data;
```

Used when __few threads competing for core__ or __short critical sections__.



















