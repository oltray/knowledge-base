# Processes and the Kernel

> **Track:** [Systems](./index.md)
> **Level:** Intermediate
> **Prerequisites:** [How Computers Work](../00-foundations/01-how-computers-work.md)

---

## What You'll Learn

- What the kernel does and how user programs talk to it
- How processes are created, identified, and terminated
- What signals are and how the OS uses them to manage processes
- How to observe what your programs actually do with `strace` and `/proc`

## Why It Matters

Every program you write runs as a process managed by the kernel. Understanding that
boundary — user space vs kernel space, the syscall interface — explains why some
things require elevated permissions, why processes can be killed, and why your program
can't just access any memory address it wants.

---

## Background Reading

- [Linux man pages](../../../../03-systems/linux/)

Look for: `man 2 intro` (overview of Linux syscalls), `man 1 ps`, `man 1 strace`.
The `man 2` section covers syscalls; `man 1` covers user commands.

---

## Core Concepts

### Kernel Space vs User Space

The CPU has privilege levels. The kernel runs at the highest level (ring 0) and can
do anything: access hardware, manage memory, schedule processes. User programs run
at a lower level (ring 3) and cannot directly touch hardware.

To do anything privileged — read a file, send network data, create a new process —
a user program makes a **syscall**: a controlled jump into kernel code.

```bash
# See every syscall your program makes:
strace ls /tmp
# Output: openat, getdents64, close, write... each line is one syscall
```

### Processes

A process is an instance of a running program. The kernel gives each process:
- A unique **PID** (process ID)
- Its own **virtual address space** (it thinks it owns all of memory)
- File descriptors (open files, sockets, pipes)
- A parent process (every process has one, except PID 1)

```bash
ps aux            # list all processes
ps aux | grep python   # find Python processes
pstree            # show parent-child hierarchy
```

Every process has a parent. When a shell runs `ls`, it:
1. **forks** — creates a copy of itself (new PID, same memory)
2. The child **execs** — replaces itself with the `ls` program
3. The shell **waits** — blocks until `ls` exits
4. The child **exits** — returns an exit code to the parent

```bash
# See this yourself:
strace -e trace=process sh -c "ls /tmp" 2>&1 | grep -E "clone|execve|wait|exit"
```

### Signals

Signals are asynchronous notifications the kernel sends to processes.

| Signal | Number | Meaning |
|--------|--------|---------|
| SIGTERM | 15 | Please terminate (can be caught) |
| SIGKILL | 9 | Terminate immediately (cannot be caught) |
| SIGINT | 2 | Interrupt (Ctrl+C) |
| SIGHUP | 1 | Terminal closed / reload config |
| SIGCHLD | 17 | Child process changed state |

```bash
kill -15 <PID>    # politely ask process to exit (SIGTERM)
kill -9 <PID>     # force-kill (SIGKILL)
kill -l           # list all signals
```

A process can install a **signal handler** — a function that runs when the signal
arrives. SIGKILL and SIGSTOP cannot be caught, blocked, or ignored.

### /proc — The Kernel's Window

`/proc` is a virtual filesystem — it has no disk backing. The kernel generates its
contents on-the-fly to expose process state:

```bash
ls /proc/$$           # $$ = current shell's PID
cat /proc/$$/status   # name, state, PID, PPID, memory usage
cat /proc/$$/cmdline  # the command that started this process
ls -la /proc/$$/fd    # open file descriptors
cat /proc/cpuinfo     # CPU details
cat /proc/meminfo     # memory statistics
```

---

## Exercises

1. **strace a command**: Run `strace -c ls /tmp` (summary mode). Which syscall is
   called most often? What does it do? Look it up: `man 2 <syscall-name>`.

2. **Process tree**: Run `pstree -p` and find your terminal. Trace the parent chain
   from your shell up to PID 1. How many levels deep is it?

3. **Signal handling**: Run `sleep 100 &` to background a process. Find its PID with
   `jobs -l`. Send it SIGTERM. Then try the same with SIGKILL. What's the difference
   in how the shell reports it?

4. **/proc exploration**: Pick any running process. Look at its `/proc/PID/status`,
   `/proc/PID/cmdline`, and `/proc/PID/fd`. What files does it have open?

---

## Check Your Understanding

- What is the difference between kernel space and user space?
- What happens at the OS level when a shell runs a command like `ls`?
- Why can't you catch SIGKILL?
- What is `/proc` and where does its content come from?
- What does `strace` show you, and why is it useful for debugging?

---

## Next Steps

→ [Memory Layout](./02-memory-layout.md)
→ [Track Index](./index.md)
