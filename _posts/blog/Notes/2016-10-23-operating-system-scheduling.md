---
layout: post
title:  "Operating System - Scheduling"
categories: Blog Notes OS
tags: ["OS", "ECE344", "scheduling"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Scheduling Overview
2. Scheduling Policies
3. Multiprocessor Scheduling

<!--more-->
---
## Scheduling Overview

- Prevent `thread starvation`, BUT `context switching` is expensive
- Runs another program when I/O performed
- Goals
	- __Batch systems__: Long running, no interactive users, no time constraints
		- `CPU utilization`
			- % of time CPU is busy
		- `Throughput`
			- # of programs complete per unit time
		- `Turnaround time`
			- Total time to finish a program
			- `turnaround = processing + waiting`
	- __Interactive (general-purpose) systems__: Short running, interactive suers, weak time constraints
		- `Response time`
			- Time between _receiving request_ & starting to _produce output_

## Scheduling Policies

- __Batch systems__
	- Policies
		- `FIFO` (non-preemptive)
			- In order of arrival time
			- Run thread until completion
		- `Shortest job first` (non-preemptive)
			- In order of shortest running time
			- Run thread until completion
			- Starving long jobs
		- `Shortest remaining time` (preemptive)
			- In order of shortest remaining time
			- Run thread until completion OR another thread arrives
			- Preemptive version of `shortest job first`
			- Starving long jobs
			- Optimal w.r.t. avg waiting time
	- Properties
		- Some require estimate of preocessing time
		- May starve long running threads
		- Long response time
- __Interactive systems__
	- Policies
		- `Round-Robin`
			- Preemptive version of `FIFO`
			- `Time slice`
				- Upper time bound each process runs 
				- `time slice >> context switch time`
				- `cs overhead = cs/(ts+cs)`
			- Run thread until `time slice` interrupt OR thread blocks
			- Effectiveness:
				- # of threads
				- Size of `time slice`  
					__Long__ -> slow response  
					__Short__ -> high overhead
			- Does not require estimation of job processing time; no starvation; enables interactivity by limiting the amount of time each thread can run
		- `Static priority`
			- In order of priority assigned
			- Starving low prioriy threads
			- _Priiority inversion_: low priority threads holding locks that high priority threads want
		- `Multi-level queue`
			- High, medium, & low PQs
			- Choose from high-priority PQ first (e.g. I/O threads)
			- For each queue, `round-robin` scheduling
		- `Dynamic priority (feedback)`
			- Priority changed based on thread behavior; CPU-bound threads have priority reduced
- `Feedback scheduling`
	- Goals
		- Allocate CPU fairly
		- I/O-bound threads receive higher priority
	- Each thread:
		- CPU usage (C)
		- Current priority (Pi)
		- Initial priority (P0)
		- Nice value (N)
	- Steps
		1. Scheduler chooses thread with the __smallest__ Pi
		2. On timer interrupt, update CPU C of running thread `C = C + 1`
		3. Every time slice, update Pi `Pi = Pi-1/2 + C + N`
		4. Reset C for all threads
	- `Time slice`
		- Many interrupts in between `time slice` to avoid excessive `context switches`
		- A `thread` runs for a full `time slice` unless:
			- The `thread` blocks
			- Some blocked `thread` wakesup
		- Longer `time slice` improves throughput

## Multiprocessor Scheduling

- Asymetric multiprocessing
	- 1 processor runs all OS code, I/O processing code, etc.
	- Others run user code
	- Simple implementation
- Symmetric multiprocessing (SMP)
	- All processors fun OS & user code
	- Efficient
	- Difficult implementation
	- Scheduling issues
		- __Processor affinity__
			- Cache issue, want to ensure `threads` run on the same `thread` before
			- `Hard affinity`: a `thread` specifies which processor it wants to use
		- __Load balancing__
			- Single ready queue: easy BUT tends to bottleneck because each processor needs a spinlock for ready queue
			- 1 ready queue per processor: scalable BUT _task migration_ & _load balancing_ tricky  
				- _task migration_  -  
					Deadlock?
				- _load balancing_  -  
					`Push migration`: thread find less-busy processors  
					`Pull migration`: idle processor find thread on busy processors
















