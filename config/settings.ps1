# ==============================================================================
# settings.ps1 — User configuration for knowledge-base (Windows / PowerShell)
#
# Override any setting by setting the environment variable before running:
#   $env:DOC_PATH = "D:\docs"; .\setup.ps1
# ==============================================================================

# Root path where all documentation will be stored (outside the repo)
if (-not $env:DOC_PATH)             { $env:DOC_PATH             = Join-Path $HOME "docs" }

# Path to the Obsidian vault
if (-not $env:OBSIDIAN_VAULT_PATH)  { $env:OBSIDIAN_VAULT_PATH  = Join-Path $env:DOC_PATH "obsidian-vault" }

# Log file location
if (-not $env:KB_LOG_FILE)          { $env:KB_LOG_FILE          = Join-Path $env:DOC_PATH "00-index\update.log" }

# Maximum parallel downloads (reserved for future use)
if (-not $env:MAX_PARALLEL)         { $env:MAX_PARALLEL         = "4" }

# Git clone depth (1 = shallow, 0 = full)
if (-not $env:DEFAULT_GIT_DEPTH)    { $env:DEFAULT_GIT_DEPTH    = "1" }

# Zeal docset CDN: sanfrancisco, newyork, london, frankfurt, tokyo, sydney
if (-not $env:ZEAL_CDN)             { $env:ZEAL_CDN             = "sanfrancisco" }

# Skip categories (space-separated prefixes to skip)
# Example: $env:SKIP_CATEGORIES = "07-devops 11-standards"; .\setup.ps1
if (-not $env:SKIP_CATEGORIES)      { $env:SKIP_CATEGORIES      = "" }

# Sources manifest (resolved relative to this file's directory)
$script:KB_SOURCES_FILE = Join-Path $PSScriptRoot "sources.yaml"
