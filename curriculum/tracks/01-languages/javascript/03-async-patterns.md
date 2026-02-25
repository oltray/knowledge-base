# Async Patterns

> **Track:** [Languages: JavaScript](./index.md)
> **Level:** Intermediate
> **Prerequisites:** [Language Fundamentals](./02-language-fundamentals.md)

---

## What You'll Learn

- The event loop: how JavaScript handles non-blocking I/O
- Callbacks: the original async pattern and its limitations
- Promises: chaining, error handling, and `Promise.all`
- `async/await`: clean syntax over promises, with `try/catch` error handling

## Why It Matters

Almost everything useful in JavaScript is asynchronous — reading files, making network
requests, timers, user events. Understanding the event loop explains *why* async code
works the way it does, and knowing all three patterns (callbacks → promises → async/await)
means you can read and work with any codebase, old or new.

---

## Background Reading

- [JavaScript docs — Promises](../../../../../01-languages/javascript/)
- [MDN: Event loop](../../../../../01-languages/javascript/)
- [MDN: async/await](../../../../../01-languages/javascript/)

---

## Core Concepts

### The Event Loop

JavaScript is single-threaded — it can only do one thing at a time. But it handles
concurrency through the **event loop**:

```
Call Stack          Task Queue (Macrotasks)    Microtask Queue
─────────────       ──────────────────────     ───────────────
[current code]      [setTimeout callbacks]     [Promise .then]
                    [setInterval callbacks]    [queueMicrotask]
                    [I/O callbacks]
```

1. JavaScript runs whatever is on the call stack
2. When the stack empties, it drains the microtask queue (all of it)
3. Then it takes **one** task from the task queue and runs it
4. Repeat

This means `setTimeout(fn, 0)` doesn't run immediately — it queues a task. But
`Promise.resolve().then(fn)` runs before the next setTimeout.

```javascript
console.log('1');
setTimeout(() => console.log('2'), 0);
Promise.resolve().then(() => console.log('3'));
console.log('4');
// Output: 1, 4, 3, 2
```

Non-blocking I/O: when Node.js calls `fs.readFile()`, it hands the work off to the OS
and returns immediately. When the OS is done, it puts the callback in the task queue.
The call stack was free the whole time.

### Callbacks

The original async pattern — pass a function to be called when work completes:

```javascript
const fs = require('fs');

fs.readFile('data.txt', 'utf8', function(err, data) {
  if (err) {
    console.error('Error:', err);
    return;
  }
  console.log(data);
});

console.log('Reading file...'); // prints BEFORE the file content
```

Node.js uses the *error-first* convention: the first callback argument is always an
error (or `null` if none), the second is the result.

**Callback hell** — nesting callbacks for sequential async operations:

```javascript
fs.readFile('a.txt', 'utf8', (err, a) => {
  if (err) return handleErr(err);
  fs.readFile('b.txt', 'utf8', (err, b) => {
    if (err) return handleErr(err);
    fs.writeFile('out.txt', a + b, (err) => {
      if (err) return handleErr(err);
      console.log('Done'); // three levels deep, hard to follow
    });
  });
});
```

### Promises

A Promise represents a value that will be available in the future. It has three states:
pending → fulfilled or rejected.

```javascript
const promise = new Promise((resolve, reject) => {
  setTimeout(() => resolve('done'), 1000);
});

promise
  .then(result => console.log(result))  // 'done' after 1s
  .catch(err => console.error(err));
```

**Chaining** — each `.then` returns a new Promise, enabling flat sequential chains:

```javascript
fetch('/api/user')
  .then(response => response.json())      // parse JSON
  .then(user => fetch('/api/posts/' + user.id))
  .then(response => response.json())
  .then(posts => console.log(posts))
  .catch(err => console.error('Failed:', err));  // catches any error above
```

**`Promise.all`** — run promises in parallel, wait for all:

```javascript
const [users, posts, comments] = await Promise.all([
  fetch('/api/users').then(r => r.json()),
  fetch('/api/posts').then(r => r.json()),
  fetch('/api/comments').then(r => r.json()),
]);
```

If any promise rejects, `Promise.all` rejects immediately.

**`Promise.allSettled`** — like `Promise.all` but waits for all, even if some fail:

```javascript
const results = await Promise.allSettled([p1, p2, p3]);
results.forEach(r => {
  if (r.status === 'fulfilled') console.log(r.value);
  else console.error(r.reason);
});
```

### async/await

`async/await` is syntax sugar over Promises — it makes async code look synchronous:

```javascript
async function loadUserPosts(userId) {
  const userRes = await fetch('/api/users/' + userId);
  const user = await userRes.json();

  const postsRes = await fetch('/api/posts?author=' + user.name);
  const posts = await postsRes.json();

  return posts;
}
```

- `async` before a function makes it return a Promise automatically
- `await` inside an async function pauses execution until the Promise resolves
- `await` can only be used inside `async` functions (or at the top level of modules)

**Error handling with `try/catch`:**

```javascript
async function loadData() {
  try {
    const res = await fetch('/api/data');
    if (!res.ok) throw new Error('HTTP ' + res.status);
    return await res.json();
  } catch (err) {
    console.error('Failed to load:', err.message);
    return null;
  }
}
```

**Parallel with async/await** — don't `await` in sequence when you can run in parallel:

```javascript
// Sequential (slow — waits for each):
const a = await fetchA();
const b = await fetchB();

// Parallel (fast — both start immediately):
const [a, b] = await Promise.all([fetchA(), fetchB()]);
```

---

## Exercises

1. **Event loop quiz**: Predict the output of this code, then run it:
   ```javascript
   console.log('start');
   setTimeout(() => console.log('timeout'), 0);
   Promise.resolve().then(() => console.log('promise'));
   console.log('end');
   ```

2. **Promisify**: Convert this callback-style function to return a Promise:
   ```javascript
   function delay(ms, cb) { setTimeout(cb, ms); }
   ```

3. **Parallel fetch**: Use `Promise.all` to fetch two URLs simultaneously and log both
   results when both are ready. (Use `https://jsonplaceholder.typicode.com` endpoints.)

4. **Error handling**: Write an `async` function that fetches a URL, handles HTTP errors
   (non-2xx status codes), and returns `null` on failure instead of throwing.

---

## Check Your Understanding

- What is the event loop? Why does `setTimeout(fn, 0)` not run immediately?
- What is the error-first callback convention?
- What's the difference between `Promise.all` and `Promise.allSettled`?
- What does `await` do, and where can you use it?
- Why is `await` inside a loop often a bug? How do you fix it?

---

## Next Steps

→ [Modules and Node.js](./04-modules-and-node.md)
→ [Track Index](./index.md)
