# Track 03 — Systems

> **Level:** Intermediate
> **Goal:** Understand how the OS manages processes, memory, concurrency, and I/O at the syscall level

---

## Why Systems

Every program runs inside an operating system that controls what it can do. When
code misbehaves — crashes, leaks memory, deadlocks, blocks on I/O — the explanation
is always in the OS layer. This track gives you the mental model to reason about
what your programs are actually doing.

---

## Modules

| # | Module | Description |
|---|---|---|
| 1 | [Processes and the Kernel](./01-processes-and-the-kernel.md) | Syscall interface, process lifecycle, signals |
| 2 | [Memory Layout](./02-memory-layout.md) | Virtual memory, address space, stack vs heap |
| 3 | [Concurrency](./03-concurrency.md) | Threads, race conditions, mutexes, deadlock |
| 4 | [File Descriptors and IPC](./04-file-descriptors-and-ipc.md) | Everything-is-a-file, pipes, sockets, mmap |

---

## Prerequisites

- [Track 00 — Foundations](../00-foundations/index.md)

---

## Local Documentation

Linux man pages: `../../../../03-systems/linux/`

---

## What Comes Next

- [Track 01 — Languages: C / C++](../01-languages/c-cpp/index.md) — implement syscalls directly in C
- [Track 01 — Languages: Rust](../01-languages/rust/index.md) — safe systems programming

---

→ [Curriculum Overview](../../overview.md)
