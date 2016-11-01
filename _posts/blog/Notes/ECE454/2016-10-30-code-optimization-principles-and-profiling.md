---
layout: post
title:  "Code Optimization Principles & Profiling"
categories: Blog Notes Optimization
tags: ["Optimization", "ECE454"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Measurements of Programs & Computers
	1. Measurements
	2. Amdahl's Law
	3. Tools for Measuring
2. Compiler Optimizations
	1. Common Compiler Optimizations
3. Basics of Computer Architecture
	1. Pipelines
	2. Branch Prediction
	3. Out-of-Order Execution
	4. Superscalar & Simultaneous Multithreading(SMT)/Hyperthreading

<!--more-->
---
## Measurements of Programs & Computers

### Measurements

- __IPS__: instructions per second
- __FLOPS__: floating point operations per second
- __IPC__: instructions per cycle
- __CPI__: cycles per instruction

### Amdahl's Law

- `speedup = OldTime/NewTime`
- `NewTime = OldTime x [(1 - f) + f/s]`  
  `speedup = 1 / (1 - f + f/s)`
	- `f` = fraction of execution time the optimization applies to
	- `s` = improvement factor

### Tools for Measuring

- __S/W timers__
	- C library: `<sys/times.h>`
	- OS-level timers: `/usr/bin/time`
- __H/W timers & performance counters__
	- Built into processor chip: low-level architecture events e.g. cache misses, branch mispredictions, ...
	- S/W packages to make them easier to use: `perf`
- __Instrumentation__
	- Self implemented codes
	- __gprof__
		- Periodically interrupt program
		- Measure _time spent_ & _# of calls made_ in each function
	- __gcov__
		- Profile of execution within a function e.g. # of times each line of code was executed, which loops/conditional statements are important
	- Disturbing the system slows down execution
	- Comparison
	|    | gprof | gcov |
	|:---|:------|:-----|
	| Compile | faster (insert counter func for each function) | slower (insert counter func for each line) |
	| Size | smaller | bigger |
	| Runtime | slower (frequent interrupts) | faster |

## Compiler Optimizations

- Preserve correctness
- Improve performance
	- Fewer CPI
		- Schedule instructions
		- Improve cache/memory behavior
	- Fewer instructions
- Worth the effort

```
---> Front End ---> Optimizer ---> Code Generator --->
 HLL			IR			   IR				  LLL
```

- Limitations
	- Cannot change program behavior
	- Inter-procedural analysis too expensive -> most analysis performed within procedures
	- Hard to anticipate run-time inputs -> most analysis based on static information
	- Must be conservative
- Programmers should:
	- Select best algorithm
	- Write readable & maintainable code
	- __Eliminate optimization blockers__
		- Memory aliasing
			- 2 different memory references specify single location
		- Pocedural side-effects

### Common Compiler Optimizations

- Machine independent
	- Constant propagation
	- Constant folding
	- Common subexpression elimination
	- Dead code elimination
	- Loop invariant code motion
	- Function inlining
		- Space-speed tradeoff
		- Overloading issue
	- Reduction in strength: replace costly operation with simpler one
		- Shifting (machine-dependent)
		- Make use of registers
	- Direct access
		- Avoid bound checking
- Machine dependent
	- Instruction scheduling
	- Loop unrolling
		- Enables more aggressive instruction scheduling
	- Parallel unrolling

## Basics of Computer Architecture

- RISC: simpler instructions -> __pipeline__
- 64-bit: larger databases, counter not overflowing, better math performance -> code size increases

### Pipelines

- Important factors
	- Branch prediction
	- Data dependency
- Pipeline deeper -> misprediction penalty larger
- Multiple instruction issue: flushing & refetching more instructions
- OOP: More indirect branches to be predicted

### Branch Prediction

- Predict future based on history
- Global predictor: predict based on _global_ & _local_ history
	- __(m, n) prediction__: m-bit global x n-bit local

### Out-of-Order Execution

- Solve __data dependency__
- Mask __cache miss delay__

### Superscalar & Simultaneous Multithreading(SMT)/Hyperthreading

```
	1				1 2				1 2 6
	2				3 4 5			3 4 5	
	3				6				7 8
	4				7 8				9
	5				9
	6
	7
	8
	9
single-issue	 superscalar	out-of-order superscalar

	1	1'			1 2 6			1 2 1'
	2	2'			3 4 5			2'6 6'
	3	3'			7 8				3'3 5
	4	4'			9				4 4'5'
	5	5'			1'2'6'			7 8 7'
	6	6'			3'4'5'			9 8'
	7	7'			7'8'			9'
	8	8'			9'
	9	9'
2 applications		fast 		hyperthreading
				context switching
```

















