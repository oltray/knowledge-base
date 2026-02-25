# JavaScript Orientation

> **Track:** [Languages: JavaScript](./index.md)
> **Level:** Beginner
> **Prerequisites:** [JavaScript in the Browser](../../02-web/02-javascript-in-browser.md)

---

## What You'll Learn

- Where JavaScript runs and which engines power it
- How to run JS in the browser console, Node.js REPL, and as script files
- The npm ecosystem: packages, `package.json`, and `node_modules`
- How to navigate MDN — the canonical JavaScript reference

## Why It Matters

Most developers learn JavaScript by copying examples. This module builds the foundation
underneath that: knowing *where* the code runs, *what* tools exist, and *where to look*
when you need an answer. That foundation makes every future concept easier.

---

## Background Reading

Open your local JavaScript documentation:

- [JavaScript docs](../../../../../01-languages/javascript/)

Browse the structure before continuing. Familiarity with the layout pays off every time
you need to look something up.

---

## Core Concepts

### Where JavaScript Runs

JavaScript is a specification (ECMAScript) with multiple implementations called *engines*:

| Engine | Used by |
|---|---|
| V8 | Chrome, Node.js, Deno, Bun |
| SpiderMonkey | Firefox |
| JavaScriptCore | Safari |

Every engine implements the same language standard. Code that avoids browser-specific APIs
runs anywhere.

**Environments:**
- **Browser** — has `document`, `window`, `fetch`, DOM APIs
- **Node.js** — has `fs`, `path`, `http`, `process`; no DOM
- **Deno** — modern Node alternative with built-in TypeScript support
- **Bun** — fast Node-compatible runtime focused on performance

### Running JavaScript

**Browser console** — press F12 or Cmd+Option+J (Chrome):

```javascript
> 2 + 2
4
> "hello".toUpperCase()
'HELLO'
> typeof null
'object'   // famous quirk
```

**Node.js REPL** — from your terminal:

```bash
node
```

```javascript
> require('path').join('a', 'b', 'c')
'a/b/c'
> .help   // REPL commands
> .exit
```

**Script files:**

```bash
node my-script.js
```

```javascript
// my-script.js
console.log("Hello from Node.js");
console.log(process.argv);   // command-line arguments
```

### The npm Ecosystem

npm (Node Package Manager) is the registry for JavaScript packages:

```bash
npm install lodash          # install a package
npm install --save-dev jest # install a dev dependency
npm run test                # run a script from package.json
```

**package.json** — every project's manifest:

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js",
    "test": "jest"
  },
  "dependencies": {
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  }
}
```

**node_modules/** — where installed packages live. Never commit this to git; use a
`.gitignore` entry. Anyone can recreate it with `npm install`.

### Reading MDN

MDN Web Docs is the canonical reference for JavaScript (and web APIs). Every entry has:

- **Description** — what the feature is and when to use it
- **Syntax** — the exact signature with parameters
- **Examples** — runnable code
- **Browser compatibility** — what environments support it
- **Specifications** — links to the ECMAScript standard

When you encounter something unfamiliar, MDN is the first place to look. Get comfortable
with its structure; you'll use it constantly.

---

## Exercises

1. **Console exploration**: Open your browser's dev tools. Try 10 expressions: arithmetic,
   string methods, `typeof` on different values, `Array.isArray([])`, `null == undefined`.

2. **Node REPL**: Start `node`. Explore `process.version`, `process.platform`, and
   `require('os').cpus().length`. Type `.help` to see REPL commands.

3. **First script**: Create `hello.js` with `console.log("Hello, " + process.argv[2])`.
   Run it with `node hello.js YourName`.

4. **Read the docs**: Find the MDN page for `Array.prototype.map`. Read the description,
   syntax, and first example. Then find it in your local docs.

---

## Check Your Understanding

- What is V8, and which environments use it?
- What does `node_modules/` contain, and why shouldn't it be committed?
- What are the three ways to run JavaScript outside of a `.html` file?
- Where do you look first when you encounter an unfamiliar JS method?

---

## Next Steps

→ [Language Fundamentals](./02-language-fundamentals.md)
→ [Track Index](./index.md)
