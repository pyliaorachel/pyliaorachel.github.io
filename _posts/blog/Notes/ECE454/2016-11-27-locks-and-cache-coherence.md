---
layout: post
title:  "Locks & Cache Coherence"
categories: Blog Notes Optimization
tags: ["Optimization", "ECE454"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Locks & Cache Coherence
	1. Atomic Operations
	2. Ticket Lock
	3. Array-Based Queueing Locks
	4. List-Based Queueing Locks (MCS Locks)
	5. Summary

<!--more-->
---
## Locks & Cache Coherence

- Criteria for evaluating spin locks
	- Scalability & induced network load
	- Single-processor latency
	- Space requirements
	- Fairness
	- Implementability with available atomic operations

### Atomic Operations

H/W support is required to implement synchronization primitives.

- Test & set
	- Steps
		1. Load old value to register
		2. Set value in memory to 1
		3. Return old value
	- Lock implementation (TAS)

		```
		struct lock { 
			int held = 0;
		}
		void acquire (lock) {
			while (test-and-set(&lock->held)); 
		}
		void release (lock) { 
			lock->held = 0;
		}
		```
	- Contentions
		- 2 threads contending to acquire lock & modify lock to 1
		- Caused by spinning on _global_ variables
		- Poor scalability
	- Improved lock implementation (TATAS)

		```
		void test_and_test_and_set (lock) { 
			do {
				while (lock->held == 1) // only read
					; // spin 
				}
			} while (test_and_set(lock->held));
		}
		void release (lock) {
			lock->held = 0; 
		}
		```

	- Further improved lock implementation (TAS with backoff)

		```
		while test&set (L) fails { 
			pause (delay);
			delay = delay * 2;
		}
		```
- Swap
- Fetch & Op
- Compare & swap

### Ticket Lock

```
my_ticket = fetch_and_increment(next_ticket); 
while (my_ticket != now_serving)
	pause(); //back-off
```

- Improvements
	- Only 1 process try to get lock upon release
	- Only 1 process have read miss upon release (not achieved)
	- Locked acquired in FIFO (fairness)
	- Further improvement: proportional backoff
- Components
	- 2 counters: `next_ticket`, `now_serving`
	- Lock acquire: `fetch-and-increment` on `next_ticket`
	- Lock release: increment on `now_serving` -> cuases contention

### Array-Based Queueing Locks

- Components
	- Queue `slots[N]`, each element lies in different cache line
		- Has-lock (HL)
		- Must-wait (MW)
	- `next_slot`
- Steps
	1. Incoming processes enqueued (`my_place = fetch-and-inc(next_slot)`)
	2. Lock-acquire: `while(slots[my_place] == MW);`
	3. Lock-release: `slots[(my_place+1)%N] = HL;`
- Pros
	- Atomic ops `fetch-and-inc` to obtain location to spin on
	- Each CPU spins on different location in a distinct cache line
	- Each CPU clears the lock for its successor (must-wait -> has-lock)
- Cons
	- Space complexity `O(N)`(bounded by # of processors)
	- Queue is static

### List-Based Queueing Locks (MCS Locks)

- Steps
	1. Incoming processes enqueued (`predecessor = fetch-and-store(L,me)`)
	2. Lock-acquire: wait for predecessor to signal
	3. Lock-release: remove `me` from `L` & signal successor
		- If no successor, spin on myself using `compare-and-swap(L,me,nil)`

			```
			L -> me
				 new

			# compare-and-swap fails
			L    me
			  ⬊  
			  	 new

			# spin on while I->next = nil
			L    me
			  ⬊   ↓
			  	 new
			```
- Properties
	- Lock points at tail of queue
	- __Compare-and-swap__ for detection if it is the only processor in queue & atomic removal of self from queue
- Pros
	- Spins on local flag variables only
	- Requires a small constant amount of space per lock (bounded by # of requests)

### Summary

- __TAS__ with proper backoffs
	- Scale well
	- More network load
- __Ticket lock__ with proper backoffs 
	- Scale well
	- More network load
- __Array-based locks__
	- Scales best
	- Least interconnect contention
	- High space requirement for large numbers of CPUs
	- Fair
- __MCS__
	- Scales best
	- Least interconnect contention
	- Low space requirement
	- Fair
	- Benefits from __compare-and-swap__



















