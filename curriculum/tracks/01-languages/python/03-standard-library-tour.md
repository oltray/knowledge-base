# Python Standard Library Tour

> **Track:** [Languages: Python](./index.md)
> **Level:** Beginner–Intermediate
> **Prerequisites:** [Core Concepts](./02-core-concepts.md)

---

## What You'll Learn

- Why "batteries included" is Python's superpower
- The most useful standard library modules and when to reach for them
- How to read the library reference for modules you haven't used

## Why It Matters

Most tasks you'll want to do in Python are already solved in the standard
library. Before reaching for a third-party package, check whether the stdlib
does it. Knowing what's available saves you from reinventing the wheel.

---

## Background Reading

Your local Python docs include a complete Library Reference:

- [Python docs](../../../../../01-languages/python/) → Library Reference

Browse the table of contents. You don't need to read it all — just know what's
there so you know where to look.

---

## Essential Modules

### `pathlib` — Modern Path Handling

```python
from pathlib import Path

p = Path.home() / "Documents" / "notes.txt"
p.exists()                  # True/False
p.read_text()               # Read the whole file
p.write_text("content")     # Write the whole file
p.parent                    # Parent directory
p.suffix                    # ".txt"
p.stem                      # "notes"

# List all Python files recursively
for f in Path(".").rglob("*.py"):
    print(f)
```

> See: [Python docs](../../../../../01-languages/python/) → `pathlib` in Library Reference

### `os` and `os.path` — System Interface

```python
import os

os.getcwd()                 # Current directory
os.listdir(".")             # List directory (use pathlib instead when possible)
os.environ.get("HOME")      # Environment variables
os.makedirs("a/b/c", exist_ok=True)  # Create nested dirs
```

### `json` — Data Serialization

```python
import json

data = {"name": "Alice", "scores": [95, 87, 92]}
text = json.dumps(data, indent=2)   # Python → JSON string
data2 = json.loads(text)            # JSON string → Python

# Files
with open("data.json", "w") as f:
    json.dump(data, f, indent=2)

with open("data.json") as f:
    data3 = json.load(f)
```

### `datetime` — Dates and Times

```python
from datetime import datetime, date, timedelta

now = datetime.now()
print(now.isoformat())              # "2024-01-15T14:30:00.123456"
print(now.strftime("%Y-%m-%d"))     # "2024-01-15"

yesterday = now - timedelta(days=1)
diff = now - datetime(2024, 1, 1)
print(diff.days)                    # Days since Jan 1
```

### `re` — Regular Expressions

```python
import re

pattern = re.compile(r'\d+')       # One or more digits
match = pattern.search("abc123def")
match.group()                       # "123"

# Find all matches
re.findall(r'\w+', "hello world")  # ["hello", "world"]

# Substitute
re.sub(r'\s+', ' ', "too   many   spaces")  # "too many spaces"
```

### `collections` — Specialized Containers

```python
from collections import Counter, defaultdict, deque

# Count occurrences
words = ["cat", "dog", "cat", "fish", "dog", "cat"]
counts = Counter(words)
counts.most_common(2)              # [("cat", 3), ("dog", 2)]

# Dict with default values
dd = defaultdict(list)
dd["key"].append("value")          # No KeyError if "key" missing

# Double-ended queue (fast append/pop on both ends)
q = deque([1, 2, 3])
q.appendleft(0)
q.popleft()
```

### `itertools` — Iterator Building Blocks

```python
import itertools

list(itertools.chain([1,2], [3,4], [5,6]))   # [1,2,3,4,5,6]
list(itertools.islice(range(1000), 5))        # [0,1,2,3,4]
list(itertools.combinations("ABC", 2))        # [('A','B'),('A','C'),('B','C')]
```

### `sys` — System-Specific Parameters

```python
import sys

sys.argv                    # Command-line arguments
sys.exit(0)                 # Exit with status code
sys.version                 # Python version string
sys.path                    # Where Python looks for modules
print("hello", file=sys.stderr)  # Write to stderr
```

---

## Exercises

1. **File operations**: Write a script using `pathlib` that:
   - Creates a directory `test_output/`
   - Writes a JSON file there with some data
   - Reads it back and prints it
   - Cleans up the directory

2. **Text processing**: Write a function using `re` and `collections.Counter`
   that takes a text string and returns the 5 most common words (case-insensitive,
   ignoring punctuation).

3. **Date math**: Write a script that prints how many days until the next New Year.

4. **Explore an unfamiliar module**: Pick any module from the Library Reference
   that you haven't used. Read its docs, write a 5-line example, run it.

---

## Check Your Understanding

- Why use `pathlib` instead of string concatenation for paths?
- What does `Counter.most_common(n)` return?
- When would you use `json.dumps` vs `json.dump`?
- What's the difference between `re.search` and `re.match`?

---

## Next Steps

→ [Track Index](./index.md)
→ [Web Track](../../02-web/index.md)
