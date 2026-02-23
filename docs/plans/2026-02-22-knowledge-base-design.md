# knowledge-base — Design Document

**Date:** 2026-02-22
**Status:** Implemented

---

## Problem

Building a comprehensive offline documentation library for CS topics requires:
- Downloading and organizing dozens of sources (git repos, PDFs, docsets)
- Keeping everything updated
- Making it portable across machines
- Integrating with note-taking (Obsidian)

Storing docs on a single device is fragile. Storing them in a git repo is impractical (too large). The solution is a **repo that contains the automation to build the library**, not the library itself.

---

## Goals

1. Clone the repo + run one command → fully populated documentation library
2. Declarative source manifest — add a doc source by editing one YAML file
3. macOS and Linux support
4. Portable to USB/external drives via sync script
5. Obsidian vault wired to the local library

---

## Architecture

### Separation of Concerns

```
knowledge-base/          ← This repo (scripts + config)
  setup.sh               ← Bootstrap
  update.sh              ← Incremental updates
  sync.sh                ← USB/drive sync
  scripts/
    lib.sh               ← Shared utilities
    fetch.sh             ← Download engine (reads sources.yaml)
    index.sh             ← Index generator
  config/
    sources.yaml         ← THE manifest
    settings.sh          ← User config (DOC_PATH etc.)
  obsidian/              ← Vault structure (no docs)

~/docs/                  ← DOC_PATH (outside the repo, gitignored by nature)
  00-index/              ← Generated indexes and logs
  01-languages/
  02-web/
  ...
```

### Source Manifest (sources.yaml)

Three source types:

| Type   | Mechanism          | Update strategy        |
|--------|--------------------|------------------------|
| `git`  | `git clone`        | `git pull --rebase`    |
| `wget` | `wget` + extract   | Skip if exists         |
| `zeal` | kapeli CDN `.tgz`  | Skip if `.docset` dir exists |

### Flow

```
./setup.sh
  ↓
install deps (brew/apt)
  ↓
mkdir -p ~/docs/{00-index, 01-languages, ...}
  ↓
scripts/fetch.sh install
  ├── clone all git sources
  ├── download all wget sources (+ extract)
  └── download all zeal docsets (+ extract)
  ↓
scripts/index.sh
  ├── generate ~/docs/00-index/README.md
  └── generate ~/docs/00-index/status.md
  ↓
copy obsidian/ vault to ~/docs/obsidian-vault/
```

---

## Key Design Decisions

**Why YAML manifest over shell arrays?**
Adding a source = editing config, not scripts. The scripts are stable plumbing. The YAML is the content.

**Why yq over Python/jq?**
yq is purpose-built for YAML, installed via brew/binary with no other deps. Python adds pip dependency management complexity.

**Why docs outside the repo?**
Docs can be 20-100GB. They don't belong in git. The repo is lean and fast to clone. The docs are built by it.

**Why shallow clones (depth=1)?**
Full history of the Kubernetes website or MDN content is wasteful for a reference library. Shallow is faster and smaller. Full clones can always be deepened manually.

---

## Sources Included

### Git Repositories (14)
- Languages: rust-book, rust-by-example, cppreference-doc
- Web: mdn-content, mdn-css-examples
- Systems: man-pages
- Security: owasp-cheatsheets, owasp-wstg
- Databases: sqlite
- DevOps: docker-docs, kubernetes-docs
- Tools: pro-git
- Extras: free-programming-books

### File Downloads (21)
- Python 3.12 docs (HTML + PDF)
- Effective Go
- RFCs: 791, 793, 2616, 7540, 8446, 9110
- OWASP Top 10 2021
- NIST SPs: 800-53r5, 800-63b, 800-61r2, 800-115, 800-171r2
- PostgreSQL 16 docs, MySQL 8.0 reference
- Linux: ABS Guide, Bash Beginners Guide
- Papers: Attention Is All You Need, MapReduce, Dynamo

### Zeal/Dash Docsets (22)
- Languages: Python 3, JavaScript, TypeScript, C, C++, Rust, Go, Java SE11, Bash
- Web: HTML, CSS, React, Vue.js, Node.JS
- Databases: PostgreSQL, MySQL, SQLite, Redis, MongoDB
- DevOps: Docker, Kubernetes
- Tools: Git, Vim

---

## Future Additions

To add a new source, edit `config/sources.yaml`:

```yaml
# New git repo
git:
  - name: my-new-docs
    url: https://github.com/org/repo.git
    category: 01-languages/python
    depth: 1

# New file download
wget:
  - name: some-spec.pdf
    url: https://example.com/spec.pdf
    category: 11-standards/w3c

# New docset
zeal:
  - name: Angular
    category: 02-web/frontend-frameworks
```

No script changes needed.
