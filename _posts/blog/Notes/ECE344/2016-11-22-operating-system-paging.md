---
layout: post
title:  "Operating System - Paging"
categories: Blog Notes OS
tags: ["OS", "ECE344", "paging"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Paging Overview
	1. Introduction to Virtual Memory
	2. Paging MMU
	3. Page Tables
2. Translation Lookaside Buffer (TLB)
	1. TLB Basics
	2. Memory Protection
3. Demand Paging
	1. Demand Paging Overview
	2. Virtual Memory Hierarchy
	3. Managing Virtual Address Space
	4. Managing Physical Memory
	5. Managing Swap Area
4. Processes & Virtual Memory
	1. Interaction of Processes with VM System
	2. Page Sharing & Memory-Mapped Files
	3. Kernal Address Space
5. Page Replacement Algorithms
	1. Page Replacement Algorithms Overview
	2. Paging Issues

<!--more-->
---
## Paging Overview

### Introduction to Virtual Memory

#### Problems with Contiguous Memory

- Growing program requires copying entire program
- Wasted memory due to __internal & external fragmentation__
- Running program requires loading entire program
- Max program size limited by memory size

### Paging MMU

#### Pages & Frames

- __Page__: contiguous, fixed size chunks in virtual address space
- __Frame__: physical memory mapped from a page

#### Virtual & Physical Addresses

```
# 32-bit machine, virtual address space 2^32 B
# page size 2^12, # of pages 2^20
|...20 bits...|.12 bits.|
	page num	 offset

# e.g. physical address space 2^30 B
# frame size 2^12, # of frames 2^18
|...18 bits...|.12 bits.|
	page num	 offset

			   VA				PA
		  ----------->     ----------->
Processor 			   MMU 				Bus
		  <----------------------------
		  	   		   data
```

#### Benefits of Paging

- Growing program requires allocating a page at a time
- No external fragmentation (page granularity); internal fragmentation 1/2 page per region
- Pages can be loaded in memory as program runs
- Max program size limited by disk size

### Page Tables

Mapping information maintained by MMU.

#### Page Table Entries (PTE)

```
|...18 bits...|.7 bits.|C|D|R|W|V|
   frame num	unused
```

#### Storing Page Table

- Stored in memory
	- Each memory access requires 2 memory accesses: PTE & PA
	- Solution: Cache PTE in TLB
- __Page table register (PTR)__
	- For MMU to store the location of start of page table
	- OS associates a seperate page table for each process
	- __Address space switch__ switches PTR

#### Page Table Size

```
#pages * PTE size (typically word size)
= (va_size / page_size) * PTE size
```

- Smaller page size: lower internal fragmentation
- Larger page size: fewer PTE & memory overhead

#### Multi-Level Page Table

```
|.10 bits.|.10 bits.|.12 bits.|
	PT1		  PT2	   offset
```

- Slower than _single-level page table_ because more memory accesses
- Saves space

#### Inverted Page Table

Maps __frame num -> (thread id, page num)__

```
|....|...52 bits...|.12 bits.|
 TID    page num	 offset
  |			|
  -----------
  	   |
   hash func ----> index into page table
```

- Exhaustive search is slow
	- Use hash table indexed by page number
- Hashing function needs to be good
- Poor cache locality
	- Adjacent pages hashed to scattered locations
- Sharing memory is complecated

## Translation Lookaside Buffer (TLB)

### TLB Basics

- H/W cache of PTE
	- Small # of entries
	- Exploits locality (program uses small # of pages at a time)

```
|virtual page number (VPN)|...18 bits...|.7 bits.|C|D|R|W|V|
   							 frame num	  unused
|	key: page number	  |				data: PTE		   |

V: valid, W: writable, R: referenced (H/W), D: dirty (H/W), C: cacheable
```

V: is the entry valid or not?  
W: is the page writable?  
C: is the page cacheable? when not cacheable, processor should bypass the cache when accessing the page, e.g., to access memory-mapped device registers  
D: has a writable page been written to (is it dirty with respect to the data on disk)?  
R: has a page been referenced?  
unused: unused by hardware, can be used by OS  

H/W may or may not need execution bit, but instead use _read_ as _execute_  

#### TLB Operations

##### TLB Lookup

Fully associative TLB example  

![TLB lookup](http://www.cems.uwe.ac.uk/~br-gaster/courses/2015-2016/CNOS/lectures/reveal.js-jade/decks/cnos_lecture9/resources/tlb-lookup.png)

##### TLB cache miss handling

- TLB lookup fails -> page table lookup -> TLB cache replaced (__TLB replacement policy__)
- Handled by H/W or OS
	- H/W managed TLB
		- H/W defines page table format & replacement policy
		- PTR to locate page table in physical memory
		- Fast miss handling
	- S/W managed TLB
		- H/W generates trap called __TLB miss fault__
			- __Read fault__
			- __Write fault__
		- OS handles TLB miss similar to exception handling
		- OS figures out correct PTE, add in TLB (CPU has instructions to modify TLB)
		- Page tables become entirely a OS data structure (no PTR in H/W, H/W doesn't know about page table)
		- TLB replacement policy managed in S/W
		- Slower by more flexible miss handling

##### TLB cache invalidate

- Adds cost to context switching
	- Changing PTR + invalidating TLB + TLB misses afterwards
- Invalidate options
	- __Clear TLB__: clearing valid bit of all entries
	- __Tagged TLB__: H/W maintains __id tag__ on each entry
		- Compare current thread id (stored in register) to the tag
		- No invalidation; enables space multiplexing of entries

### Memory Protection

- Generate __protection fault__ if memory access inconsistent with protection bits
	- __Read-only fault__
	- __No-execute fault__

## Demand Paging

### Demand Paging Overview

- Motivation: program size/# of running programs limited by physical memory
	- Make memory a cache for data on disk
- Basic Mechanism
	- PTE unset for invalid page
	- __Cache miss__ when program accesses invalid page
	- Generates __page fault__
	- OS __page fault handler__ performs miss handling: allocate frame, update PTE, set valid bit, restart instruction
- Benefits
	- Allows programs run to exceed available memory (limited by VA space (processor architecture) or disk)
	- Faster startup programs (no need to load entire program)

### Virtual Memory Hierarchy

![VM hierarchy](http://images.slideplayer.com/27/9050102/slides/slide_8.jpg)

#### Swap Handler

1. Chooses a page to evict using page replacement algorithm
2. If page modified, write to a free location on __swap__
3. Find pages that map to the evicted frame
	- Need frame-to-page mapping (coremap)
	- Change all PTEs to invalid
	- Keep track of the evicted frame location in swap
4. Return newly freed frame to page fault handler

#### Other Notes

1. If _TLB miss handling_ is performed by H/W, no _TLB miss fault_ generated; if by S/W, H/W doesn't access PT
2. __Page fault handler__: 
	- checks __segmentation fault__, __protection fault__
	- allocates frame, PTE
	- loads data from disk into frame
	- maps page to frame by updating PTE
3. Page contents may:
	- be all 0
	- in __swap__
	- in __executable__
4. OS accesses PT when:
	- on TLB-miss fault (for h/w managed TLB), it reads the page table
	- on page fault, it allocates frame and updates page table
	- whenever address space of current process is modified, (frame is allocated/deallocated, context switch), it updates page table

### Managing Virtual Address Space

#### Address Space

- Broken into __regions__ or __segments__
- OS must track the regions within an address space & PT holding translations
- API
	- `id = as_create()` create empty address space, allocate new PT with no pages mapped to frames
	- `as_destroy(id)` destroy as, free PT
	- `as_define_region(id,...)` add new region
	- `as_modify_region(id,...)` change size (e.g. heap, stack)
	- `as_find_region(id,va)` find valid region or give seg fault
	- `as_load_page(id,...)` load page from file into memory
	- `new_id = as_copy(id)` create copy of as & PT (actually copy data to other frames)
	- `as_switch(id)` mappings in TLB must be removed

### Managing Physical Memory

#### Coremap

- Array of structures, one per frame
- Tracks:
	- whether frame allocated
	- address spaces & pages map to this frame (list of (pid, page_id))
	- kernel or user
- API
	- `frame = allocate_frame(n)` alloc n free contiguous frames (user needs 1 frame; kernel needs more)
	- `free_frame(frame)`
	- `map(id,page_nr,frame)`
	- `unamp(id,page_nr)`
	- `evict(frame)` for swap handler to unmap pages associated with frame

### Managing Swap Area

- Dirty pages need to be placed in swap
- Bitmap or linked list of __swap frames__ on disk; keep location in invalid PTE
- If loading shared frame from swap and needs to write to it:
	- allocate a frame and keep the swap frame
	- next time allocate another frame and free the swap frame
	
	```
	# PTE
	|frame number|unused|R|D|C|W|1| virtual page in memory
	|000.......................0|0| invalid PTE
	|index in swap area.........|0| virtual page in swap
	```

## Processes & Virtual Memory

### Interaction of Processes with VM System

- OS implements VM system using 3 abstractions: address space, physical memory, & swap management
- Rest of OS invokes the VM systems when __address space of current process changes__
	- Process creation `fork`
		- Create new PT & copy content from parent's regions
	- Process execution `execv`
		- Destroy old address space structure & create new one
	- Process termination `exit`
	- Context switch
		- H/W managed TLB: change PTR, flush TLB
		- S/W managed TLB: flush TLB
	- Memory allocation/deallocation `sbrk, stack`
		- Heap: system call (`sbrk`) to grow; allows OS to __detect errors__
		- Stack: when faulting address _clost_ to stack, extend stack region running standard page fault handler

### Page Sharing & Memory-Mapped Files

- Benefits
	- Fast communication between processes
	- Good isolation (only share when needed)
- Applications
	- __Sharing text regions__
		- e.g. dynamically loaded libraries
		- Must update all pages when frame evicted
	- __Copy-on-write pages__
		- Child shares pages with parent until pages modified
		- PTE marks __COW & read-only__
		- On protection fault: allocate new frame, copy, remap, make writable, update TLB, resume
		- Must update all pages when frame evicted
	- __Memory-mapped files__
		- Threads r/w files using load/store instead of system calls
		- `mmap(addr,length,prot_flags,fd,offset)` maps a file at given offset contiguously within address space
			- Storing `offset` to provide flexibility since different processes may have different addresses of shared memory
		- File data loaded on page fault
		- Instead of swap area, use file itself as backing store
		- More efficient than r/w system calls because system calls need buffer in kernel to transfer data
- Shared memory
	- Threads r/w to mapped memory region
	- PTE can have different protections for different threads
	- Memory can be mapped at same or different VA in each process

### Kernal Address Space

- OS typically lies in _low physical memory_
- Options
	- __Paging turned off__ in kernel mode, OS access physical memory directly
		- OS needs to simulate paging, i.e. do address translation in software, to copy in or out user parameters on a system call, deal with dirty bit, etc.
	- OS uses __separate address space__
		- Pros
			- Clean isolation
		- Cons
			- System call requires switching MMU -> TLB flush
			- Copy in/out of system call parameters requires traversing PT in S/W
	- OS maps to __address space of each thread__
		- Typically mapped to high addresses
		- Pros
			- No system call
			- Copy in/out of system call parameters can reuse paging H/W		
		- Cons
			- Address space of processes reduces
			- PT needs to be setup to access OS code
				- H/W may allow OS to bypass PT

## Page Replacement Algorithms

### Page Replacement Algorithms Overview

- When will paging work?
	- If occurs rarely
	- __Spatial locality__ & __temporal locality__
- Algorithms
	- __Optimal algorithm__: page that will not be needed for longest time
		- Need to know the future
		- Can be used to compare performance
			- Generate a log of VM accesses (__reference string__); use log to simulate various replacement policies
	- __FIFO__: oldest page
		- Oldest page may be needed soon
		- Faults may increase if given more memory ([Belady's Anomaly](http://stackoverflow.com/questions/4800285/cant-understand-beladys-anomaly))
	- __Clock__: FIFO giving second chance to referenced pages
		- __Referenced bit__: set by processor when page read/written; cleared by OS/software
		- __Dirty bit__: set by processor when page written; cleared by OS/software
		- OS synchronizes R/D bits in TLB with PTE (H/W: write-through or write-back; S/W: needs to implement synchronization)
		- OS simulates the bits if H/W doesn't maintain
			- When TLB read fault: 
				- Set referenced bit; make page read-only
			- When TLB read-only protection fault/write fault: 
				- Set referenced & dirty bits; make page writeable
			- Algorithm

				```
				Choose page starting from clock hand:
					if referenced bit set:
						unset, goto next
					else:
						if page dirty:
							schedule page write, goto next
						else:
							select for replacement
				```
	- __LRU__: page used least recently
		- Updating LRU on each memory access is expensive
		- If MMU maintains a counter incremented at each clock cycle:
			- When page accessed: 
				- Writes counter value to PTE
			- On page fault: 
				- S/W looks through PT, identifies entry with oldest timestamp
		- If MMU doesn't provide such counter, OS maintains it in S/W (__LRU aprroximation__):
			- Periodically (timer interrupt) increment counter; granularity depends on timer interrupt
			- If referenced bit set:
				- Write counter value
				- Clear referenced bit
			- On page fault:
				- S/W looks through PT & identify the oldest timestamp
	- __Working set clock__: keep working set in memory
		- __Working set__: set of pages a program needs currently
			- __Working set interval `T`__: `WS(T) = {pages accessed in interval (now, now-T)}`
			- __Max WS__: how much memory a program needs
		- Algorithm

			```
			Choose page starting from clock hand:
				if referenced bit set:
					update time-of-last-use to current virtual time
					unset, goto next
				else:
					if (current time - time-of-last-use) < T:
						continue
					else:
						if page dirty:
							schedule page write, goto next
						else:
							select for replacement
			```
	- __Page fault frequency__: estimate of working set needs of a program
		- Measurements

			```
			For each thread:
				On fault:
					f = f + 1
				Every second, update faults/sec (fe) via aging:
					fe = (1-a) * fe + a * f, f = 0
					# 0 < a < 1, weighting factor; a -> 1 means history ignored
			```
		- Allocate frames s.t. __PFF is equal for programs__
			- __Global replacement__: victim process has lowest PFF
			- __Local replacement__: use algorithms above (clock, LRU, etc.) to evict a page within the victim process
- Comparison

	|Algorithm|Comment|
	|:--------|:------|
	|Optimal|Not implementable; useful as benchmark|
	|FIFO|Might throw out important pages|
	|Clock|Realistic|
	|LRU|Excellent; difficult to implement efficiently|
	|WSC|Efficient working set algorithm|
	|PFF|Fairness in working set allocation|

### Paging Issues

#### Paging & I/O Interaction

- Problem: a frame waiting for I/O may be selected for eviction
- Solution: each frame has __do not evict__ flag called __pinned page__; un-pin after I/O completes

#### Paging Performance

- Paging works best if many free frames
- If pages full of dirty pages, 2 disk operations (swap in/out) needed on each page fault
- __Paging daemon__: swap out in advance
	- OS maintains a pool of free frames using __paging thread/daemon__
	- Daemon runs replacement algorithm periodically or when pool reaches __low watermark__:
		- Writes out dirty pages
		- Frees enough pages until pool reaches __high watermark__
	- Frames can be __rescued__ if page referenced before realocation, because previous content still holds
- __Prefetching__: swap in in advance
	- Predict future page usage at current faults
	- Works well when pages read sequentially

#### Thrashing

- __Livelock__: OS spends time paging data from disk, programs not making progress
- Causes
	1. Pages replacement algorithm not working
	2. Not enough memory to hold working set of all running programs
- Solutions
	1. __Swapping__: suspend some programs for a while
	2. Buy more memory

#### Resources

* [What are the differences between a page table and an inverted page table?](https://www.quora.com/What-is-the-differences-between-a-page-table-and-an-inverted-page-table)
* [Can I turn off paging in kernel mode?](http://f.osdev.org/viewtopic.php?f=1&t=15321)



















