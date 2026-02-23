# knowledge-base

A self-deploying offline documentation library. Clone it, run one command, walk away. Come back to a fully populated reference library covering programming languages, networking, security, databases, DevOps, and more.

---

## Quick Start

```bash
git clone https://github.com/rw/knowledge-base.git
cd knowledge-base
./setup.sh
```

That's it. The library builds itself.

**Default location:** `~/docs`
**Estimated size:** 20–60GB (depends on which sources complete)
**Estimated time:** 30–90 minutes (network speed dependent)

---

## What Gets Installed

| Category | Contents |
|----------|----------|
| `01-languages` | Python 3 docs, Rust Book, Rust by Example, CPPReference, Go, Java |
| `02-web` | MDN content, CSS examples, React/Vue/Node docsets |
| `03-systems` | Linux man pages, ABS Guide, Bash guide |
| `04-networking` | RFC 791, 793, 2616, 7540, 8446, 9110 |
| `05-security` | OWASP Cheat Sheets, OWASP Testing Guide, OWASP Top 10, NIST SPs |
| `06-databases` | PostgreSQL, MySQL, SQLite source, Redis/MongoDB docsets |
| `07-devops` | Docker docs, Kubernetes docs |
| `08-tools` | Pro Git book |
| `09-algorithms` | (populate via `sources.yaml`) |
| `10-architecture` | (populate via `sources.yaml`) |
| `11-standards` | (populate via `sources.yaml`) |
| `99-extras` | Free Programming Books, papers (MapReduce, Dynamo, Attention) |

Plus 22 Zeal/Dash docsets for offline API browsing.

---

## Configuration

**Change where docs are stored:**
```bash
DOC_PATH=/Volumes/SSD/docs ./setup.sh
```

**Skip categories you don't need:**
```bash
SKIP_CATEGORIES="07-devops 11-standards" ./setup.sh
```

**Edit `config/settings.sh`** for persistent overrides.

---

## Adding Documentation Sources

Open `config/sources.yaml` and add an entry. No script changes needed.

```yaml
# Add a git repo
git:
  - name: my-docs
    url: https://github.com/org/repo.git
    category: 01-languages/python
    depth: 1

# Add a file download
wget:
  - name: spec.pdf
    url: https://example.com/spec.pdf
    category: 11-standards/w3c

# Add a Zeal/Dash docset
zeal:
  - name: Angular
    category: 02-web/frontend-frameworks
```

---

## Commands

| Command | What it does |
|---------|-------------|
| `./setup.sh` | Full bootstrap: install tools, create dirs, fetch all docs |
| `./setup.sh --dry-run` | Preview what setup would do |
| `./setup.sh --skip-fetch` | Create structure only, skip downloads |
| `./update.sh` | Update all sources (git pull + check for new files) |
| `./update.sh --git-only` | Only update git repos (fast) |
| `./sync.sh /Volumes/USB` | Sync library to external drive |
| `./sync.sh /Volumes/USB --dry-run` | Preview sync |
| `./scripts/index.sh` | Regenerate the index and status files |

---

## Obsidian Integration

After setup, an Obsidian vault is created at `~/docs/obsidian-vault/`. Open Obsidian → **Open folder as vault** → select that path.

The vault contains:
- A home page with links to every category
- Note templates (doc-template, cheatsheet-template)
- A status page showing what's installed

---

## Requirements

**macOS:** Homebrew (scripts install the rest)
**Linux (Debian/Ubuntu):** `sudo` access (scripts install via apt)
**Linux (RHEL/Fedora):** `sudo` access (scripts install via dnf/yum)

Dependencies installed automatically: `git`, `wget`, `curl`, `yq`, `p7zip`

---

## Platform

| OS | Status |
|----|--------|
| macOS (Apple Silicon + Intel) | Supported |
| Ubuntu / Debian | Supported |
| RHEL / Fedora | Supported |
| Windows | Not supported (use WSL2) |

---

## License

Scripts and configuration in this repo: MIT.

**Important:** All downloaded documentation is subject to its own license. Only download and store documentation you have the right to use. Most official documentation (Python, Rust, MDN, etc.) is freely available for personal use.
