# Files and Directories

> **Track:** [00 — Foundations](./index.md)
> **Level:** Beginner
> **Prerequisites:** [Command Line Basics](./02-command-line-basics.md)

---

## What You'll Learn

- How Unix filesystems are structured (everything is a file)
- File permissions: what they mean and how to change them
- Absolute vs. relative paths
- Essential file operations: create, copy, move, delete
- Hard links vs. symbolic links

## Why It Matters

Every program you write reads or writes files. Understanding paths, permissions,
and the filesystem layout prevents the "file not found" and "permission denied"
errors that confuse beginners endlessly.

---

## Background Reading

- [Linux docs](../../../../03-systems/linux/) — look for filesystem section
- [Unix reference](../../../../03-systems/unix/) — POSIX filesystem conventions

---

## Core Concepts

### The Unix Filesystem Tree

Everything hangs from a single root `/`. There are no drive letters.

```
/
├── bin/        System programs (ls, cp, etc.)
├── etc/        System configuration files
├── home/       User home directories
│   └── you/    Your home directory (~)
├── tmp/        Temporary files (cleared on reboot)
├── usr/        User-installed programs
│   └── local/  Locally installed programs
└── var/        Variable data (logs, databases)
```

macOS has a similar layout but with some differences (`/Applications`, etc.).

### Paths

- **Absolute**: starts with `/` — always the same regardless of where you are
  - `/home/you/Documents/notes.txt`
- **Relative**: starts from current directory — changes based on `pwd`
  - `Documents/notes.txt` (if you're in `/home/you/`)
  - `../sibling-dir/file.txt` (one level up, then into sibling)

Special path components:
- `.` = current directory
- `..` = parent directory
- `~` = your home directory

### File Permissions

```
-rwxr-xr--  1 alice staff  4096 Jan 10 12:00 script.sh
^            ^       ^
type+perms   owner   group
```

Permissions come in three groups: **owner, group, others**.
Each group has three bits: **read (r), write (w), execute (x)**.

| Mode | Meaning |
|---|---|
| `r` | Read the file's contents |
| `w` | Write/modify the file |
| `x` | Execute (run as a program) |

For directories: `x` means you can `cd` into it; `r` means you can `ls` it.

```bash
chmod +x script.sh        # Make executable
chmod 644 file.txt        # rw-r--r-- (owner rw, group r, others r)
chmod 755 directory/      # rwxr-xr-x (owner all, others rx)
```

### Essential File Operations

```bash
touch newfile.txt         # Create empty file
mkdir newdir/             # Create directory
mkdir -p a/b/c/           # Create nested directories at once
cp file.txt copy.txt      # Copy a file
cp -r dir/ copy-dir/      # Copy a directory recursively
mv file.txt new-name.txt  # Rename/move a file
rm file.txt               # Delete a file
rm -r directory/          # Delete a directory and contents (irreversible!)
```

### Symbolic Links

A symlink is a pointer to another file or directory. The symlink has its own
path but redirects all access to the target.

```bash
ln -s /path/to/target linkname     # Create a symlink
ls -la linkname                    # Shows: linkname -> /path/to/target
```

Common use: making a deeply nested path accessible from a convenient location.

---

## Exercises

1. **Explore system directories**: Run `ls /`, then `ls /etc | head -20`. What
   kinds of files live in `/etc`?

2. **Permission experiment**: Create a script file, remove execute permission,
   try to run it. Add execute permission back, try again.
   ```bash
   echo '#!/bin/bash\necho hello' > test.sh
   chmod -x test.sh && ./test.sh   # Should fail
   chmod +x test.sh && ./test.sh   # Should succeed
   ```

3. **Path navigation**: From your home directory, navigate to `/tmp` using only
   relative paths. (Hint: how many `..` do you need?)

4. **Create a symlink**: Create a directory, put a file in it, then create a
   symlink from your home directory pointing to that file. Access the file via
   the symlink.

---

## Check Your Understanding

- What's the difference between `rm file` and `rm -r dir/`?
- Why does a script need execute permission even though you have read permission?
- What does `chmod 700` mean in plain language?
- Can two files have the same inode? (Research: hard links vs. symlinks)

---

## Next Steps

→ [Networking Intuition](./04-networking-intuition.md)
→ [Track Index](./index.md)
