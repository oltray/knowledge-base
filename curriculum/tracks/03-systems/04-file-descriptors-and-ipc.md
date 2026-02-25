# File Descriptors and IPC

> **Track:** [Systems](./index.md)
> **Level:** Intermediate
> **Prerequisites:** [Concurrency](./03-concurrency.md)

---

## What You'll Learn

- What file descriptors are and why Unix treats everything as a file
- How stdin, stdout, and stderr connect processes to the world
- How pipes pass data between processes
- What Unix sockets are and when to use them
- What memory-mapped files (mmap) are and when they matter

## Why It Matters

IPC (Inter-Process Communication) is how every program interacts with the world
and with other programs — reading config files, writing logs, talking to databases,
responding to HTTP requests. All of it flows through file descriptors. Understanding
this abstraction makes shell pipelines, network code, and process communication
much less mysterious.

---

## Background Reading

- [Linux man pages](../../../../03-systems/linux/)

Look for: `man 2 open`, `man 2 read`, `man 2 write`, `man 2 pipe`,
`man 7 unix` (Unix sockets), `man 2 mmap`, `man 1 lsof`.

---

## Core Concepts

### Everything Is a File

Unix represents almost everything as a file descriptor (fd) — an integer that
refers to an open kernel object:

| fd type | Examples |
|---|---|
| Regular file | `open("data.txt", O_RDONLY)` |
| Directory | `opendir("/tmp")` |
| Pipe | `pipe(fds)` |
| Terminal | `/dev/tty` |
| Socket | `socket(AF_INET, SOCK_STREAM, 0)` |
| Device | `/dev/null`, `/dev/urandom` |

Every process starts with three open fds:

| fd | Name | Default |
|---|---|---|
| 0 | stdin | keyboard |
| 1 | stdout | terminal |
| 2 | stderr | terminal |

```bash
# See all open file descriptors for your shell:
ls -la /proc/$$/fd
# 0 → /dev/pts/0  (terminal)
# 1 → /dev/pts/0
# 2 → /dev/pts/0
```

### Redirection

The shell manipulates file descriptors before exec-ing a command:

```bash
command > out.txt        # stdout (fd 1) → file
command 2> err.txt       # stderr (fd 2) → file
command > out.txt 2>&1   # both stdout and stderr → file
command < in.txt         # stdin (fd 0) ← file
command &> all.txt       # both → file (bash shorthand)
```

The command itself doesn't know the difference — it just writes to fd 1.

### Pipes

A pipe is a kernel buffer connecting two file descriptors: write end and read end.
When a process writes to the write end, data waits in the buffer until the read end
reads it.

```bash
# Shell pipe: stdout of ls becomes stdin of grep
ls /etc | grep conf
```

Under the hood:
1. Kernel creates a pipe (two fds)
2. Shell forks twice: `ls` gets pipe-write as stdout; `grep` gets pipe-read as stdin
3. `ls` writes its output; `grep` reads it
4. When `ls` exits (closes write end), `grep` gets EOF

```python
import subprocess

# Python subprocess pipe
result = subprocess.run(
    ['grep', 'conf'],
    input=subprocess.run(['ls', '/etc'], capture_output=True).stdout,
    capture_output=True, text=True
)
print(result.stdout)
```

```bash
# Named pipe (FIFO) — pipe that lives on the filesystem:
mkfifo /tmp/mypipe
echo "hello" > /tmp/mypipe &   # blocks until reader connects
cat /tmp/mypipe                 # reads and the echo unblocks
```

### Unix Sockets

A Unix domain socket is like a network socket but local to the machine — no TCP
overhead. Processes communicate via a socket file on the filesystem.

```bash
ls /var/run/*.sock   # common location for Unix sockets
# docker.sock, systemd/private/stdout, etc.

# See what's connecting to Docker's socket:
sudo lsof /var/run/docker.sock
```

Unix sockets vs network sockets:
- **Unix socket**: same machine only, path-based, faster
- **Network socket**: any machine, IP+port, full TCP/IP overhead

Databases (PostgreSQL, Redis, MySQL) use Unix sockets for local connections by
default — it's why `psql` works without specifying a host.

### lsof — List Open Files

`lsof` shows every open file descriptor on the system:

```bash
lsof -p $$              # all fds for current shell
lsof -i :8080           # what's listening on port 8080
lsof /var/log/syslog    # what processes have this file open
lsof -u alice           # all files opened by user alice
```

### mmap — Memory-Mapped Files

`mmap` maps a file into the process's virtual address space. Reading the memory
reads the file; writing to the memory writes the file. No explicit read/write
syscalls needed.

```python
import mmap

with open("data.bin", "r+b") as f:
    mm = mmap.mmap(f.fileno(), 0)
    print(mm[:10])        # read first 10 bytes
    mm[0:5] = b"hello"    # write to the file via memory
    mm.close()
```

Use cases:
- Large files: read only the pages you access (kernel handles loading)
- Shared memory between processes: two processes map the same file
- Executable loading: the kernel mmaps the executable's text segment

---

## Exercises

1. **fd inspection**: Run `ls -la /proc/$$/fd`. What does each fd point to?
   Open a file in your shell with `exec 3< /etc/hostname` and check again.
   Close it with `exec 3<&-`.

2. **Pipe timing**: Run `yes | head -5`. What does `yes` do? Why does `yes` stop
   when `head` exits? What signal does the kernel send?

3. **strace file ops**: Run `strace -e trace=file cat /etc/hostname 2>&1`.
   Identify the `openat`, `read`, and `close` syscalls. What are the fd numbers?

4. **lsof exploration**: Find a long-running process (your browser, a server).
   Run `lsof -p <PID>`. How many file descriptors does it have open? What types?

5. **Named pipe**: Create a FIFO with `mkfifo /tmp/test`. In one terminal, run
   `cat /tmp/test`. In another, run `echo "hello" > /tmp/test`. What happens?
   Clean up: `rm /tmp/test`.

---

## Check Your Understanding

- What is a file descriptor? What are the three every process starts with?
- What happens at the OS level when you run `ls | grep conf`?
- What is the difference between a named pipe (FIFO) and an unnamed pipe?
- When would you use a Unix socket instead of a network socket?
- What does `mmap` do, and what advantage does it have over `read`/`write`?

---

## Next Steps

→ [Track Index](./index.md)
→ [Curriculum Overview](../../overview.md)
