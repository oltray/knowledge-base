# CLAUDE.md — knowledge-base

> Instructions for Claude Code working in this repository.

## Project Overview

A self-deploying offline documentation library. Users clone the repo, run
`setup.sh` (or `setup.ps1`), and get a fully populated reference library at
`~/docs`. An Obsidian vault at `~/docs/obsidian-vault` contains both downloaded
docs and a guided curriculum.

## Key Paths

| Path | Purpose |
|------|---------|
| `config/sources.yaml` | All documentation sources (git repos, PDFs, Dash docsets) |
| `config/settings.sh` | User-configurable paths (`DOC_PATH`, `OBSIDIAN_VAULT_PATH`) |
| `scripts/` | Setup, update, sync, and index scripts (bash + PowerShell) |
| `curriculum/` | Guided learning tracks and modules |
| `curriculum/overview.md` | Curriculum entry point — track status and links |
| `curriculum/meta/module-template.md` | Template for new modules |
| `docs/plans/` | Design docs and implementation plans |
| `obsidian/` | Vault config (plugins, themes, settings) — deployed to vault |

## Curriculum Conventions

### Track Status
- **P0** — implemented and available
- **P1** — next priority
- **P2** — planned later

### Module Authoring
Follow `curriculum/meta/module-template.md` exactly. Key sections:
- Header with Track, Level, Prerequisites
- What You'll Learn / Why It Matters
- Background Reading (links to local docs)
- Core Concepts
- Exercises
- Check Your Understanding
- Next Steps

### Relative Link Depth Table
From any curriculum file, the prefix to reach `$DOC_PATH/`:

| File location | Prefix |
|---|---|
| `curriculum/overview.md` | `../../` |
| `curriculum/meta/*.md` | `../../` |
| `curriculum/tracks/XX-track/index.md` | `../../../../` |
| `curriculum/tracks/XX-track/NN-module.md` | `../../../../` |
| `curriculum/tracks/XX-track/language/index.md` | `../../../../../` |
| `curriculum/tracks/XX-track/language/NN-module.md` | `../../../../../` |

### Completed Tracks (as of 2026-02-25)

| Track | Modules |
|---|---|
| 00 — Foundations | 4 |
| 01 — Languages: Python | 3 |
| 02 — Web | 2 |
| 01 — Languages: JavaScript | 4 |
| 03 — Systems | 4 |

### Next Tracks (P1 remaining)
- `01-languages/rust/` — Rust language track
- `01-languages/c-cpp/` — C/C++ language track

## Scripts

| Script | Purpose |
|--------|---------|
| `setup.sh` / `setup.ps1` | First-time vault setup |
| `update.sh` / `update.ps1` | Pull latest doc sources |
| `sync.sh` / `sync.ps1` | Copy curriculum to vault |
| `scripts/index.sh` / `index.ps1` | Index vault, patch Home.md |
| `scripts/check-curriculum-links.sh` | Verify all curriculum relative links |

## Workflow

1. Feature branches via git worktrees (`.worktrees/` — gitignored)
2. Commit frequently with conventional commits (`feat:`, `fix:`, `docs:`)
3. Run `scripts/check-curriculum-links.sh` before merging curriculum changes
4. Merge to `main`, push to origin
