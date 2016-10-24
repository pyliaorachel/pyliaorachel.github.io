---
layout: post
title:  "Operating System - Unix & Pthread"
categories: Blog Notes OS
tags: ["OS", "ECE344", "unix", "pthread"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Process-Related Unix System Calls
2. Posix Thread

<!--more-->
---
## Process-Related Unix System Calls

- A `process` in Unix consistes of an `address space` & a `thread`
- API
	- `getpid()`, `getppid()`
		- Pid identifies `address space` & `thread`
	- `fork()`, `execv()`
		- Create `processes`
	- `exit()`, `wait()`
		- Terminate `processes` & synchronize with terminating `process`
	- `kill()`, `sigaction()`
		- Communicate with another `process` via `signals`
- `fork()`
	- Create `childe process` from `parent process` with an identical copy of:
		- `Thread state`
		- `Address space`

	```
	int n = 5;
	int pid = fork(); 
	if (pid == 0) {
		// run child code
		n = n + 1;
	} else { // pid value > 0
		// run parent code
		n = n - 1;
	}
	```

- `execv()`
	- Replaces current `process` with a new `program`:
		- Loaded from disk
		- `Code` & `data` copied from disk
		- `Stack` initialized with activation frame of `main()`
		- `Processor registers` reinitialized
		- `Pid` stays the same
		- Doesn't return

	```
	char *cmd = "/bin/ls"; 
	char *arg1 = "-l"; 
	char *args[3];
	args[1] = arg1; 
	args[2] = NULL;
	execv(cmd, args);
	// code doesn’t execute
	```
	- `fork()` + `execv()` can run a new program as a new process with the old one kept

- `exit(retval)`
	- Terminate itself:
		- `Address space` destroyed
		- Process-specific OS state destroyed (e.g. open files)
		- `retval` saved & return to `parent process`
			- For `parent process` to learn about `child process`
		- `Thread state` destroyed
- `wait()`
	- Wait for `child process` to terminate; synchronize with `child processes`
	- Returns `retval` returned from `exit()`
	- 4 cases:
		- `W` wait starts, `C` continue, `E` exit starts, `D` exit done

		```
		# Semaphore required for 1, 2, 3

		1.
				 down(c)  up(p)
		Parent ---> W	   C----->
						  / \
		Child  --------> E   D
					  up(c) down(p)

		2.

		Parent --------> WC----->
						 / \
		Child  ------> E  | D			# OS keeps child exit retval until wait() is issued by parent,
					(zombie process)	# or destroyed when parent exits
		
		3.

		Parent --------> E
					    / \
		Child  -----> E    D

		4.

		Parent ---> E

		Child  --------> ED
		```
		- Each `child process` needs a pair of `semaphore`

- `kill()`
	- Process send signals to itself or other `processes` by calling `kill` system call
	- Receiver executes `signal handler`; if not setup, forced to exit
	- Receiver process exits when scheduled to run next
		- Because if receiver is holding the lock, it must be released by itself instead of other threads
- `sigaction()`
	- Setup `signal handler` function

## Posix Thread

- Allows creating additional threads in a `Unix process`
- API
	- `pthread_create(thread, attr, start_routine, arg)`
	- `pthread_exit(status)`
		- Returns `status` to a joining thread
	- `pthread_join(thread_id, status)`
		- Block thread until thread with `thread_id` terminates
	- `pthread_yield()`
- Synchronization API
	- __Mutex__

		```
		pthread_mutex_t mut = PTHREAD_MUTEX_INITIALIZER;
		pthread_mutex_lock(&mut);
		pthread_mutex_unlock(&mut)
		```

	- __Monitor__

		```
		int x,y;
		pthread_mutex_t mut = PTHREAD_MUTEX_INITIALIZER; 
		pthread_cond_t cond = PTHREAD_COND_INITIALIZER;

		pthread_mutex_lock(&mut); 
		while (x <= y) {
			pthread_cond_wait(&cond, &mut); 
		}
		/* operate on x and y */ 
		pthread_mutex_unlock(&mut);
		```
		```
		pthread_mutex_lock(&mut);
		/* modify x and y */
		if (x > y) 
			pthread_cond_signal(&cond); 
		pthread_mutex_unlock(&mut);
		```

	- __Semaphores__

		```
		sem_t sem name;
		sem_init(&sem_name, 0, 0); // (_, flag, init value)
		sem_wait(&sem_name);
		sem_post(&sem);
		```
















