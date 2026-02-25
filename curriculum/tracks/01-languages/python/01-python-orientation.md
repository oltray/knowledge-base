# Python Orientation

> **Track:** [Languages: Python](./index.md)
> **Level:** Beginner
> **Prerequisites:** [Command Line Basics](../../00-foundations/02-command-line-basics.md)

---

## What You'll Learn

- How to install Python and verify the installation
- How to use the Python REPL for interactive exploration
- How to write and run your first script
- How to navigate the local Python documentation

## Why It Matters

Getting comfortable with the REPL and the docs is more valuable than memorizing
syntax. Python ships with exceptional offline documentation — learning to use it
means you can answer your own questions without internet access.

---

## Background Reading

Open your local Python documentation:

- [Python docs](../../../../../01-languages/python/)

Look for the tutorial section and the library reference. Browse the table of
contents to get a feel for what's there.

---

## Core Concepts

### Installing Python

Most systems come with Python. Check what you have:

```bash
python3 --version   # Python 3.x.x
python --version    # May be Python 2 on older systems — avoid
```

If you need to install: the [Python docs](../../../../../01-languages/python/)
include installation instructions. On macOS: `brew install python3`.
On Debian/Ubuntu: `sudo apt install python3`.

### The REPL

REPL = Read-Eval-Print Loop. Start it:

```bash
python3
```

```python
>>> 2 + 2
4
>>> "hello" + " world"
'hello world'
>>> type(42)
<class 'int'>
>>> exit()
```

The REPL is your sandbox. Try anything — it can't break your system.

**The `help()` function** is essential:

```python
>>> help(str)          # Full docs for the str type
>>> help(str.split)    # Docs for a specific method
>>> help()             # Interactive help system
```

This works entirely offline. It's the same content as the HTML docs, available
anywhere you have Python.

### Your First Script

Create a file `hello.py`:

```python
name = input("What's your name? ")
print(f"Hello, {name}!")
```

Run it:

```bash
python3 hello.py
```

### Reading Python Errors

Python errors are informative. Read them bottom-up:

```
Traceback (most recent call last):
  File "hello.py", line 2, in <module>
    print(undefined_variable)
NameError: name 'undefined_variable' is not defined
```

The last line names the error type and explains it. The lines above show
where in the code the error occurred.

### Navigating the Docs

Your local Python docs include:
- **Tutorial** — learn by example
- **Library Reference** — every built-in module documented
- **Language Reference** — formal specification of the language
- **Glossary** — plain-English definitions

Start with the Tutorial for learning; use the Library Reference when you need
to know exactly what a function does.

---

## Exercises

1. **REPL exploration**: Start the REPL. Try at least 10 different expressions:
   math, strings, comparisons, `type()` calls. Use `help()` on at least two things.

2. **Read the docs**: Open the Python Tutorial in your local docs. Read the first
   two sections. What are the two styles of running Python covered?

3. **Write a script**: Create a script that asks for two numbers and prints their
   sum, difference, product, and quotient. Run it.

4. **Error reading**: Deliberately introduce an error into your script. Read the
   traceback and identify: the file, the line, the error type, and the message.

---

## Check Your Understanding

- What does REPL stand for?
- How do you get help on a function without internet access?
- What's the difference between running `python3 file.py` and opening the REPL?
- Why should you use `python3` instead of `python`?

---

## Next Steps

→ [Core Concepts](./02-core-concepts.md)
→ [Track Index](./index.md)
