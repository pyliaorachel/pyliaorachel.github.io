---
layout: post
title:  "Operating System - Concurrent Programming"
categories: Blog Notes OS
tags: ["OS", "ECE344", "mutex", "synchronization"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Concurrent Programming
2. Mutual Exclusion
3. Synchronization

<!--more-->
---
## Concurrent Programming

- `Threads` cooperate to perform a common task by sharing data (global vars & heap data)
- Problems
	- __Race conditions__
		- `Thread interleaving` cause incorrect results
		- Access to shared variable must be exclusive
	- __Synchronization__
		- Ordering between threads must be enforced

## Mutual Exclusion

- `Atomic operation`
	- Operation appears _indivisible_; rest of the system either doesn't observe any of the effects, or all of them
	- Other threads may still run, but they should not observe any intermediate states of the operation
- `Mutual exclusion`
	- Only one thread can read/update shared variables at a time
- `Critical section`
	- The code region where `mutual exclusion` is enforced

### __Mutex Lock__

- `Critical sections` accessed in between `lock`, `unlock`
- Functions
	- `mutex = lock_create()`
	- `lock_destroy(mutex)`
	- `lock(mutex)`
		- If lock free: acquire lock
		- Else: wait/sleep until lock free
	- `unlock(mutex)`
		- Release lock
		- Wake up one of the waiting threads
- `Mutual exclusion` conditions
	- NO 2 threads in `critical section` at the same time
	- NO assumption on speed of thread execution
	- Thread running outside `critical section` CANNOT block another thread
	- NO thread must wait forever to enter its `critical section`

### __Mutex Implementation__

1. Variable tracking

	```
	lock(l) {
		while (l == TRUE)
			;
		l = TRUE;
	}
	unlock(l) {
		l = FALSE;
	}
	```
	- `l` is also a shared variable, so `lock` & `unlock` should be `atomic`

2. Make `lock` atomic

	```
	lock(l) {
		disable_interupts;
		while (l == TRUE)
			;
		l = TRUE;
	}
	unlock(l) {
		l = FALSE;
		enable_interupts;
	}
	```
	- Works only on _single core_

	> #### Multiprocessor H/W provides `atomic instructions`
	>	- `Test-and-set` lock, `compare-and-swap` lock
	>	- Operate on a memory word, perform 2 operations __indivisibly__ by CPU requesting the lock controller to lock out the memory location
	>
	>	```
	>		int tset(int *lock) { // atomic in H/W
	>			int old = *lock;
	>			*lock = 1;  ___> atomic
	>			return old; _|
	>		}
	>	```

3. `Spin locks`
	- Uses `tset` in a loop

	```
	// *l init to 0
	lock(int *l) {
		while (tset(1))
			;
	}
	unlock(int *l) {
		*l = FALSE;
	}
	```
	- Efficient only if `critical sections` are short
	- But `CPU` performs no useful working waiting in the loop -> __waste CPU__

4. `Yielding locks`

	```
	// *l init to 0
	lock(int *l) {
		while (tset(1))
			thread_yield();
	}
	unlock(int *l) {
		*l = FALSE;
	}
	```
	- But scheduler determines when it returns back -> __delay lock acquire__

5. `Blocking locks`
	- Unlike 3., 4. polling for locks, now `unlock` will wakeup threads sleeping in `lock`

	```
	// *l init to 0
	lock(int *l) {
		while (tset(1))
			thread_sleep();
	}
	unlock(int *l) {
		*l = FALSE;
		thread_wakeup();
	}
	```
	- Access shared `ready queue`, i.e. we need locking while implementing blocking

- Locking solutions
	- Multiprocessor

		```
						blocking lock    # manipulate queues
							  ↓
						  spin lock		 # loop on atomic instruction
						  	  ↓
					  atomic instruction # single instruction
		```

	- Uniprocessor
	
		```
						blocking lock
							  ↓
					  interrupt disabling
		```

- Which lock to use?

| Lock | When to use? |
|:-----|:-------------|
| Atomic instruction | Most efficient, use when available|
| Interrupt disabling, spin locks | Critical sections short & will not block |
| Blocking locks | Critical sections long & may block (__for synchronization__); overhead for context switch |

- How many locks to create?
	- 1 per individual data structure
	- More locks -> more parallelism BUT more bugs

- Why do we need `spin lock` when implementing `blocking lock`?
	- Avoid `lost wakeup` between checking availability of lock & sleep
	- Need another locking method to protect the shared ready queue

### __Deadlocks, Starvation, Livelock__

- `Deadlock`: a set of threads each waiting for a resource held by another thread
	- Conditions
		- __Mutual exclusion__
		- __Hold & wait__
		- __No premption__
		- __Circular wait__
	- Prevention
		- Release previously acquired locks? (hold & wait)
			- But modifications to data might have already happened
			- Or `livelock` when keep trying to acquire locks
		- Number each resources, need to acquire lower numbered resources before higher ones? (circular wait)
			- Difficult to number a whole bunch, and some of them are from third-party
- `Starvation`: a set of threads waiting for resources constantly used by others
- `Livelock`: a set of threads continue to num but make no progress
	- e.g. `interrupt livelock`: interrupts queueing up and suspend the running threads
		=> Can turn to `polling`, with intervals not too long
	- Need to ensure a thread runs for a while before switching

---
## Synchronization

- `Threads` wait on some conditions before proceeding

### __Motivation: Producer-Consumer Problem__

- Single producer & consumer
	
	```
	char buf[8];
	int in;
	int out;

	void send(char msg) {
		while ((in-out+n) % n == n-1)
			; // full
		buf[in] = msg;
		in = (in+1) % n;
	}

	char receive() {
		while (in == out)
			; // empty
		msg = buf[out];
		out = (out+1) % n;
		return msg;
	}
	```

- Multiple producers & consumers
	
	```
	# deadlock

	void send(char msg) {
		lock(l);
		while ((in-out+n) % n == n-1)
			; // full
		buf[in] = msg;
		in = (in+1) % n;
		unlock(l);
	}

	char receive() {
		lock(l);
		while (in == out)
			; // empty
		msg = buf[out];
		out = (out+1) % n;
		return msg;
		unlock(l);
	}
	```
	```
	# release locks before spinning - too tight

	void send(char msg) {
		lock(l);
		while ((in-out+n) % n == n-1) {
			unlock(l);
			lock(l);
		}
		buf[in] = msg;
		in = (in+1) % n;
		unlock(l);
	}

	char receive() {
		lock(l);
		while (in == out) {
			unlock(l);
			lock(l);
		}
		msg = buf[out];
		out = (out+1) % n;
		return msg;
		unlock(l);
	}
	```
	```
	# sleep after unlocking

	void send(char msg) {
		lock(l);
		while ((in-out+n) % n == n-1) {
			unlock(l);			____> atomic! Or else lost wakeup
			thread_sleep(full); __|
			lock(l);
		}
		buf[in] = msg;
		if (in == out)
			thread_wakeup(empty);
		in = (in+1) % n;
		unlock(l);
	}

	char receive() {
		lock(l);
		while (in == out) {
			unlock(l);
			thread_sleep(empty);
			lock(l);
		}
		msg = buf[out];
		if ((in-out+n) % n == n-1)
			thread_wakeup(full);
		out = (out+1) % n;
		unlock(l);
		return msg;
	}
	```
- Challenges
	- Can't spin or sleep while holding lock
		- `Deadlock`
	- Can't release lock and then sleep
		- `Lost wakeup`
	- Need to __unlock & sleep atomically__

### __Monitors__

- `Condition variable`
	- Used within `monitor methods`
	- Functions
		- `cv = cv_create()`
		- `cv_destroy(cv)`
		- `cv_wait(cv, lock)`
			- Lock released `atomically` while waiting
			- Lock reacquired after wait returns
		- `cv_signal(cv, lock)`
			- Wakeup one thread waiting on the condition
			- `Lost signal`: signal occurs before a wait
		- `cv_broadcast(cv, lock)`
			- Wakeup all threads waiting on the condition
- Basis

	```
	F() {
		int disabled = disaple_interrupt;
		do_work();
		enable_interrupt(disabled);
	}
	do_work(){
		int disabled = disaple_interrupt; // already disabled!
		...
		enable_interrupt(disabled);	// stay disabled
	}
	```

- `Producer-consumer` with `monitors`

	```
	buf[n], in, out;
	lock l = 0;
	cv full;
	cv empty;

	void send(char msg) {
		lock(l);
		while ((in-out+n) % n == n-1) {
			// put thread into wait queue for 'full' condition
			wait(full, l); // unlock + sleep + lock
		}
		buf[in] = msg;
		if (in == out)
			signal(empty, l);
		in = (in+1) % n;
		unlock(l);
	}

	char receive() {
		lock(l);
		while (in == out) {
			wait(empty, l);
		}
		msg = buf[out];
		if ((in-out+n) % n == n-1)
			signal(full, l);
		out = (out+1) % n;
		unlock(l);
		return msg;
	}
	```

- `Variable initialization` with `monitors`

	```
	Method1() {
		lock(l);
		V = malloc(...);
		signal(cv, l); // condition = V is null
		...
		unlock(l);
	}
	Method2() {
		lock(l);
		if (V == NULL)
			wait(cv, l); // condition = V is null
		assert(V);
		unlock(l);
	}
	```
	- `Lock` is for avoiding `lost wakeup` because `signal` CANNOT come before `wait`

### __Semaphores__

- Tracks number of available resources using `down` & `up`

	```
	# spinning (example with race condition on s)

	down() {
		while (s <= 0)
			;
		s--;
	}
	up() {
		s++;
	}
	```
	```
	# blocked
	
	down() {
		disable_interrupts;
		while (s <= 0)
			thread_sleep(s);
		s--;
		enable_interrupts;
	}
	up() {
		disable_interrupts;
		s++;
		thread_wakeup(s);
		enable_interrupts;
	}
	```
	- If `s` init to `1`, then behaves like `lock` & `unlock`
- Difference with `lock`
	- __Different__ threads call `down` & `up`
	- `up` can happen __before__ `down` to bank resource

- `Producer-consumer` with `semaphores`

	```
	buf[n], in, out;
	lock l;
	sem full = 0;
	sem empty = n;

	void send(char msg) {
		down(empty);
		lock(l);
		buf[in] = msg;
		in = (in+1) % n;
		unlock(l);
		up(full);
	}

	char receive() {
		down(full);
		lock(l); // this lock for buf, not for avoiding lost signal
		msg = buf[out];
		out = (out+1) % n;
		unlock(l);
		up(empty);
		return msg;
	}
	```

---
## __Quick Questions__
1. What is the difference between mutual exclusion and synchronization?
	- Mutex: used to ensure that only one thread accesses a critical section at a time, ensuring that operations are run atomically.
	- Synchronization: used to ensure threads wait on some condition.
2. Why are locks, by themselves, not sufficient for solving synchronization problems?
	- `Lock` & `unlock` are used together and in that order. Synchronization problems require a more general primitive: conditional `sleep` and `wakeup`.
3. What are the differences between a monitor and a semaphore?
	- `Monitor` requires locks to avoid lost signal. `Down/Up` & `wait/signal` are also different.
4. What are the differences between `wait()` and `down()`?
	- `Wait` is stateless, it always waits. `Wait` also releases a lock, waits, and then reacquires a lock. 
	- `Down` has state embedded with a notion of available resources, and will only wait if resources are not available. `Down` doesn’t have any notion of an associated lock.
5. What are the differences between `signal()` and `up()`?
	- `Signal` can be lost if no one is waiting, hence the need to use locks with condition variables, so that there is no race with `wait`. 
	- `Up` will always increase the resource available, so a future down can acquire the resource. 
6. Why might you prefer one over the other?
 	- `Semaphore`: resource counting problem
 	- `Monitor`: other problems, ensures mutual exclusion













