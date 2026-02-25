# How Computers Work

> **Track:** [00 — Foundations](./index.md)
> **Level:** Beginner
> **Prerequisites:** None

---

## What You'll Learn

- What a CPU does and why it matters
- The difference between RAM and storage
- How binary and hexadecimal relate to everything you write
- What an operating system does on your behalf

## Why It Matters

Every bug, every performance problem, every security vulnerability has a physical
root. When you understand the hardware layer, you stop being surprised by things
like "why does my program crash when memory runs out" or "why is reading from disk
so slow."

---

## Core Concepts

### The CPU — Your Program's Engine

The CPU executes instructions one at a time (or in parallel via cores). Each
instruction is simple: add two numbers, move data from one place to another,
jump to a different instruction.

Your high-level code (Python, JavaScript) gets translated into these primitive
instructions before the CPU touches it. Understanding this explains why some
code is faster than other code.

**Key ideas:**
- Clock speed (GHz) = rough instructions per second
- Cores = independent instruction streams
- Cache (L1/L2/L3) = tiny, ultra-fast memory near the CPU

### RAM — Working Memory

RAM holds data your program is actively using. It's fast but volatile (erased
when power is cut). Everything your program reads, writes, and computes lives
here while it runs.

**Key ideas:**
- Size determines how many things you can hold at once
- Access is random — any byte is equally fast to reach
- Your OS manages which program gets which RAM (virtual memory)

### Storage — Long-Term Memory

SSDs and HDDs hold data even when power is off. Much slower than RAM.
When your program opens a file, data travels: disk → RAM → CPU.

**Key ideas:**
- Files live on disk; your program loads them into RAM to use them
- The filesystem is the organization layer (directories, names, permissions)

### The Operating System

The OS is the software layer between your programs and the hardware. It:
- Manages memory allocation across all running programs
- Handles disk I/O, network I/O, and display output
- Provides the shell and filesystem you use every day
- Enforces security and permissions

> See: [Linux docs](../../../../03-systems/linux/) and
> [Unix reference](../../../../03-systems/unix/)

### Binary and Hexadecimal

Computers store everything as 1s and 0s (bits). A byte = 8 bits.
Hexadecimal (base 16) is a compact way to write bytes: `0xFF = 255 decimal`.

You'll encounter hex constantly: color codes, memory addresses, byte sequences,
file magic numbers.

---

## Exercises

1. **Observe your RAM**: Open a terminal and run `free -h` (Linux) or open
   Activity Monitor (macOS) → Memory tab. Watch what happens when you open a
   heavy application.

2. **Find your CPU info**: Run `lscpu` (Linux) or `sysctl -n machdep.cpu.brand_string`
   (macOS). How many cores? What clock speed?

3. **Convert numbers**: Convert these by hand, then verify:
   - `0xFF` → decimal
   - `255` → binary
   - `42` → hex

4. **Explore the filesystem**: Open a terminal and run `df -h`. Where is your
   storage mounted? How much is free?

---

## Check Your Understanding

- What's the difference between RAM and an SSD?
- Why does your computer feel slow when RAM is full?
- If a program crashes, does it corrupt your files on disk?
- What does the OS do when two programs want the same memory address?

---

## Next Steps

→ [Command Line Basics](./02-command-line-basics.md)
→ [Track Index](./index.md)
