#!/usr/bin/env bash
# ==============================================================================
# settings.sh — User configuration for knowledge-base
# Override any of these by setting environment variables before running scripts
# ==============================================================================

# Root path where all documentation will be stored (outside the repo)
DOC_PATH="${DOC_PATH:-$HOME/docs}"

# Path to the Obsidian vault (defaults to inside DOC_PATH)
OBSIDIAN_VAULT_PATH="${OBSIDIAN_VAULT_PATH:-$DOC_PATH/obsidian-vault}"

# Log file location
LOG_FILE="${LOG_FILE:-$DOC_PATH/00-index/update.log}"

# Maximum parallel downloads (for wget sources)
MAX_PARALLEL="${MAX_PARALLEL:-4}"

# Git clone depth (1 = shallow, 0 = full)
DEFAULT_GIT_DEPTH="${DEFAULT_GIT_DEPTH:-1}"

# Zeal docset CDN location options: sanfrancisco, newyork, london, frankfurt, tokyo, sydney
ZEAL_CDN="${ZEAL_CDN:-sanfrancisco}"

# Skip categories (space-separated list of category prefixes to skip)
# Example: SKIP_CATEGORIES="07-devops 11-standards"
SKIP_CATEGORIES="${SKIP_CATEGORIES:-}"

# Sources manifest file
SOURCES_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sources.yaml"
