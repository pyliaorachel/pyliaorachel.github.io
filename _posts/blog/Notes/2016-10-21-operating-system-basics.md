---
layout: post
title:  "Operating System - Basics"
categories: Blog Notes OS
tags: ["OS", "ECE344"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Basics of OS
2. OS Design
3. Hardware

<!--more-->
---
## Basics of OS

- Layer of `software` between `hardware & applications`
	- Application dedicated to a single task; OS serves all applications
	- Also called `systems software`

### __What OS does__

- Manage H/W resources
	- Allows programs to interact with H/W
		- CPU, memory, disk, graphics card, co-processors, ...
		- Simpler interface to devices
			- e.g. access disk as files
			- _If NOT, apps have to be written to specific H/W devices directly -> deal with all the specific H/W stuffs -> not compatible to another manufacturer's device_
	- Allows running many programs at the same time
		- Programs share CPU, memory
		- Isolates apps from each other
			- _If NOT, then memory corruption a problem_
		- Isolates itself from apps
			- _If NOT, then OS has to compromise for apps; apps may corrupt OS and no isolations provided to them_

## OS Design

### Key Ideas

- How does OS allow running many programs?
	- `Virtualization` - programs share resources securely
- How does OS allow programs to interact with H/W?
	- `Abstraction` for H/W
	- Implemented via `System calls`

### __Virtualization__

- Programs think:
	- They are running on their own machine (but only one physical machine!)
	- They have full access to CPU, memory, disk
- Benefits
	- `Resource isolation` (an ideal virtual machine)
		- Program cannot accidentally overwrite others' memory or files
		- Ideally, if a program uses too much memory, only its performance degrades
	- Improves __portablity__ of programs
- An ideal virtual machine ~ physical machine, i.e. programs won't affect each other
- Implementation
	- __Processor -> Threads__
	- __Memory -> Virtual Memory__
		- Contiguous & private memory
		- Illusion of access to large amount of memory
	- __Disk -> Files__
	- __Network -> Sockets__
		- Hides details of network protocols & layers

### __Abstraction__

- Eases programming, improves __portability__

#### Concurrency

- `Thread abstraction` allows program to concurrently perform several tasks
	- _Race condition?_

#### System Calls

- Program request H/W access via `system calls`
- `OS API`: a set of system calls
- Requires control transfer from `user space` to `kernel space` via `interrupts` or `traps`
- e.g.
	- Create/destroy process (_process-related system calls_)
	- Allocate/deallocate memory from system (_memory-related system calls_)
	- Read/write a file
- Ex.

	```
		Program | Library
		-----------------
			OS Kernel 							# program read() 
		----------------- 						# -> library generates trap 
			   H/W 								# -> trap invokes kernel 
			   									# -> kernel accesses disk 
		Program (read) -> library 				# -> kernel returns results to program
		------------------(trap)--^----					
			OS Kernel		 |    |
		---------------------v-(result)
			   		H/W 			
	```

#### OS Interface

- `OS interface` to H/W = set of __system calls__
- `VM interface` to H/W = subset of physical machine interface + OS interface

```
	* Application Layer

	* OS Interface 
(system calls: thread_create(), read(), write(), thread_join(), ...)

	(when program needs access to devices)
------------virtual machine interface--------
	* OS Kernel 							|
(thread scheduler, memory mgmt, 			|
device mgmt, file sys, network comm, 		|
protection, process mgmt, security, ...)	|	(when program runs most instructions)
											|
-----------physical machine interface---------virtual/physical machine interface-------
	* H/W Layer
(network, CPU, memory, printer, video card, monitor, disk, ...)
```

## Hardware

### __Processor (CPU)__

- CPU executes a set of instructions
	- `Fetch` - `Decode` - `Execute`

	```
	PC = <start address>;
	while (halt flag not set) {
		IR = memory[PC];
		PC++;
		execute(IR);
	}
	```

- Anatomy of a CPU:
	- `Program Counter (PC)`
	- `Instruction Register (IR)`
	- `General Registers`
	- `Stack Pointer (SP)`
	- `Status Register (SR)` or `Processor Status Word`

### __Memory__

- Memory (DRAM) provides storage for `code` & `data`
- Abstraction
	- `Write(addr, val)`
	- `val = Read(addr)`
- Anatomy of memory
	- `Data sections`: global vars
	- `Stack`: local vars, parameters, return values
	- `Heap`: dynamic vars

### __I/O Devices__

- Runs __concurrently__ with `CPU`
- Connected to __device-specific controllers__
- `Buses` connect `CPU` to `memory` & `controllers`
	- Each `controller` owns a range of `bus addresses`
	- `CPU` sends messgage to address using:
		- `Special I/O instructions`
		- `Memory-mapped I/O`: 
			- Memory locations mapped to device registers
- Communication model
	- `Send(addr, val)`
	- `val = Receive(addr)`
		- `CPU` polling the addr for val & read the data with another address
	- Similar to memory abstraction?
		- But data may _never arrive_, _get corrupted_, or _arrive out-of-order_
	- `Polling` frequency?
		- Too high -> waste CPU
		- Too low -> data loss or delay

### __Interrupts__

- `Polling` not efficient -> let devices send `interrupts`
	- `CPU` has `interrupt request flag` to be set by devices
- Requires support from H/W & S/W
- Processor execution with `interrupts`:
	
	```
	1. (H/W) When interrupt flag set:
		H/W saves PC
		Set PC to predetermined address
		The address contains 'interrupt handler'
	2. (S/W) When H/W executes next instruction:
		Save CPU registers
		Run interrupt handler
		Restore CPU registers
	3. (S/W) Handler runs 'return from interrupt' instruction:
		Set PC to original next instruction
	```
	```
	PC = <start address>;
	while (halt flag not set) {
		IR = memory[PC];
		PC++;
		execute(IR);
		if (InterruptRequest) {
			H/W save PC, SP, SR in stack; // not all states, only those necessary to be returned from handler
			PC = memory[0]; // where interrupt handler resides
		}
	}
	Interrupt_handler(){
		save_processor_state(); // gets to choose essential states to save
		handle_interrupt();
		restore_processor_state();
		return;
	}
	```










