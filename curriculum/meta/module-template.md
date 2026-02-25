# Module Title

> **Track:** Track Name (link to `../index.md`)
> **Level:** Beginner / Intermediate / Advanced
> **Prerequisites:** None / Module Name (link to `./01-previous-module.md`)

---

## What You'll Learn

- Concept one
- Concept two
- Concept three

## Why It Matters

One paragraph explaining why this topic is worth your time and where you'll use it.

---

## Background Reading

Link to the local documentation you should read first.
Replace `RELATIVE_PATH` with the appropriate prefix from the table at the bottom.

```markdown
- [Reference Name](RELATIVE_PATH/category/subcategory)
```

---

## Core Concepts

### Concept 1

Explain the concept in plain language. Then show an example or point to the docs:

```markdown
> See: [doc section](RELATIVE_PATH/category/)
```

### Concept 2

...

---

## Exercises

1. **Hands-on task**: Description of something to try.
2. **Exploration task**: "Open the X docs (`RELATIVE_PATH/...`) and find Y."
3. **Build task**: Something to build that applies the concepts.

---

## Check Your Understanding

- Question 1?
- Question 2?
- Question 3?

---

## Next Steps

```markdown
→ [Next Module](./02-next-module.md)
→ [Track Index](../index.md)
```

---

## Path Depth Reference

Use this table to build correct relative links to `$DOC_PATH/` categories
from any curriculum file. Replace `RELATIVE_PATH` in links above with the
appropriate prefix for this file's nesting depth.

| File location (inside vault) | Prefix to reach `$DOC_PATH/` |
|---|---|
| `curriculum/overview.md` | `../../` |
| `curriculum/meta/*.md` | `../../` |
| `curriculum/tracks/XX-track/index.md` | `../../../../` |
| `curriculum/tracks/XX-track/NN-module.md` | `../../../../` |
| `curriculum/tracks/XX-track/language/index.md` | `../../../../../` |
| `curriculum/tracks/XX-track/language/NN-module.md` | `../../../../../` |

**Example:** A module at `curriculum/tracks/00-foundations/01-how-computers-work.md`
links to Python docs with: `../../../../01-languages/python/`
