# How to Use This Library Offline

> **Location:** `curriculum/meta/how-to-use-offline.md`

This knowledge base is designed to work entirely without an internet connection.
Here's how to get the most out of it.

---

## The Three Layers

### 1. Reference Documentation (`$DOC_PATH/`)

Actual language specs, API docs, manuals, and standards — fetched once and
stored locally. These are the authoritative sources you consult when you need
to know *exactly* how something works.

Browse them from the [vault home](../../Home.md) under "Browse by Category".

### 2. Curriculum Modules (this directory)

Guided learning modules that point you *into* the reference docs. They:
- Explain the "why" before the "what"
- Select which parts of the docs matter most for beginners
- Give you exercises and questions to check understanding
- Provide a path from zero to productive

Start at the [Curriculum Overview](../overview.md).

### 3. Your Notes (`notes/`)

Your personal scratch pad inside the vault. Cross-reference anything you learn.
See `notes/index.md` to get started.

---

## Typical Learning Session

1. **Open** the curriculum track you're working through
2. **Read** the module's background section — it tells you which docs to open
3. **Open** those local docs and skim them (Obsidian can open file:// links)
4. **Return** to the module and work through the exercises
5. **Take notes** in `notes/` about things worth remembering

---

## Navigating Local Docs in Obsidian

Obsidian opens files and folders natively. Links in curriculum modules use
relative paths like `../../../../01-languages/python/` — click them to open
the local directory in your system file manager, or browse from Home.md.

For richer browsing, open the doc folders directly in your text editor or
browser. Most offline docs are either:
- **Markdown** — readable directly in Obsidian
- **HTML** — open `index.html` in a browser (no internet needed)
- **Text/man pages** — open in any text editor

---

## Keeping Everything Up to Date

From the repo directory:

```bash
git pull          # Update curriculum modules
./update.sh       # Re-fetch updated documentation
```

The curriculum symlink (`$OBSIDIAN_VAULT_PATH/curriculum/`) tracks the repo
automatically via `git pull` — no extra sync step needed.

---

## Working Offline on a Laptop or USB Drive

If you're taking this library somewhere without network access:
1. Run `./update.sh` before you leave to get the latest docs
2. Run `./sync.sh /path/to/usb` to copy everything to a USB drive
3. Open Obsidian on the destination machine pointing at the vault

Everything — including the curriculum modules — will be available.
