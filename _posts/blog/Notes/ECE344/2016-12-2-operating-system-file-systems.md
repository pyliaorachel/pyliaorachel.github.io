---
layout: post
title:  "Operating System - File Systems"
categories: Blog Notes OS
tags: ["OS", "ECE344", "file system"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Overview of File Systems
2. File System Design
3. Sharing Files
4. Unix File System
5. Consistency & Crash Recovery
6. Journaling File Systems
7. Log-Structured File Systems (LFS)

<!--more-->
---
## Overview of File Systems

- Abstraction for storing, organizing, & accessing __persistent data__
	- Data organized as objects called __files__
	- Files accessed via __system calls__

#### Basic File-Related Calls

- __Open__
	- Program can keep the __file description__ returned to imporve file access efficiency
- __Read/Write__: r/w bytes from/to current position; update position
- __Seek__: move to new position
- __Close__
- __Create__, __rename__, __delete__, __get/set attributes__

#### Basic Directory-Related Calls

- __Open__
- __Readdir__: read entries in a directory
	- No __writedir__ to avoid dir metadata corruption
- __Seekdir__
- __Close__
- __Create__, __rename__, __delete__, __get/set attributes__
- __Link/Unlink__: add/remove a name for an existing file
	- __Hard link__: different directory entries have same inode number
		- Inodes maintains reference count
		- Points to files not directories to avoid cycles (ensure directory deletion ok)
		- Becomes __DAG__
	- __Symbolic link (short cut)__: a file containing data of another file's name (redirect)
		- File type: shortcut (l)

## File System Design

- OS needs to:
	- maintain information about files & directories
	- store files durably
	- handle machine crashes e.g. recover data

#### Disk Blocks

- Disks are accessed at the granularity of sectors; a file system allocates data in __blocks__
	- Reduces overhead managing individual blocks
	- Increase internal fragmentation

#### File System Tasks

- __Free block management__
	- __Bitmap__: separate area on disk
		- Allows allocating contiguous blocks to file easily
		- Only need 1 bitmap block in memory at a time
		- Extra space for bitmap
- __Block allocation & replacement__: maps (potentially non-contiguous) blocks to file
	- __Contiguous allocation__
		- Good performance for sequential reading
		- File growth requires copying
		- Fragmentation; need periodic compaction
		- Good for __CD-ROMS__: file sizes known, files never deleted
	- __Linked list allocation__: first word in block points to next block
		- Random accesses slow
	- __File allocation table (FAT)__: keep linked list information in memory
		- Random accesses faster
		- Entire table in memory, poor scalibility of file system
		- More efficient than i-node on small files
	- __I-node based allocation__: tree to store index information
		- Allows growth of index information without spreading this information too much
		- Optimized for small files
		- Root of tree: __inode__
			- 12 __direct block pointers__
			- 1 __indirect pointer__
			- 1 __double indirect pointer__
			- 1 __triple indirect pointer__

			```
								disk partitions
			|MBR||||	|								   |	|	|
						/									\
					   |Super|Inode |Block |Inode |File & dir|
					   |block|bitmap|bitmap|blocks|blocks    |
			```

		- Block placement
			- Problems
				- Data blocks scatter across disk in _aging_ file systems -> long seeks
				- Inodes at beginning of disk, far from data -> going back and forth -> long seeks
		- __BSD Fast File System__
			- Disk partitioned into groups of cylinders
			- __Superblocks__ placed in every group & in offset manner to recover from damage
			- Place these in same cylinder group:
				- Inode, data blocks in a file
				- Files in a directory
				- Place in nearby group if group full

- __Directory management__: map file names to location of starting block of file
	
	```
	|file name|file attributes|starting block #|
	...

	# Unix
	|file name|i-node #| # i-node contains file attributes
	...
	```

	- File names
		- Short, fixed length names
		- Variable length names
			- Size of directory entry variable
			- Options
				- Entries allocated contiguously: 

					```
					|len|name|inode|len|name|inode|...
					```
					-> Inefficient for search; fragmentation  
				- Allocate pointers to file names in the beginning of directory; heap at end to store names

					```
					|p1|hash of name1| # fixed size
					|p2|hash of name2|
					...
					p1-> |name1|inode| # variable size
					p2-> |name2|inode|name3|inode|
					```
	- File deletion
		- Directory entry removed from directory
		- All blocks in file returned to free list
	- Path lookup: e.g. `/D1/D2/F`
		- Super block (locatin of inode blocks area; typically already cached in memory)
		- Inode of `/` -> data blocks of `/`
		- Inode of `D1` -> data blocks of `D1`
		- Inode of `D2` -> data blocks of `D2`
		- Inode of `F` (returned in `open`) -> data blocks of `F`

- __Buffer cache management__: cache disk block in memory
	- Operations
		- __Block lookup__

			```
			# hash table to lookup blocks in memory

				  key
			|device|block #| -> |disk block in memory| -> ...
			...
			```

		- __Block miss__
		- __Block flush__
	- Issues
		- Limited size: need replacement algorithms
		- Competes with VM system about frames
			- __Separate cache__: inefficient use of cache if not doing file I/O
			- __Unified cache__: large file I/O affects performance of other programs
	- __Read ahead__: prefetch next block from disk

## Sharing Files

- Issues
	- Concurrent access
		- __Sequential consistency__
			- A `read` call sees data from most recently __finished__ `write` call
			- All processors see same order of writes
	- Protection
		- __Subject__: __who__ can access a file
		- __Object__: the file
		- __Action__: how can they access a file
			- `read`, `write`, `execute`, `append`, `change protection`, `delete`, etc.
		- Mechanisms
			- __Access control lists (ACL)__: object -> subjects & actions
				- Easy to grant, revoke
				- Becomes large when heavily shared -> use __groups__
			- __Capabilities__: subject -> objects & actions
				- Easy to transfer
				- Hard to revoke

## Unix File System

```
# In memory

Parent's fd table   Open file table
-----------			|File position|
-----------			|R/W		  |
----------- ------> |Ptr to i-node|
... 				---------------
					|			  |
Child's fd table  / |			  |
-----------      /	...
----------- -----
-----------
...

# Child can copy parent's fd table when forked
```

### File-Related System Calls

- `fd = open(name,mode)`
	- Path lookup: find inode of file
	- Cache inode in buffer cache
	- Check permissions
	- Set up entry in open file table
	- Set up entry in fd table
	- Return fd
- `byte_count = read(fd, buffer, buffer_size)`
	-  Figure out data/indirect blocks to read
	- Read from disk into buffer cache
	- Copy data to user buffer
	- Update file position
	- Return # of bytes read
- `byte_count = write(fd, buffer, num_bytes)`
	-  Figure out data/indirect blocks to write
	- Read from disk into buffer cache
	- Copy data from user buffer to buffer cache
	- Update i-node
	- Mark modified buffers dirty (inode, free maps, indirect, data blocks, etc.)
	- Schedule writing dirty buffers to disk
	- Update file position
	- Return # of bytes written
- `close(fd)`

### Mounting File Systems

- __File system namespace__: set of names for all files in a file system
- File system __mounting__ glues a file system namespace into the namespace of another file system

## Consistency & Crash Recovery

#### Deleting a Unix File

1. Remove file's directory entry in directory data block
2. Mark inode of file as free in inode bitmap; mark file blocks as free in block bitmap; update metadata in inode of directory

Crash in between leads to __storage leak__.

Switch steps. Crash in between leads to __dangling pointer__.

#### Reducing File System Inconsistency

- Write-through metadata blocks
	- Avoid dangling pointers
	- Still inconsistent for the last file system operation before a crash
- Write-back data blocks
	- Most blocks are data blocks, improves file system performance
	- Data blocks can be lost without affecting file system consistency
- __Crash recovery__: restore file system consistency
	- Full scan of file system to recover inconsistent states
	- Long time since disk capacities increase faster than disk throughput
- Avoid crash recovery:
	- Use __battery-backed RAM__
		- Ensure enough power to write all dirty blocks to disk
	- __Failure atomicity__: a file system operation either doesn't happen at all or happens completely
		- __Undo recovery__
			1. Copy old block on disk to spare block on disk (mark done)
			2. Copy new block in memory to block on disk
			3. Remove spare block
		- __Redo recovery__
			1. Copy new block in memory to spare block on disk (mark done)
			2. Copy new block in memory to old block on disk
			3. Remove spare block

## Journaling File Systems

- __Write-ahead logging__
	- Write new versions of blocks in a __journal__ (circular log)
	- __Commit__ when done
	- File system then updates asynchronously
	- Copy journal blocks to file system on crash where commit is present
- Steps
	1. Write blocks (e.g. B,I,D) to journal 
	2. Write commit block to journal

		```
		|...|TransactionHeaderBlock|B'|I'|D'|Commit|

		# TransactionHeaderBlock contains block # of the following blocks
		```
	3. Install: copy updated B,I,D to file system
	4. Free transaction in journal
- Observation based on FFS
	- As memory gets larger, need to __optimize for writes__
	- Reads: read from buffer cache, less of performance problem
	- Writes: becomes heavy for synchronous operations & data integrity
		- Also, writes are not well clustered i.e. directory, inodes, data are scattered

## Log-Structured File Systems (LFS)

Write all file system data & metadata in a contiguous log.

- __LFS reads__
	- When inodes updated, written in log (scattered in log)
	- __Inode-map__: an array in memory to locate inodes
		- Inode # -> inode location in log
- __LFS writes__
	- When inodes updated, inode-map has to be updated & stored on disk (inode-map itself stored in the log)
	- Uses __checkpoint region__ in a fixed area on disk
		- Locates inode-map blocks in log
		- Serves as a commit point
		- Region updated when inode-map blocks written
	
		```
		|superblock|checkpoint region|		segment 	  |segment|...|
									/		  			   \
									|segment|inode|inode|...|
									|header |	  |map	|...|

		# Checkpoint region -> inode map -> inode -> data
		```

		- Keep 2 checkpoint regions to ensure failure atomicity on checkpoint region itself
- Log space reclamation
	- Reclaim segments when:
		- blocks overwritten
		- blocks deleted
		- live blocks have to be copied out of segments
- __Wear leveling__: writing to SSD in log fashion
	- Since each block in SSD has limited endurance, log fashion ensures writes to be spread evenly on disk

### Comparison on Journaling File Systems & Log-Structured File Systems

#### Journaling

- Motivation: speed up crash recovery
- Benefit: speeds up crash recovery
- Drawback: every block write becomes two block writes

#### Log-Structured

- Motivation: reads will be absorbed by buffer cache, optimize for writes by issuing all writes sequentially
- Drawback: 
	1. Reads not sequential if file created sequentially
	2. Need garbage collection -> affect normal I/O performance
- Writes: 1 or more; 1 for writing to log, more for cleaning process

#### Resources
* [Log-structured File Systems](http://pages.cs.wisc.edu/~remzi/OSTEP/file-lfs.pdf)













