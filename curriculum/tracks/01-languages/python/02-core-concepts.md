# Python Core Concepts

> **Track:** [Languages: Python](./index.md)
> **Level:** Beginner
> **Prerequisites:** [Python Orientation](./01-python-orientation.md)

---

## What You'll Learn

- Python's built-in types and when to use each
- Functions: defining, calling, returning values
- Control flow: if/elif/else, for, while
- Lists, dicts, and how to work with them
- Importing and using modules

## Why It Matters

These are the building blocks that compose into every Python program ever written.
Once you understand them, the rest of Python is mostly learning which library
functions to call.

---

## Background Reading

Open the Python Language Reference and Library docs:

- [Python docs](../../../../../01-languages/python/) — "Data Model" and "Built-in Types"

In the REPL, try `help(list)`, `help(dict)`, `help(str)` as you work through
this module.

---

## Core Concepts

### Types

Python's built-in types:

| Type | Example | Notes |
|---|---|---|
| `int` | `42` | Arbitrary precision |
| `float` | `3.14` | IEEE 754 double |
| `str` | `"hello"` | Immutable, Unicode |
| `bool` | `True` / `False` | Subclass of `int` |
| `list` | `[1, 2, 3]` | Ordered, mutable |
| `tuple` | `(1, 2, 3)` | Ordered, immutable |
| `dict` | `{"a": 1}` | Key-value, ordered (Python 3.7+) |
| `set` | `{1, 2, 3}` | Unordered, unique elements |
| `None` | `None` | The "nothing" value |

Use `type(x)` to inspect any value's type.

### Functions

```python
def greet(name, greeting="Hello"):
    """Return a greeting string."""
    return f"{greeting}, {name}!"

result = greet("Alice")           # "Hello, Alice!"
result = greet("Bob", "Hi")       # "Hi, Bob!"
```

Key points:
- Default arguments go last
- `return` sends a value back; without it, the function returns `None`
- The docstring (`"""..."""`) is accessible via `help(greet)`

### Control Flow

```python
# if/elif/else
x = 10
if x > 0:
    print("positive")
elif x < 0:
    print("negative")
else:
    print("zero")

# for loop (iterate over any sequence)
for item in ["a", "b", "c"]:
    print(item)

for i in range(5):         # 0, 1, 2, 3, 4
    print(i)

# while loop
count = 0
while count < 3:
    print(count)
    count += 1
```

### Lists and Dicts

```python
# Lists
fruits = ["apple", "banana", "cherry"]
fruits.append("date")           # Add to end
fruits[0]                       # "apple" (zero-indexed)
fruits[-1]                      # "cherry" (last element)
fruits[1:3]                     # ["banana", "cherry"] (slice)

# List comprehension
squares = [x**2 for x in range(10)]

# Dicts
person = {"name": "Alice", "age": 30}
person["name"]                  # "Alice"
person["city"] = "Portland"     # Add key
person.get("missing", "default")  # Safe access

# Dict comprehension
word_lengths = {word: len(word) for word in ["cat", "dog", "elephant"]}
```

### Modules

```python
import os
import os.path

# From a module, import specific names
from pathlib import Path
from datetime import datetime

# Use it
p = Path.home() / "Documents"
now = datetime.now()
print(now.isoformat())
```

The `import` statement searches `sys.path`. The standard library modules are
always available. Third-party packages need `pip install`.

---

## Exercises

1. **Type exploration**: In the REPL, create one value of each type in the table
   above. Use `type()` to verify. Call `help()` on `list` and read the method list.

2. **Function practice**: Write a function `fizzbuzz(n)` that returns:
   - `"Fizz"` if `n` is divisible by 3
   - `"Buzz"` if divisible by 5
   - `"FizzBuzz"` if both
   - The number as a string otherwise
   Test it with a loop over `range(1, 21)`.

3. **Dict manipulation**: Write a function that takes a list of words and returns
   a dict mapping each word to how many times it appears.

4. **Module use**: Use the `os` module to:
   - Print your current working directory
   - List the files in your home directory
   - Check if a path exists

---

## Check Your Understanding

- What's the difference between a list and a tuple?
- What does `dict.get("key", default)` do that `dict["key"]` doesn't?
- Why would you use a set instead of a list?
- What happens when you call a function without `return`?

---

## Next Steps

→ [Standard Library Tour](./03-standard-library-tour.md)
→ [Track Index](./index.md)
