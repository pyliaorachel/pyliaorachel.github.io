---
layout: post
title:  "Operating System - Disk & RAID"
categories: Blog Notes OS
tags: ["OS", "ECE344", "disk"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Disks
	- Disk Scheduling Algorithms
2. Redundant Array of Inexpensive Disks (RAID)

<!--more-->
---
## Disks

- Structure
	- __Disk__
		- __Platters__
			- 1 __arm__: move together
			- 1 __head__: access data in parallel
			- Concentric __tracks__: same track across different platters
				- __Sectors__: preamble + data + 16B of ECC
- Disk access delays
	- __Seek time__: move head to correct track
	- __Rotational delay__: rotate to correct sector
	- __Transfer time__: r/w bits of sector (fastest among all)
- Disk performance trends
	- __Capacity__: 2x every 2 years
	- __Transfer rate (BW)__: 2x every 2 years
	- __Seek & rotation time__: 1/2 every 10 years
- Disk performance
	- Highest bandwidth for sequential access
	- Worst bandwidth for random access
- Disk scheduling
	- Aims to minimize __seek time__ (__rotational delay__ hard to control)
- Addressing disks
	- Older disks: require OS to specify all parameters e.g. cylinder, track, sector, transfer size, etc.
	- Modern disks: complicated e.g. not all sectors the same size, sectors are remapped, etc.
	- Current disks: higher-level interface, exports data as logical array of sectors & maps logical sectors to its surface
- Disk errors
	- Latent sector errors, mis-directed writes
	- Transient v.s. hard errors
	- Some errors can be masked by __ECC__
	- __Bad sectors__: physical damage; mapped to spare in factory, by disk controller

### Disk Scheduling Algorithms

Aims to minimize __seek time__ (__rotational delay__ hard to control).

- 2 methods
	- Reduce seek & rotation
	- Read several sectors at once
- Algorithms
	- __FCFS__
		- Simple, fair, slow
	- __Shortest seek time first (SSF)__
		- Starvation
	- __SCAN (elevator)__: serve next request in same direction (a bit to track arm direction)
		- Benefits tracks in the middle more
	- __C-SCAN__: SCAN in one direction
		
## Redundant Array of Inexpensive Disks (RAID)

Use many disks in parallel; increases storage bandwidth, improves reliability.

- __Stripe__: unit of r/w to RAID
	- __Chunks/Strips__: unit of r/w to a single disk
- Improving storage bandwidth
	- Chunks on different disks can be r/w in parallel
	- Large chunk size:
		- Fewer seeks across disks -> better throughput
	- More disks:
		- Bandwidth increases
	- Large stripe size:
		- Internal fragmentation
		- Should be based on average file size

### RAID Level 0: Disk Striping

Distributes data across several disks for speed. No redundancy.

```
| Strip 0 | | Strip 1 | | Strip 2 | | Strip 3 |
| Strip 4 | | Strip 5 | | Strip 6 | | Strip 7 |
| Strip 8 | | Strip 9 | | Strip 10| | Strip 11|
```

### RAID Level 1: Mirroring

Backup. Write both, read either.  
Utilization: 50%

```
| Strip 0 | | Strip 1 | | Strip 2 | | Strip 3 | | Strip 0 | | Strip 1 | | Strip 2 | | Strip 3 |
| Strip 4 | | Strip 5 | | Strip 6 | | Strip 7 | | Strip 4 | | Strip 5 | | Strip 6 | | Strip 7 |
| Strip 8 | | Strip 9 | | Strip 10| | Strip 11| | Strip 8 | | Strip 9 | | Strip 10| | Strip 11|
```

### RAID Level 4: Dedicated Parity Disk

Calculate XOR value of chunks and store on parity disk.
Utilization: (N-1)/N

```
# P0-3 = S0 ^ S1 ^ S2 ^ S3
# P'0-3 = S'0 ^ S1 ^ S2 ^ S3 = S'0 ^ S0 ^ P0-3

| Strip 0 | | Strip 1 | | Strip 2 | | Strip 3 | | P0-3 |
| Strip 4 | | Strip 5 | | Strip 6 | | Strip 7 | | P4-7 |
| Strip 8 | | Strip 9 | | Strip 10| | Strip 11| | P8-11|
```

### RAID Level 5: Distributed Parity

Parity information distributed across all disks. Avoids bottleneck for parity disk.

```
| Strip 0 | | Strip 1 | | Strip 2 | | Strip 3 | | P0-3    |
| Strip 4 | | Strip 5 | | Strip 6 | | P4-7 	  | | Strip 7 |
| Strip 8 | | Strip 9 | | P8-11   | | Strip 10| | Strip 11|
```

#### Resources
* [Chunks: the hidden key to RAID performance](http://www.zdnet.com/article/chunks-the-hidden-key-to-raid-performance/)
* [Stripe Width and Stripe Size](http://www.pcguide.com/ref/hdd/perf/raid/concepts/perfStripe-c.html)
















