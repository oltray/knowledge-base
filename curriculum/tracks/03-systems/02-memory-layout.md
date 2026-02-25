# Memory Layout

> **Track:** [Systems](./index.md)
> **Level:** Intermediate
> **Prerequisites:** [Processes and the Kernel](./01-processes-and-the-kernel.md)

---

## What You'll Learn

- How a process's virtual address space is organized
- The difference between stack, heap, BSS, text, and data segments
- How the stack grows and why it can overflow
- What virtual memory is and how the MMU translates addresses
- How to read `/proc/PID/maps` to see a live process's memory layout

## Why It Matters

Memory bugs — segfaults, buffer overflows, memory leaks, use-after-free — all have
explanations rooted in this layout. Once you know where the stack ends and the heap
begins, "stack overflow" and "heap corruption" stop being magic words and become
specific, diagnosable problems.

---

## Background Reading

- [Linux man pages](../../../../03-systems/linux/)

Look for: `man 5 proc` (the `/proc` filesystem), `man 1 pmap`.

---

## Core Concepts

### Virtual Memory

Each process thinks it has the entire address space to itself — typically 0 to
2^64 on 64-bit systems. This is an illusion maintained by the **MMU** (Memory
Management Unit) and the kernel.

The MMU translates **virtual addresses** (what your program uses) to **physical
addresses** (actual RAM locations). This gives every process:
- **Isolation** — one process can't read another's memory
- **More memory than RAM** — pages can be swapped to disk
- **Flexible layout** — same virtual address can mean different physical locations

When a program accesses a virtual address with no physical page mapped, a **page
fault** occurs. The kernel handles it: maybe it allocates a new page, maybe it
loads a page from swap, or maybe it kills the process (segfault).

### Address Space Layout

A typical 64-bit Linux process looks like this (low address at top):

```
0x0000000000000000  (unmapped — NULL dereferences caught here)
─────────────────────────────────
.text    — program code (read-only, executable)
.rodata  — string literals, const data (read-only)
.data    — initialized global/static variables
.bss     — uninitialized global/static variables (zero-filled)
─────────────────────────────────
           heap  ↑ (grows upward, managed by malloc/free)
           ...
           ...
           stack ↓ (grows downward, managed automatically)
─────────────────────────────────
kernel space     (not accessible from user space)
0xFFFFFFFFFFFFFFFF
```

### The Stack

The stack holds:
- Local variables
- Function arguments
- Return addresses (where to jump back after a function returns)

Each function call **pushes a stack frame**. When the function returns, the frame
is **popped**. This is automatic — you don't manage it.

```python
def c():
    x = 3          # x lives on the stack, in c's frame
    return x

def b():
    result = c()   # c's frame pushed on top of b's frame
    return result

def a():
    b()            # b's frame pushed on top of a's frame

a()
```

**Stack overflow** happens when recursion (or function calls) pushes frames faster
than they're popped, exhausting the stack's fixed size (typically 1–8 MB).

```python
def infinite():
    return infinite()   # each call adds a frame, never returns

infinite()  # RecursionError: maximum recursion depth exceeded
```

### The Heap

The heap holds dynamically allocated memory — objects, arrays, anything whose
size isn't known at compile time.

- In C: `malloc()` allocates, `free()` releases
- In Python/JS: the runtime manages allocation and garbage collection for you
- The heap grows upward from a low address

**Memory leak**: allocating heap memory and never freeing it. In garbage-collected
languages this is rare but possible (keeping references to objects you no longer need).

### Reading /proc/PID/maps

```bash
# See your shell's memory layout:
cat /proc/$$/maps
```

Each line: `address-range permissions offset device inode path`

```
55a3c8400000-55a3c8401000 r--p 00000000 fd:01 123456 /bin/bash  ← .text
7ffd5e200000-7ffd5e221000 rw-p 00000000 00:00 0      [stack]    ← stack
7f8a1c000000-7f8a1e000000 rw-p 00000000 00:00 0                  ← heap
```

```bash
# More readable summary:
pmap $$
```

---

## Exercises

1. **Find the stack**: Run `cat /proc/$$/maps | grep stack`. What address range is
   it? How large is it in bytes?

2. **Heap growth**: Write a Python script that allocates a large list in a loop.
   In another terminal, watch `pmap <PID>` change as the heap grows.

3. **Trigger a page fault (safely)**: In Python, try `x = [0] * 10_000_000`.
   Does the allocation happen instantly? What is Python doing under the hood?

4. **Stack trace**: Run `python3 -c "def f(): f()
f()"` and read the error.
   What does "maximum recursion depth" tell you about how the stack works?

---

## Check Your Understanding

- What is virtual memory, and what problem does it solve?
- List the main segments of a process's address space. What lives in each?
- Why does the stack have a fixed size limit but the heap does not?
- What is a page fault? Give an example of one that's normal vs one that's fatal.
- What does `pmap <PID>` show you?

---

## Next Steps

→ [Concurrency](./03-concurrency.md)
→ [Track Index](./index.md)
