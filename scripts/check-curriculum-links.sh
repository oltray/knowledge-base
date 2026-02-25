#!/usr/bin/env bash
# ==============================================================================
# check-curriculum-links.sh — Verify all relative links in curriculum markdown
#
# Usage:
#   ./scripts/check-curriculum-links.sh
#   OBSIDIAN_VAULT_PATH=/path/to/vault ./scripts/check-curriculum-links.sh
#
# Exit code:
#   0 — all links valid
#   1 — one or more broken links found
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_DIR/config/settings.sh"

CURRICULUM_DIR="${OBSIDIAN_VAULT_PATH}/curriculum"

if [[ ! -d "$CURRICULUM_DIR" ]]; then
  echo "ERROR: Curriculum directory not found: $CURRICULUM_DIR" >&2
  echo "Run ./setup.sh first to initialize the vault and curriculum." >&2
  exit 1
fi

broken=0
checked=0

while IFS= read -r -d '' md_file; do
  # Skip the module template — it contains intentional placeholder links
  [[ "$md_file" == */meta/module-template.md ]] && continue

  file_dir="$(dirname "$md_file")"

  # Extract markdown links: ](path) — capture the path inside the parens
  while IFS= read -r link_path; do
    # Strip any fragment (#section)
    link_path="${link_path%%#*}"

    # Skip empty after stripping fragment
    [[ -z "$link_path" ]] && continue

    # Skip external URLs
    [[ "$link_path" == http://* || "$link_path" == https://* ]] && continue

    # Skip wiki-links (handled by Obsidian, not file paths)
    # (already excluded by the grep pattern, but guard here too)

    # Resolve the link relative to the containing file's directory.
    # Use python3 for cross-platform path normalization (resolves .. without
    # requiring the path to exist, unlike BSD realpath which lacks the -m flag).
    if [[ "$link_path" == /* ]]; then
      resolved="$link_path"
    else
      resolved="$(python3 -c \
        "import os.path,sys; print(os.path.normpath(os.path.join(sys.argv[1],sys.argv[2])))" \
        "$file_dir" "$link_path" 2>/dev/null || echo "")"
    fi

    [[ -z "$resolved" ]] && continue

    checked=$((checked + 1))

    if [[ ! -e "$resolved" ]]; then
      echo "BROKEN: $md_file"
      echo "        link: $link_path"
      echo "        resolved: $resolved"
      broken=$((broken + 1))
    fi
  done < <(
    grep -oE '\]\([^)]+\)' "$md_file" 2>/dev/null \
      | sed 's/^](\(.*\))$/\1/' \
      | grep -v '^http' \
      | grep -v '^\[\[' \
      || true
  )

done < <(find "$CURRICULUM_DIR" -name "*.md" -print0)

echo ""
echo "Link check complete: $checked links checked"

if [[ "$broken" -gt 0 ]]; then
  echo "FAILED: $broken broken link(s) found" >&2
  exit 1
else
  echo "PASSED: all links valid"
fi
