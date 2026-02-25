# JavaScript in the Browser

> **Track:** [02 — Web](./index.md)
> **Level:** Beginner
> **Prerequisites:** [HTML & CSS Basics](./01-html-css-basics.md)

---

## What You'll Learn

- How JavaScript runs in the browser (the event loop model)
- How to select and modify HTML elements (the DOM)
- How to respond to user events (clicks, inputs)
- How to fetch data from APIs asynchronously
- Where to find the JavaScript reference in your local docs

## Why It Matters

JavaScript is the only programming language that runs natively in the browser.
It's what makes web pages interactive — everything from form validation to
real-time updates is JavaScript.

---

## Background Reading

- [HTML/CSS docs](../../../../02-web/html-css/) — includes the JavaScript/DOM reference
- [Frontend docs](../../../../02-web/frontend-frameworks/)

---

## Core Concepts

### Running JavaScript

Two ways:
1. Browser DevTools Console (F12 → Console tab) — instant experimentation
2. `<script>` tag in HTML

```html
<!-- Inline -->
<script>
    console.log("Hello from JavaScript!");
</script>

<!-- External file (preferred) -->
<script src="app.js" defer></script>
```

The `defer` attribute ensures the script runs after the HTML is parsed.

### The DOM — Your Page as a Tree

The Document Object Model (DOM) is the browser's representation of your HTML
as a tree of objects. JavaScript can read and modify it.

```javascript
// Select elements
const heading = document.querySelector('h1');          // First match
const buttons = document.querySelectorAll('.btn');      // All matches

// Read and modify
console.log(heading.textContent);         // Get text
heading.textContent = "New Title";        // Set text
heading.style.color = "red";              // Change style
heading.classList.add("active");          // Add CSS class
heading.classList.remove("active");       // Remove CSS class
heading.classList.toggle("active");       // Toggle CSS class

// Create and insert new elements
const para = document.createElement('p');
para.textContent = "A new paragraph";
document.body.appendChild(para);
```

### Events

Events are how JavaScript responds to user actions.

```javascript
const btn = document.querySelector('#myButton');

btn.addEventListener('click', function(event) {
    console.log('Button clicked!');
    console.log(event.target);   // The element that was clicked
});

// Common events
// 'click', 'input', 'change', 'submit', 'keydown', 'mouseover'

// Input events
const input = document.querySelector('input');
input.addEventListener('input', function(e) {
    console.log('Current value:', e.target.value);
});
```

### Async: Promises and fetch

The browser doesn't pause JavaScript while waiting for a network response.
Instead, it uses callbacks/promises.

```javascript
// fetch returns a Promise
fetch('https://api.example.com/data')
    .then(response => response.json())    // Parse JSON
    .then(data => console.log(data))
    .catch(error => console.error(error));

// async/await syntax (cleaner)
async function loadData() {
    try {
        const response = await fetch('https://api.example.com/data');
        const data = await response.json();
        console.log(data);
    } catch (error) {
        console.error('Failed:', error);
    }
}
```

### The Browser Console

The Console is your REPL for browser JavaScript. You can:
- Run any JavaScript expression
- Inspect DOM elements (`document.querySelector('h1')`)
- See errors and `console.log` output
- Test code before adding it to a file

Use it constantly while learning.

---

## Exercises

1. **DOM manipulation**: Add a button to your HTML page from the previous module.
   Write JavaScript that changes the heading text when the button is clicked.

2. **Dynamic list**: Create an empty `<ul>` and an `<input>` + `<button>`. Write
   JavaScript that adds a new `<li>` with the input value each time the button
   is clicked.

3. **Fetch exercise**: Open DevTools → Console on any webpage. Run:
   ```javascript
   fetch('https://httpbin.org/json').then(r => r.json()).then(console.log)
   ```
   Examine what comes back.

4. **Event exploration**: In DevTools Console, run:
   ```javascript
   document.addEventListener('click', e => console.log(e.target, e.clientX, e.clientY))
   ```
   Click around the page. What does each click log?

---

## Check Your Understanding

- What is the DOM?
- What's the difference between `querySelector` and `querySelectorAll`?
- Why does `fetch` return a Promise instead of the data directly?
- What does `async/await` do that `.then()/.catch()` chains don't?

---

## Next Steps

→ [Languages: JavaScript](../01-languages/javascript/index.md)
→ [Track Index](./index.md)
→ [Curriculum Overview](../../overview.md)
