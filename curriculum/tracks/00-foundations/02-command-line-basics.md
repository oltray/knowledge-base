# Command Line Basics

> **Track:** [00 — Foundations](./index.md)
> **Level:** Beginner
> **Prerequisites:** [How Computers Work](./01-how-computers-work.md)

---

## What You'll Learn

- How to open and use a terminal
- The anatomy of a command: program, flags, arguments
- Essential navigation: `cd`, `ls`, `pwd`
- Getting help with `man` and `--help`
- Why developers prefer the command line for many tasks

## Why It Matters

The command line is the universal control plane for computers. Every server, every
CI/CD pipeline, every developer tool expects you to be comfortable here. Many
powerful tools have no graphical interface at all.

---

## Background Reading

Open your local Linux or Unix reference:

- [Linux docs](../../../../03-systems/linux/)
- [Unix reference](../../../../03-systems/unix/)

Look for any "getting started with the shell" or "bash" section.

---

## Core Concepts

### The Shell

The shell is a program that reads your text commands and runs them.
Common shells: `bash` (most Linux), `zsh` (macOS default), `sh` (minimal).

Your terminal emulator (Terminal.app, GNOME Terminal, Windows Terminal) runs
the shell. They are separate programs.

### Anatomy of a Command

```
ls  -la  /Users/you/Documents
^    ^         ^
|    |         |
program  flags  argument
```

- **Program**: what to run (`ls`, `cd`, `git`, `python`)
- **Flags**: options that modify behavior (`-l` = long format, `-a` = all files)
- **Arguments**: what to act on (a path, a filename, a URL)

Flags that start with `--` are "long" flags: `--help` vs `-h` (often equivalent).

### Essential Navigation Commands

| Command | What it does |
|---|---|
| `pwd` | Print working directory (where am I?) |
| `ls` | List files in current directory |
| `ls -la` | List all files with details (permissions, size, date) |
| `cd path/` | Change directory |
| `cd ..` | Go up one level |
| `cd ~` | Go to your home directory |
| `cd -` | Go back to previous directory |

### Getting Help

```bash
man ls          # Full manual page (press q to quit)
ls --help       # Quick help (most programs)
info ls         # Alternative to man on some systems
```

The `man` pages are your offline documentation for every system command.
They're always available and authoritative.

### Tab Completion

Press **Tab** once to auto-complete a command or path. Press **Tab twice** to
see all options when there are multiple matches. This saves enormous amounts of
typing and prevents typos in paths.

### Command History

- **Up/Down arrows**: scroll through previous commands
- `history`: show all past commands
- `Ctrl+R`: reverse-search through history (type part of a command to find it)

---

## Exercises

1. **Navigate your filesystem**: Open a terminal. Use `pwd`, `ls`, and `cd` to
   explore three different directories. Never lose track of where you are.

2. **Read a man page**: Run `man ls`. Find the flag that sorts files by
   modification time (hint: search with `/` then type a keyword).

3. **Tab completion drill**: Type `ls /us` then press Tab. Complete the path
   to `/usr/local/bin/` using only Tab. Count how many keystrokes you saved.

4. **History search**: Press `Ctrl+R` and type `ls`. Find a previous `ls`
   command from your history.

---

## Check Your Understanding

- What does `cd ..` do?
- How do you find out what flags `grep` accepts?
- What's the difference between a relative and absolute path?
- Why does `./myscript.sh` work but `myscript.sh` might not?

---

## Next Steps

→ [Files and Directories](./03-files-and-directories.md)
→ [Track Index](./index.md)
