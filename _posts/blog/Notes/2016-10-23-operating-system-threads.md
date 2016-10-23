---
layout: post
title:  "Operating System - Threads"
categories: Blog Notes OS
tags: ["OS", "ECE344", "threads"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Threads and Processes
2. Thread Scheduling

<!--more-->
---
## Threads and Processes

- When a __program__ runs, it is called a `process`
- OS maintains states for each abstraction:
	- __Thread(CPU) state__
		- Registers, PC, SP, ...
	- __Address Space (memory) state__
		- Program instructions, static & dynamic data, ...
	- __Device & other state__
		- Open files, network connection state, ...

### __Threads__

- Abstraction of __virtualizing CPU__
	- Each `thread` thinks it has its own set of `CPU registers`
- # of `threads` arbitrary; # of `CPUs` fixed
- Enables __concurrency__
	- Running multiple programs concurrently
	- Running multiple tasks concurrently
		- Hiding I/O latency
			- Can use `non-blocking file I/O` (`event-driven`), but harder to get right because need to build a state machine
			- ~ `interrupts`
		- Run truly in parallel with multiple `CPUs` via `multiplexing`

- __Threads v.s. Functions__

	| Threads | Functions |
	|:--------|:----------|
	| Independent streams of execution, one thread no need to run to the end before switching | LIFO policy, functions runs untill the end |
	| Thread scheduler multiplexes the threads on CPU | One function calls another function |
	| Each thread has its own stack, calling its own set of functions | Running on a single stack |
	| Runs in parallel with multiprocessors | Cannot run in parallel with multiprocessors because functions stack together |

### __Address Space__

- Abstraction of __virtualizing memory__
	- A set of _virtual memory regions_ accessible to a program
		- `Text`: program code
		- `Data`, `Heap`: static, dynamic variables
		- `Stack`: for function & system calls
- Provides __memory protection__
- Address space (order may vary with different H/W & compiler environment)

	```
			+++++++++++++++ ----
			|	 param	  |	 |
			+++++++++++++++  |
			|   ret val   |	 |
			+++++++++++++++	 |
			|   ret addr  |	 |	activation frame
			+++++++++++++++	 |	for current function
	  fp ->	|   prev fp   |	 |
			+++++++++++++++	 |
			|  other regs |	 |
			+++++++++++++++	 |
	  sp ->	|  local var  |	 |		# function call:
			+++++++++++++++ ----	# push %rbp; save old fp
			|  	   ↓      |         # mov %rbp %rsp; init sp to fp
			|  	          |			# retq; call *sp
			|  	   ↑      |
			+++++++++++++++			# return:
			|	 data	  |			# add $24 %rsp; pop off stack
			+++++++++++++++			# pop %rbp; fp=*sp (or *fp), sp++
			|	 text	  |			# retq; call *sp
			+++++++++++++++
	```

### __Processes__

- A running program consistes of >= 1 processes
	- Traditionally:
		- `process = addr space + thread`
		- `Threads` communicate using `system calls`
	- Today:
		- `process = addr space + >= 1 threads`
		- `Threads` share `addr space` (but not `stack`)
		- `Threads` communicate with `reading/writing memory`
- Speed up cases analysis:

	```
	# Vector operation
	for (k = 0; k < n; k++)
		a[k] = b[k]*c[k] + d[k]*e[k];
	```

	- Multiple processes?
		- Communicate with `system call`...
	- Multiple threads?
		- Must make it global to share data
	- On single processor?
		- Threads go one after another
	- On multiprocessor?
		- O

	```
	# Web server
	Loop:
		1. get network message from client -> I/O
		2. get URL data form disk, cache in memory -> I/O
		3. compose response
		4. send response -> I/O
	```

	- Multiple processes?
		- Cannot share the cache (stored in global resource area of that process)
	- Multiple threads?
		- O
	- On single processor?
		- O
	- On multiprocessor?
		- O
- __Threads v.s. Processes__

	|   | Threads | Processes |
	|:--|:--------|:----------|
	| Memory needed| Shared, less | Not shared, more |
	| Communication & Synchronization | Via __shared vars__, faster | Via __system calls__, slower |
	| Switching | Save & restore regs, faster | Change MMU's regs (e.g. base & limit), slower |
	| Robustness | Memory sharing -> bugs | Communication explicit -> robust |

- __Program v.s. Process__
	- __Program__: a set of instructions & data
	- __Process__: a program loaded in memory and executing

### __OS-Level Process State__

- OS keeps state for each process: `process state`, `process control block (PCB)`
	- __Thread state__
		- `Processor regs` for resuming/suspending thread
		- `Thread id`
		- Various `parameters` e.g. scheduling parameters
	- __Address space state__
		- Location of `text`, `data`, `stack`
		- `MMU virtual memory state` i.e. virtual -> physical mapping
	- __Device related state__
		- Open files, network connections
	- __Other states__
		- Terminal state, pending signals, timers, swap, ...

---
## Thread Scheduling

- `Thread`: an independent stream of instructions
	- Which to choose?
	- When to switch?
	- How to switch?
- `Thread scheduling`: running threads in some order
	- `Thread state`
		- `Running`
		- `Ready`
		- `Blocked`
		- `Exited` (not yet destroyed)
	- `Scheduling policies` to change states
- `Thread scheduling functions`
	- `thread_yield`
		- `Running -> Ready`
	- `thread_sleep`
		- `Running -> Blocked`
	- `thread_wakeup`
		- `Blocked -> Ready`
- `Preemptive scheduling`
	- `Scheduler` uses `timer interrupt` to control threads
	- `Interrupt handler` calls yield on behalf of running thread
		- Normally `interrupt handler` returns to original call; here, it calls `thread_yield()` instead
- Scheduler implementation
	- Thread structures maintained in `queues`
		- `Ready queue`
			- Generally 1 per CPU
		- `Wait queue`
			- Separate `wait queues` for each type of event e.g. disk, console, timer, network, ...
			- Generally shared by CPUs
		- `Exited queue`
			- Generally shared by CPUs
	- `Scheduling functions` move `threads` between `queues`

### __Thread & Context Switch__

- `context switch` (`process switch`) = `thread switch` + `address space switch`
	- `Address space switch`
		- Updating `MMU's` registers
		- More expensive than `thread switch`
	- `Context switch` v.s. `Mode switch`
		- Unrelated; the former switch threads, the latter switch CPU modes

- Functions
	- `thread_yield`

		```
		thread_yield() {
			enqueue_ready_queue(current)
			next = choose_next_thread()
			thread_switch(current, next)
		}
		thread_switch(current, next) {
			save_processor_state(current->cpu_regs)
			...
			restore_processor_state(next->cpu_regs)
		}
		```
	- `thread_init`
		- Create the first (main) thread
	- `thread_create`
		- Allocate thread struct, stack memory, init PC, SP
		- Add to ready queue

### __Thread Creation & Termination__

- Functions
	- `thread_exit`
		- Does not destroy itself; switch to another thread and it will destroy this thread
	- `thread_destroy`
		- Actually destroy thread structure & stack of exited threads

### __Kernel Threads v.s. User Threads__

|   | Kernel Threads | User Threads |
|:--|:--------------|:------------|
| Implementation scope| Implemented in kernel | Implemented in user program |
| Virtualization| Virtualize CPU | Virtualize kernel thread |
| Switching cost| Must run kernel code, expensive | ~procedure calls, less expensive |
| Scheduling policy | Fixed | Custom definition |
| Blocking system calls | Switch to another kernel thread | All threads (associated with the same kernel thread) block -> overlap of I/O & computations impossible |
| Multiprocessors | Threads use multiple CPUs concurrently | Cannot use multiple CPUs consurrently|

- `Kernel level scheduler` doesn't know about `user threads`

---
## __Quick Questions__
1. Is the OS code run in a separate process? A separate thread? Does it need a process structure?
	- OS code runs when a process makes a system call or when an interrupt occurs. In either case, the OS generally runs in the thread and address space context of the user process, and hence it does not require its own process or thread state.
2. What is the address space of an OS?
	- The entire physical memory























