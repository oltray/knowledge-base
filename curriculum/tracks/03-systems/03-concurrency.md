# Concurrency

> **Track:** [Systems](./index.md)
> **Level:** Intermediate
> **Prerequisites:** [Memory Layout](./02-memory-layout.md)

---

## What You'll Learn

- The difference between processes and threads
- What a race condition is and why it's hard to reproduce
- How mutexes, semaphores, and condition variables work
- What deadlock is, how to recognize it, and how to prevent it

## Why It Matters

Modern hardware has multiple cores. To use them, programs use threads or processes.
But sharing state between concurrent workers is the source of an entire class of
bugs — races, deadlocks, priority inversions — that are notoriously hard to debug.
Understanding the primitives gives you the vocabulary to reason about them.

---

## Background Reading

- [Linux man pages](../../../../03-systems/linux/)

Look for: `man 7 pthreads` (POSIX threads overview), `man 3 pthread_mutex_lock`,
`man 7 sem_overview`.

---

## Core Concepts

### Processes vs Threads

| | Process | Thread |
|---|---|---|
| Memory | Own address space | Shared address space |
| Creation cost | High (fork = copy) | Low (same memory) |
| Failure isolation | Yes (crash doesn't spread) | No (one thread can crash all) |
| Communication | IPC (pipes, sockets, shared mem) | Shared variables (direct) |
| Use when | Isolation matters | Speed and shared state matter |

A program can have many threads, all running in the same address space. They share
global variables, heap, and file descriptors — but each has its own stack.

```python
import threading

def worker(name):
    print(f"Thread {name} running")

threads = [threading.Thread(target=worker, args=(i,)) for i in range(4)]
for t in threads: t.start()
for t in threads: t.join()   # wait for all to finish
```

### Race Conditions

A race condition occurs when two threads access shared state concurrently and the
result depends on scheduling order.

```python
import threading

counter = 0

def increment():
    global counter
    for _ in range(100_000):
        counter += 1   # NOT atomic: read → add → write (3 steps)

t1 = threading.Thread(target=increment)
t2 = threading.Thread(target=increment)
t1.start(); t2.start()
t1.join(); t2.join()

print(counter)   # Expected: 200000. Actual: something less, varies each run
```

`counter += 1` looks like one operation but compiles to three: read `counter`,
add 1, write back. Two threads can interleave these steps, losing updates.

**Why they're hard**: races are timing-dependent. They may not appear in testing
but surface under load or on different hardware.

### Mutexes (Mutual Exclusion Locks)

A mutex allows only one thread to hold it at a time. Others block until it's released.

```python
import threading

counter = 0
lock = threading.Lock()

def safe_increment():
    global counter
    for _ in range(100_000):
        with lock:        # acquire lock, release on exit
            counter += 1  # only one thread here at a time

t1 = threading.Thread(target=safe_increment)
t2 = threading.Thread(target=safe_increment)
t1.start(); t2.start()
t1.join(); t2.join()

print(counter)   # Always 200000
```

The critical section (code inside `with lock`) runs atomically from other threads'
perspectives.

### Semaphores

A semaphore is a counter. `acquire()` decrements it (blocks if 0); `release()`
increments it. Used to limit concurrent access to a resource.

```python
import threading, time

# Allow at most 3 concurrent "connections"
semaphore = threading.Semaphore(3)

def connect(worker_id):
    with semaphore:
        print(f"Worker {worker_id} connected")
        time.sleep(1)
        print(f"Worker {worker_id} disconnected")

threads = [threading.Thread(target=connect, args=(i,)) for i in range(8)]
for t in threads: t.start()
for t in threads: t.join()
# At most 3 "connected" lines appear simultaneously
```

A **binary semaphore** (max value 1) behaves like a mutex, but can be released
by a different thread than acquired it — useful for signaling.

### Condition Variables

A condition variable lets a thread wait until some condition becomes true, without
busy-waiting (spinning in a loop).

```python
import threading

queue = []
condition = threading.Condition()

def producer():
    for i in range(5):
        with condition:
            queue.append(i)
            condition.notify()   # wake one waiting thread

def consumer():
    for _ in range(5):
        with condition:
            while not queue:
                condition.wait()  # release lock and sleep until notified
            item = queue.pop(0)
        print(f"Consumed {item}")

t1 = threading.Thread(target=producer)
t2 = threading.Thread(target=consumer)
t2.start(); t1.start()
t1.join(); t2.join()
```

### Deadlock

Deadlock occurs when two (or more) threads each hold a lock the other needs,
and neither can proceed.

```
Thread A holds Lock 1, waits for Lock 2
Thread B holds Lock 2, waits for Lock 1
→ both wait forever
```

**Necessary conditions** (all four must hold for deadlock):
1. **Mutual exclusion** — resources can't be shared
2. **Hold and wait** — thread holds a resource while waiting for another
3. **No preemption** — resources can't be forcibly taken
4. **Circular wait** — circular chain of threads waiting on each other

**Prevention**: always acquire locks in the same order across all threads.
If every thread takes Lock 1 before Lock 2, circular wait can't happen.

**Note on Python's GIL**: CPython has a Global Interpreter Lock — only one thread
executes Python bytecode at a time. This prevents true CPU parallelism for
CPU-bound work (use `multiprocessing` instead), but the concurrency bugs above
can still appear because the GIL is released between bytecode instructions.

---

## Exercises

1. **Reproduce a race**: Run the unsynchronized `counter` example multiple times.
   Does the result vary? Add print statements inside the loop to slow it down.
   Does that change things? Why?

2. **Fix the race**: Add a `threading.Lock()` to the counter example. Verify the
   result is always 200000.

3. **Deadlock demo**: Write code that creates two locks and two threads that acquire
   them in opposite order. Run it and confirm it hangs. Then fix it by enforcing
   consistent lock ordering.

4. **Semaphore rate limiter**: Use a semaphore to limit a pool of 10 threads to
   at most 3 running simultaneously. Use `time.sleep(0.5)` to simulate work.
   Observe the output timing.

---

## Check Your Understanding

- What's the difference between a process and a thread?
- Why does `counter += 1` cause a race condition even though it looks atomic?
- What does a mutex guarantee? What is the "critical section"?
- Describe the four conditions required for deadlock.
- What is Python's GIL and why does it matter (or not) for these exercises?

---

## Next Steps

→ [File Descriptors and IPC](./04-file-descriptors-and-ipc.md)
→ [Track Index](./index.md)
