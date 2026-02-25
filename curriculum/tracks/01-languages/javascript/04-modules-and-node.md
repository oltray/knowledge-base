# Modules and Node.js

> **Track:** [Languages: JavaScript](./index.md)
> **Level:** Intermediate
> **Prerequisites:** [Async Patterns](./03-async-patterns.md)

---

## What You'll Learn

- CommonJS: `require()` and `module.exports` — Node's traditional module system
- ES Modules: `import`/`export` — the standard module system for modern JS
- Node.js core APIs: `process`, `fs`, `path`, `http`
- npm: installing packages, understanding `package.json`, running scripts

## Why It Matters

Every JavaScript project beyond a single file uses a module system. Knowing both
CommonJS and ES Modules means you can navigate any codebase — legacy or modern. And
understanding just enough Node.js lets you run scripts, read files, and build tools
without needing a browser.

---

## Background Reading

- [MDN — JavaScript Modules](../../../../../01-languages/javascript/)
- [Node.js docs](../../../../../01-languages/javascript/)

---

## Core Concepts

### CommonJS (CJS)

CommonJS is Node.js's original module system. Files are modules; each has its own scope.

**Exporting:**

```javascript
// math.js
function add(a, b) { return a + b; }
function multiply(a, b) { return a * b; }

module.exports = { add, multiply };

// or export a single value:
module.exports = function add(a, b) { return a + b; };
```

**Importing:**

```javascript
const { add, multiply } = require('./math');     // relative path
const fs = require('fs');                         // built-in module
const lodash = require('lodash');                 // npm package
```

CommonJS is **synchronous** — `require()` blocks until the module loads. This is fine
for startup, but isn't suitable for dynamic loading at runtime.

### ES Modules (ESM)

ES Modules are the JavaScript standard, supported in all modern browsers and Node.js ≥
12. They are always asynchronous and statically analyzed (imports are resolved before
code runs).

**Named exports:**

```javascript
// math.js
export function add(a, b) { return a + b; }
export function multiply(a, b) { return a * b; }
export const PI = 3.14159;
```

**Default export:**

```javascript
// logger.js
export default function log(msg) { console.log(msg); }
```

**Importing:**

```javascript
import { add, multiply } from './math.js';    // named imports
import log from './logger.js';                 // default import
import * as math from './math.js';             // namespace import
import { add as plus } from './math.js';       // renamed import
```

**In Node.js**, use ESM by either:
- Naming files `.mjs`, or
- Adding `"type": "module"` to `package.json`

**In browsers**, use `<script type="module">`:

```html
<script type="module" src="app.js"></script>
```

### CJS vs ESM — When to Use Which

| | CommonJS | ES Modules |
|---|---|---|
| Syntax | `require` / `module.exports` | `import` / `export` |
| Execution | Synchronous | Asynchronous |
| Node.js | Default (`.js` files) | With `.mjs` or `"type": "module"` |
| Browsers | No (needs bundler) | Yes (natively) |
| Tree-shaking | No | Yes |
| Use for | Legacy code, older Node | New projects, libraries, browsers |

### Node.js Core APIs

You don't need to install these — they're built in.

**`process`** — information about the running Node.js process:

```javascript
process.argv       // command-line arguments as array
process.env.HOME   // environment variables
process.cwd()      // current working directory
process.exit(0)    // exit with code 0 (success)
process.stdout.write('hello\n');
```

**`path`** — safe cross-platform path manipulation:

```javascript
const path = require('path');

path.join('/users', 'alice', 'docs')  // '/users/alice/docs'
path.resolve('./config.json')          // absolute path
path.basename('/users/alice/file.txt') // 'file.txt'
path.extname('file.txt')               // '.txt'
path.dirname('/users/alice/file.txt')  // '/users/alice'
```

Always use `path.join` instead of string concatenation for file paths — it handles
OS differences (Windows uses `\`, Unix uses `/`).

**`fs`** — file system operations:

```javascript
const fs = require('fs');

// Synchronous (simple scripts):
const data = fs.readFileSync('input.txt', 'utf8');
fs.writeFileSync('output.txt', data.toUpperCase());

// Async with callbacks:
fs.readFile('input.txt', 'utf8', (err, data) => {
  if (err) throw err;
  fs.writeFile('output.txt', data.toUpperCase(), (err) => {
    if (err) throw err;
  });
});

// Async with promises (modern):
const { readFile, writeFile } = require('fs/promises');
const data = await readFile('input.txt', 'utf8');
await writeFile('output.txt', data.toUpperCase());
```

**`http`** — create a basic HTTP server:

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello, World!\n');
});

server.listen(3000, () => {
  console.log('Server running at http://localhost:3000/');
});
```

In practice, you'd use a framework like Express instead of raw `http`.

### npm

npm manages packages and project scripts.

**Key commands:**

```bash
npm init -y                    # create package.json with defaults
npm install express            # install + add to dependencies
npm install --save-dev jest    # install + add to devDependencies
npm install                    # install all packages from package.json
npm uninstall lodash           # remove a package
npm run test                   # run the "test" script
npm run build                  # run the "build" script
npm list                       # list installed packages
npm outdated                   # show packages with newer versions
npm update                     # update packages within semver range
```

**`package.json` anatomy:**

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "description": "A sample Node.js application",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest",
    "build": "tsc"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "nodemon": "^3.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

**Semver ranges** in `package.json`:
- `^4.18.0` — compatible with 4.x.x (most common)
- `~4.18.0` — compatible with 4.18.x (patch updates only)
- `4.18.0` — exact version

**`package-lock.json`** — records the exact versions installed. Commit this to git so
everyone on the project gets identical versions.

---

## Exercises

1. **CJS module**: Create a `utils.js` that exports three functions: `capitalize`,
   `slugify` (lowercase + replace spaces with `-`), and `truncate(str, n)`. Import and
   use them in `main.js`.

2. **ESM conversion**: Convert the same module to use `export`/`import`. Add
   `"type": "module"` to a `package.json` and run it with Node.

3. **File processing script**: Write a Node.js script using `fs/promises` and `path`
   that reads all `.txt` files in a directory, concatenates their contents, and writes
   the result to `combined.txt`.

4. **npm exploration**: Create a new project with `npm init -y`. Install `chalk` (a
   terminal color library). Write a script that prints colored output. Add a `"start"`
   script to `package.json` and run it with `npm start`.

---

## Check Your Understanding

- What is the difference between `require()` and `import`? When would you use each?
- What does `"type": "module"` in `package.json` do?
- What does `process.argv` contain, and how do you access command-line arguments?
- Why should you use `path.join` instead of string concatenation for file paths?
- What is `package-lock.json` and why should it be committed to git?

---

## Next Steps

→ [Track Index](./index.md)
→ [Curriculum Overview](../../../overview.md)
