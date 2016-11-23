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

1. Introduction to Virtual Memory
2. Paging MMU
3. Page Tables

<!--more-->
---
## Introduction to Virtual Memory

#### Problems with Contiguous Memory

- Growing program requires copying entire program
- Wasted memory due to __internal & external fragmentation__
- Running program requires loading entire program
- Max program size limited by memory size

## Paging MMU

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

## Page Tables

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

#### Related Resources

* [What are the differences between a page table and an inverted page table?](https://www.quora.com/What-is-the-differences-between-a-page-table-and-an-inverted-page-table)




















