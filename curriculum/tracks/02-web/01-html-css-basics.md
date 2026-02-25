# HTML & CSS Basics

> **Track:** [02 — Web](./index.md)
> **Level:** Beginner
> **Prerequisites:** [Files and Directories](../00-foundations/03-files-and-directories.md)

---

## What You'll Learn

- What HTML does (structure) and what CSS does (presentation)
- The most important HTML elements and when to use them
- How CSS selectors, properties, and the box model work
- How to open and inspect a local HTML file in a browser

## Why It Matters

HTML and CSS are the universal language of the web. Every webpage, web app,
and email newsletter you've ever seen is built on these two technologies.
Understanding them makes you able to read, modify, and create anything visual
on the web.

---

## Background Reading

Open your local HTML/CSS documentation:

- [HTML/CSS docs](../../../../02-web/html-css/)

Look for the MDN HTML and CSS references. Skim the HTML elements reference —
you don't need to memorize it, just know it exists.

---

## Core Concepts

### HTML: Structure

HTML describes *what* things are, not how they look.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Page</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Main Heading</h1>
    <p>A paragraph of text with <strong>bold</strong> and <em>italic</em>.</p>

    <ul>
        <li>List item one</li>
        <li>List item two</li>
    </ul>

    <a href="https://example.com">A link</a>
    <img src="photo.jpg" alt="Description of photo">
</body>
</html>
```

Key structural elements:
| Element | Purpose |
|---|---|
| `<h1>`–`<h6>` | Headings (h1 = most important) |
| `<p>` | Paragraph |
| `<a href="...">` | Link |
| `<img src="..." alt="...">` | Image |
| `<ul>`, `<ol>`, `<li>` | Lists |
| `<div>` | Generic block container |
| `<span>` | Generic inline container |
| `<form>`, `<input>`, `<button>` | Forms and inputs |

### CSS: Presentation

CSS describes *how* things look.

```css
/* Select by element type */
h1 {
    color: #333333;
    font-size: 2rem;
}

/* Select by class (used on any element with class="card") */
.card {
    background: white;
    border: 1px solid #ccc;
    padding: 1rem;
    border-radius: 4px;
}

/* Select by ID (unique on the page) */
#header {
    position: fixed;
    top: 0;
    width: 100%;
}

/* Descendant selector */
.card p {
    color: #666;
    line-height: 1.5;
}
```

### The Box Model

Every HTML element is a rectangle with four layers:

```
┌─────────────────────────────────────┐  ← margin (space outside border)
│  ┌───────────────────────────────┐  │
│  │         border                │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │       padding           │  │  │
│  │  │  ┌───────────────────┐  │  │  │
│  │  │  │     content       │  │  │  │
│  │  │  └───────────────────┘  │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

```css
.box {
    width: 200px;
    padding: 20px;        /* Inside the border */
    border: 2px solid black;
    margin: 10px;         /* Outside the border */
    box-sizing: border-box;  /* Makes width include padding+border */
}
```

### CSS Layout Basics

**Normal flow**: block elements stack vertically; inline elements flow left-to-right.

**Flexbox**: modern, one-dimensional layout:
```css
.container {
    display: flex;
    justify-content: space-between;  /* horizontal alignment */
    align-items: center;             /* vertical alignment */
    gap: 1rem;
}
```

---

## Exercises

1. **Build a page**: Create `index.html` with:
   - A heading, two paragraphs, an unordered list, and a link
   - Open it in your browser (no server needed — just `file:///path/to/index.html`)

2. **Style it**: Create `style.css`, link it from your HTML, and add:
   - A different color for headings
   - A max-width and centered margin on the body
   - A background color on list items

3. **Box model experiment**: Add a `<div>` with padding, border, and margin. Use
   browser DevTools (F12) to inspect the element and see the box model diagram.

4. **Read the docs**: In your local HTML docs, find the reference for the `<form>`
   element. What attributes does it have? What's the `action` attribute for?

---

## Check Your Understanding

- What's the difference between `class` and `id` in HTML?
- When would you use `<div>` vs `<span>`?
- What does `box-sizing: border-box` change?
- What's the difference between `margin` and `padding`?

---

## Next Steps

→ [JavaScript in the Browser](./02-javascript-in-browser.md)
→ [Track Index](./index.md)
