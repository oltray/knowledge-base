# knowledge-base

A self-deploying offline documentation library. Clone it, run one command, walk away. Come back to a fully populated reference library covering programming languages, networking, security, databases, DevOps, and more.

---

## Quick Start

**macOS / Linux:**
```bash
git clone https://github.com/oltray/knowledge-base.git
cd knowledge-base
./setup.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/oltray/knowledge-base.git
cd knowledge-base
.\setup.ps1
```

> First-time Windows users: if you get an execution policy error, run this once in an elevated PowerShell:
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

That's it. The library builds itself.

**Default location:** `~/docs` (macOS/Linux) · `%USERPROFILE%\docs` (Windows)
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

### macOS / Linux

**Change where docs are stored:**
```bash
DOC_PATH=/Volumes/SSD/docs ./setup.sh
```

**Skip categories you don't need:**
```bash
SKIP_CATEGORIES="07-devops 11-standards" ./setup.sh
```

**Edit `config/settings.sh`** for persistent overrides.

### Windows

**Change where docs are stored:**
```powershell
.\setup.ps1 -DocPath "D:\docs"
# or
$env:DOC_PATH = "D:\docs"; .\setup.ps1
```

**Skip categories you don't need:**
```powershell
$env:SKIP_CATEGORIES = "07-devops 11-standards"; .\setup.ps1
```

**Edit `config/settings.ps1`** for persistent overrides.

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

### macOS / Linux

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

### Windows (PowerShell)

| Command | What it does |
|---------|-------------|
| `.\setup.ps1` | Full bootstrap: install tools, create dirs, fetch all docs |
| `.\setup.ps1 -DryRun` | Preview what setup would do |
| `.\setup.ps1 -SkipFetch` | Create structure only, skip downloads |
| `.\setup.ps1 -DocPath D:\docs` | Use a custom docs path |
| `.\update.ps1` | Update all sources (git pull + check for new files) |
| `.\update.ps1 -GitOnly` | Only update git repos (fast) |
| `.\sync.ps1 -Destination E:\` | Sync library to USB drive |
| `.\sync.ps1 -Destination E:\ -DryRun` | Preview sync |
| `.\sync.ps1 -Destination E:\ -Mirror` | Mirror mode (delete extra files at dest) |
| `.\scripts\index.ps1` | Regenerate the index and status files |

---

## Obsidian Integration

After setup, an Obsidian vault is created at `~/docs/obsidian-vault/` (macOS/Linux) or `%USERPROFILE%\docs\obsidian-vault\` (Windows). Open Obsidian → **Open folder as vault** → select that path.

The vault contains:
- A home page with links to every category
- Note templates (doc-template, cheatsheet-template)
- A status page showing what's installed

---

## Requirements

**macOS:** Homebrew (scripts install the rest)
**Linux (Debian/Ubuntu):** `sudo` access (scripts install via apt)
**Linux (RHEL/Fedora):** `sudo` access (scripts install via dnf/yum)
**Windows:** Windows 10 21H1+ or Windows 11 with winget (scripts install the rest)

| Platform | Auto-installed | Pre-required |
|----------|---------------|--------------|
| macOS | git, wget, curl, yq, p7zip | Homebrew |
| Linux (Debian/Ubuntu) | git, wget, curl, yq, p7zip-full | sudo |
| Linux (RHEL/Fedora) | git, wget, curl, yq, p7zip | sudo |
| Windows | git, yq | winget, PowerShell 5.1+, curl.exe & tar.exe (built-in Win10+) |

---

## Platform

| OS | Status |
|----|--------|
| macOS (Apple Silicon + Intel) | Supported |
| Ubuntu / Debian | Supported |
| RHEL / Fedora | Supported |
| Windows 10 21H1+ / Windows 11 | Supported (PowerShell) |
| Windows (older) | Use WSL2 and run `./setup.sh` |

---

## License

Scripts and configuration in this repo: MIT.

**Important:** All downloaded documentation is subject to its own license. Only download and store documentation you have the right to use. Most official documentation (Python, Rust, MDN, etc.) is freely available for personal use.
