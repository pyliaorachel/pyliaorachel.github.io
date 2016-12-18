---
layout: post
title:  "Threads & Parallel Programming II"
categories: Blog Notes Optimization
tags: ["Optimization", "ECE454"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Locking Parallelization Options
2. Basic Parallel Improvements
	1. OpenMP & Code Restructuring Optimizations
	2. Characteristics of Parallel Code

<!--more-->
---
## Locking Parallelization Options

- Course-grained locking: easy to program; limited parallelism
- Fine-grained locking: hard to program; good parallelism
	- Deadlock, fault tolerance, priority inversion, etc.
- Transactional memory: easy to program, promise good parallelism
	- Checkpoints execution -> detects conflicts -> commits/aborts and reexecutes
	- Machine limits: abort if transaction too long and has to evict L1 cahce
	- Overhead
	- Bookkeeping
	- Failure recovery

## Basic Parallel Improvements

### OpenMP & Code Restructuring Optimizations

Compiler & library implementation.  

```
annotated source -> OpenMP compiler -> sequential program
										(compiler switch)
									-> parallel program
```

#### OpenMP Directives

- Parallelization directives
	- `#pragma omp parallel for` 
	- `#pragma omp parallel for schedule <block/cyclic>` 
- Data environment directives
	- `shared`, `private`, `threadprivate`, `reduction`

#### Code Restructuring Optimizations

Eliminate/reduce dependences by restructuring the code.

- Private variables

	```
	#pragma omp parallel for private(tmp)
	for (i = 0; i < n; i++) { 
		tmp = a[i];
		a[i] = b[i];
		b[i] = tmp;
	}
	```

- Induction variable elimination
	
	```
	for (i = 0, index = 0; i < n; i++) { 
		index += i;
		a[i] = b[index];
	}

	->
	#pragma omp parallel for
	for (i = 0, index = 0; i < n; i++) { 
		a[i] = b[i*(i+1)/2];
	}
	```

- Loop splitting

	```
	for (i = 0, index = 0; i < n; i++) { 
		index += f(i);
		b[i] = g(a[index]);
	}

	->
	for (i = 0; i < n; i++) { 
		index[i] += f(i);
	}
	#pragma omp parallel for
	for (i = 0; i < n; i++) { 
		b[i] = g(a[index[i]]);
	}
	```
	```
	while (*a) { 
		process(a); 
		a++;
	}

	->
	for (count = 0, p = a; p != NULL; count++, p++);
	#pragma omp parallel for
	for (i = 0; i < count; i++) 
		process(a[i]);
	```
- Loop reordering

	```
	for (k = 0; k < n; k++) 
		for (i = 0; i < n; i++)
			for (j = 0; j < n; j++)
				a[i][j] += b[i][k] + c[k][j];

	->
	#pragma omp parallel for 
	for (i = 0; i < n; i++)
		for (j = 0; j < n; j++)
			for (k = 0; k < n; k++)
				a[i][j] += b[i][k] + c[k][j];
	```

- Loop Fusion: reduce loop startup & thread overhead

	```
	#pragma omp parallel for
	for (i = 0; i < n; i++) 
		a[i] = b[i];
	#pragma omp parallel for
	for (i = 0; i < n; i++) 
		c[i] = b[i]^2;

	->
	#pragma omp parallel for
	for (i = 0; i < n; i++) {
		a[i] = b[i];
		c[i] = b[i]^2;
	}
	```

- Loop peeling

	```
	for (i = 0, wrap = n; i < n; i++) { 
		b[i] = a[i] + a[wrap]; 
		wrap = i;
	}

	->
	b[0] = a[0] + a[n];
	#pragma omp parallel for 
	for (i = 1; i < n; i++) {
		b[i] = a[i] + a[i-1]; 
	}
	```
	```
	for (i = 0; i < n; i++) 
		a[i+m] = a[i] + b[i];

	->
	if (m > n) {
		#pragma omp parallel for 
		for (i = 0; i < n; i++)
			a[i+m] = a[i] + b[i]; 
	} else {
		... cannot be parallelized
	}
	```

### Characteristics of Parallel Code

- Granularity
- Load balance
- Locality
- Communication & synchronization

#### Granularity 

Size of program unit executed by a single processor.  

- Fine granularity
	- Ability to use many processors
	- Finer-grain load balancing
	- Increased overhead
	- More critical section accesses & contention

#### Load balance

Different in execution time between processors between barriers.  

- Execution time predictable?
	- Regular data parallel: yes
	- Irregular data paralle or pipeline: perhaps
	- Task queue: no
- __Static load balancing__: done once by programmer
	- __Block__: good locality, poor load balance
	- __Cyclic__: good load balance, poor locality
	- __Block-cyclic__
	- Fine for regular data parallel
- __Dynamic load balancing__: done at runtime; task queue
	- __Centralized__: easy to program, good load balance
	- __Distributed__: less communication/synchronization; more memory & larger working set
	- __Task stealing__: extra overhead, difficult to program, better load balance
	- Unpredictable execution times
	- Regular data parallel in heterogeneous/multitasked environment
	- Usually high overhead
- __Semi-static load balancing__: done once at runtime
	- Partition computation using measurements of cost of program parts
	- Done once, done every iteration, done every n iterations





















