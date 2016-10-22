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
4. OS-Related Hardware

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
													(user mode interface)
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

## OS-Related Hardware

- OS is S/W, when other apps are running, it is not. How does OS manage resources?
	- Requires H/W support to implement virtualization & abstraction __efficiently__ & __securely__
		- __Efficient__ because no need to provide interpreter for every single instruction that provides H/W `abstraction` & `virtualization`
		- __Secure__ because `CPU modes`, `MMU`, & `traps` ensure no corruption between programs

### __CPU Modes__

- 2 CPU Modes:
	- `Kernel mode` - OS
		- Every instruction can be executed  
			e.g. access disk & timer, controll interrupts, setting CPU mode
	- `User mode` - Programs
		- A subset of instructions can be executed  
			e.g. `add`, `sub`, `push`, `pop`, etc.
- Current mode kept in `status register`
- Devices mapped to kernel memory
- OS is priviledged & trusted program; correct system operation depend on correct OS design & implementation instead of user programs
- Enables `memory isolation`
	- Memories & registers can only be changed in `privileged mode`

### __Memory Management__

- `Memory Management Unit (MMU)`
	1. Programs use `virtual memory addresses`
	2. `CPU` sends `virtual addresses` to `MMU`
	3. `MMU` translates them to `physical addresses`
	4. `MMU` accesses `physical addresses`
- Anatomy of a simple MMU
	- `Base register`
		`Phys addr = Virt addr + Base reg`
	- `Limit register`
		`Virt addr < Limit reg`
- Enables `memory virtualization` & `memory isolation`
	- `Memory virtualization`: Each program has access to a large amount of contiguous, private memory, starting at address 0
	- `Memory isolation`: Ensures OS & other programs are located in different physical memory, and they cannot step on each other

### __Trap__

- For programs to switch to `kernel mode` and run `OS code`
	- Programs cannot call `OS code` directly because `MMU` isolates `OS code` & program not in `kernel mode`
- Provides a secure way to enter the kernel
- Similar to handling `interrupts`

	```
	# (H/W) On trap:
		Switch to kernel mode
		Run OS handler code at well-defined location
	# (S/W) OS handler code:
		Save processor state
		Runs kernel functions to access H/W
		Restore processor state
		Return to user code, switch to user mode
	```
	=> __atomic__ to avoid `user code` running in `kernal mode`

- Unix system calls
	- Process related  
		e.g. fork, exec, wait, exit, kill, signal
	- File related  
		e.g. open, read, write, close, link, unlink, chdir
- Invoking system call

	```
	read(file, buff, n) { // library code
		...
		lw v0, SYS_read // load syscall number into v0 reg

		syscall // trap
		...
	}
	```
- `Traps`, `interrupts`, `exceptions`

	|			| Interrupt | Trap | Exception |
	|-----------|:----------|:-----|:----------|
	|Cause		| H/W external to CPU | Explicit intruction| Instruction failure |
	|Effect 	| Program unaware of interrupt handling (async) | Similar to program invoked function, function returns data (sync) | Abnormal control flow |
	|Timeliness | Needs to respond quickly | Program suspended, OS can take time | OS can take time |

---
### __Quick Questions__
1. How does OS manage H/W?
	- Abstraction & virtualization
2. OS is software, when other applications are running, it is not running, so how can it do its work?
	- H/W support e.g. CPU modes, MMU, traps
3. Why can’t applications corrupt other applications or the OS?
	- MMU helps
4. Why can’t applications directly access h/w?
	- I/O devices are mapped to kernel memory, so no access allowed by MMU; or, I/O intructions are priviledged
5. Why is the OS not a normal program?
	- Entered from different locations (system calls and interrupts) in response to external events
	- It does not have a single thread of control, it can be invoked simultaneously by two different events (e.g. system call & interrupt)
	- It is not supposed to terminate
	- Can execute any instruction in the machine
	- Has access to the entire memory on the machine
6. What if a program tries to cheat?
	1. What happens if it issues a privileged instruction directly? 
		- Attempting execution of privileged instruction in user mode causes trap, so kernel gets control. Normally, kernel will kill program.
	2. What if a running thread doesn’t make a system call to the OS and hence hogs the CPU?
		- OS must register a future timer interrupt before it hands control of the CPU over to a thread; when the timer interrupt goes off, the OS gets control
	3. What stops the running program from disabling an interrupt?
		- It is a priviledges instruction
	4. What stops a program from modifying the OS so that the OS runs user code?
		- Program cannot even see OS code due to memory virtualization
	5. What stops a program from changing the MMU registers?
		- It is a priviledges instruction
7. How does the OS solve these problems:
	1. Time sharing the CPU among programs?
		- Timer interrupts
	2. Space sharing memory among programs?
		- MMU
	3. Protection of programs from each other?
		- 1. & 2.
	4. Protection of hardware/devices?
		- I/O devices are mapped to kernel memory, so no access allowed by MMU; or, I/O intructions are priviledged
	5. Protection of the OS itself?
		- MMU isolates OS code
8. Does library code (executing in user mode) provide isolation and abstraction?
	- Provides abstraction but not isolation. Programs can jump to any instruction in library code, overwrite library code/data, thus bypassing any isolation that library code may try to provide.
9. Does a virtual machine monitor (VMM) such as VMware provide isolation and abstraction?
	- A VMM is a system program, similar to an OS, that allows multiple OSs to run simultaneously on a single physical machine
	- It provides isolation, but the same abstraction as a physical machine (each OS thinks it is running on physical hardware), thus providing no additional abstraction than the physical machine.
10. Why can’t user code execute some arbitrary code of its choosing in kernel mode?
	- User code wants to execute some code in kernel mode, so what can it do?
		1. Write instructions into kernel image - can’t do that due to memory protection.
		2. Transfer control to arbitrary places in kernel image to skip checks - can’t do this due to memory protection, and control can only be transferred via TRAP to well known kernel entry locations.
		3. Execute privileged instructions - can’t do this in user mode.
11. What is the minimum number of privileged instructions that h/w must implement so that the OS can work correctly?
	- With memory mapped IO, you can hide all device accesses with memory protection. So programming the MMU (i.e., modify MMU registers) should be privileged. 
	- Also, returning from a trap (e.g., iret instruction) should ensure that we cannot switch from user to kernel mode and run arbitrary kernel code. For example, on x86, a return from trap is guaranteed to execute code with the same or lower privilege level.








