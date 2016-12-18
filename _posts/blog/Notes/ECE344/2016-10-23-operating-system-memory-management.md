---
layout: post
title:  "Operating System - Memory Management"
categories: Blog Notes OS
tags: ["OS", "ECE344", "memory management"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Introduction to Memory Management
2. Managing Memory with Bitmaps & Lists
3. Simple Memory Management & Fragmentation

<!--more-->
---
## Introduction to Memory Management

- Requirements
	- __Isolation__
	- __Abstraction__
	- __Sharing__
- Goals
	- Low memory overhead
	- Low performance overhead
- Supports
	- __Compiler__
		- Source file to object file
		- Generates _relocatable_ `virtual memeory addresses`
	- __Linker__
		- Links multiple object files to single program on disk
		- Generates _absolute_ `virtual memeory addresses`
	- __OS__
		- Loads program into `physical memory`
		- Sets up `virtual memory H/W`
	- __H/W__
		- Translates `virtual memory` to `physical memory`
		- S/W too slow for address translation

## Managing Memory with Bitmaps & Lists

- After `boot loader` loads OS code & data in low memory, `OS` keeps track of `allocated` & `free` memory

- Bitmap
	- 1 bit per chunk of memory; in use or not
	- Larger chunk size, lower overhead BUT more __internal fragmentation__

	```
	|--OS code data--| bit map | chunk1 | chunk2 | ... |
					  01101...
	```

- Linked Lists
	- A list of elements for each allocated or free region of memory
	- Allocated bit + starting address + length + pointer

	```
	| A |   f   |  B  | C | f |    D    | E | f | ... |

	| a | 0 | 5 | [] | --> | f | 5 | 3 | [] | --> ...
	```

	- Searching
		- __First fit__
		- __Best fit__
		- __Quick fit__

- Under which conditions is each approach preferable?

## Simple Memory Management & Fragmentation

- __Internal fragmentation__
	- Program doesn't use entire region -> paddings
- __External fragmentation__
	- A large region cannot be allocated even enough memory exists
		- _Compaction_: move processes around, but expensive














