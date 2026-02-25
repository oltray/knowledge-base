# Language Fundamentals

> **Track:** [Languages: JavaScript](./index.md)
> **Level:** Beginner–Intermediate
> **Prerequisites:** [JavaScript Orientation](./01-javascript-orientation.md)

---

## What You'll Learn

- The type system: primitives, objects, `typeof`, and type coercion
- The difference between `==` and `===`
- Scope: `var`, `let`, `const`, hoisting, and block scope
- Closures: what they are and why they matter
- `this`: how it's determined in different contexts

## Why It Matters

These topics are where most JavaScript confusion lives. Developers who skip them spend
years being surprised by bugs that have simple explanations. Understanding coercion,
closures, and `this` is the difference between using JavaScript and understanding it.

---

## Background Reading

- [JavaScript Guide on MDN](../../../../../01-languages/javascript/)

Focus on: Grammar and Types, Functions, Closures, and the `this` reference.

---

## Core Concepts

### The Type System

JavaScript has eight types. Seven are *primitives*, one is `object`:

| Type | Examples |
|---|---|
| `undefined` | `undefined` |
| `null` | `null` |
| `boolean` | `true`, `false` |
| `number` | `42`, `3.14`, `NaN`, `Infinity` |
| `bigint` | `9007199254740991n` |
| `string` | `"hello"`, `'world'`, `` `template` `` |
| `symbol` | `Symbol('id')` |
| `object` | `{}`, `[]`, `function(){}`, `null` (quirk) |

`typeof` reveals a value's type — with two famous quirks:

```javascript
typeof null        // 'object'  ← historical bug, never fixed
typeof function(){} // 'function' ← functions are objects, but typeof is special
typeof []          // 'object'
typeof undefined   // 'undefined'
```

Use `Array.isArray(x)` to test for arrays. Use `=== null` to test for null.

### Type Coercion

JavaScript converts types automatically in many contexts. This is coercion:

```javascript
'5' + 3      // '53'   — number coerced to string
'5' - 3      // 2      — string coerced to number
!!'hello'    // true   — string coerced to boolean
!!''         // false  — empty string is falsy
!!0          // false  — 0 is falsy
!!null       // false  — null is falsy
!!undefined  // false  — undefined is falsy
!!NaN        // false  — NaN is falsy
```

**Falsy values** (everything else is truthy): `false`, `0`, `''`, `null`, `undefined`, `NaN`.

### `==` vs `===`

`===` (strict equality) — same type AND same value. Never coerces.

`==` (loose equality) — coerces types before comparing. Produces surprising results:

```javascript
0 == false    // true  (false coerces to 0)
'' == false   // true  (both coerce to 0)
null == undefined  // true  (special case)
null == 0          // false (null only equals undefined with ==)
```

**Rule:** Always use `===`. The only exception is `x == null` which is a concise way to
check for both `null` and `undefined`.

### Scope

**`var`** — function-scoped, hoisted to the top of its function, can be re-declared:

```javascript
function example() {
  console.log(x); // undefined (hoisted, not an error)
  var x = 5;
  console.log(x); // 5
}
```

**`let`** — block-scoped, not accessible before declaration (temporal dead zone):

```javascript
{
  let x = 5;
  console.log(x); // 5
}
console.log(x); // ReferenceError
```

**`const`** — block-scoped, must be initialized, cannot be reassigned:

```javascript
const PI = 3.14159;
PI = 3; // TypeError

const obj = { x: 1 };
obj.x = 2; // OK — const prevents reassignment, not mutation
```

**Rule:** Use `const` by default. Use `let` when you need to reassign. Avoid `var`.

### Closures

A closure is a function that *remembers* the variables from its enclosing scope, even
after that scope has finished executing:

```javascript
function makeCounter() {
  let count = 0;           // in makeCounter's scope
  return function() {
    count++;               // inner function closes over count
    return count;
  };
}

const counter = makeCounter();
counter(); // 1
counter(); // 2
counter(); // 3
```

`count` is not accessible from outside `makeCounter`, but the returned function can still
read and modify it. This is the basis for private state in JavaScript.

**Practical pattern — module with private state:**

```javascript
const wallet = (function() {
  let balance = 0;
  return {
    deposit(amount) { balance += amount; },
    withdraw(amount) { balance -= amount; },
    getBalance() { return balance; }
  };
})();

wallet.deposit(100);
wallet.getBalance(); // 100
wallet.balance;      // undefined — not accessible directly
```

### `this`

`this` refers to the *calling context* — it's set at call time, not at definition time.

**Method call** — `this` is the object before the dot:

```javascript
const obj = {
  name: 'Alice',
  greet() { return 'Hello, ' + this.name; }
};
obj.greet(); // 'Hello, Alice'
```

**Plain function call** — `this` is `undefined` (strict mode) or `globalThis`:

```javascript
function show() { console.log(this); }
show(); // undefined (in strict mode)
```

**Arrow functions** — do NOT have their own `this`; they inherit from enclosing scope:

```javascript
const obj = {
  name: 'Alice',
  greet() {
    const inner = () => 'Hello, ' + this.name; // this from greet()
    return inner();
  }
};
obj.greet(); // 'Hello, Alice'
```

**Class** — `this` is the instance:

```javascript
class Person {
  constructor(name) { this.name = name; }
  greet() { return 'Hello, ' + this.name; }
}
new Person('Bob').greet(); // 'Hello, Bob'
```

**Common trap** — losing `this` when passing a method as a callback:

```javascript
const obj = { name: 'Alice', greet() { return this.name; } };
const fn = obj.greet;
fn(); // undefined — this is no longer obj

// Fix: bind
const bound = obj.greet.bind(obj);
bound(); // 'Alice'

// Fix: arrow function wrapper
setTimeout(() => obj.greet(), 100); // 'Alice'
```

---

## Exercises

1. **Coercion predictions**: Before running, predict the result of each expression:
   `[] + []`, `[] + {}`, `{} + []`, `+'3'`, `+true`, `+null`. Then check in the console.

2. **Closure counter**: Write a `makeAdder(n)` function that returns a function adding `n`
   to its argument: `makeAdder(5)(3)` → `8`.

3. **Scope bug**: Explain why the classic loop bug produces the wrong output, then fix it:
   ```javascript
   for (var i = 0; i < 3; i++) {
     setTimeout(() => console.log(i), 0);
   }
   ```

4. **`this` tracing**: For each code snippet, determine what `this` refers to:
   an arrow function inside a method, a method called via a variable, a class method.

---

## Check Your Understanding

- What are the seven primitive types? How do you distinguish `null` from `undefined`?
- Why does `typeof null === 'object'`? What's the correct way to check for null?
- What's the difference between `var` and `let` in terms of scoping and hoisting?
- Describe what a closure is in one sentence. Give a practical use case.
- How does `this` differ between a regular function and an arrow function?

---

## Next Steps

→ [Async Patterns](./03-async-patterns.md)
→ [Track Index](./index.md)
