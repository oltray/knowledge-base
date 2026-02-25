#!/usr/bin/env bash
# ==============================================================================
# index.sh — Generate a markdown index of what's installed in DOC_PATH
# Writes to DOC_PATH/00-index/README.md and DOC_PATH/00-index/status.md
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/../config/settings.sh"

INDEX_DIR="${DOC_PATH}/00-index"
README_FILE="${INDEX_DIR}/README.md"
STATUS_FILE="${INDEX_DIR}/status.md"

# Category display names (case statement — bash 3.x compatible)
get_category_name() {
  case "$1" in
    00-index)      echo "Index" ;;
    01-languages)  echo "Programming Languages" ;;
    02-web)        echo "Web Technologies" ;;
    03-systems)    echo "Operating Systems & Systems Programming" ;;
    04-networking) echo "Networking" ;;
    05-security)   echo "Security" ;;
    06-databases)  echo "Databases" ;;
    07-devops)     echo "DevOps & Infrastructure" ;;
    08-tools)      echo "Development Tools" ;;
    09-algorithms) echo "Algorithms & Data Structures" ;;
    10-architecture) echo "Software Architecture" ;;
    11-standards)  echo "Standards Documents" ;;
    99-extras)     echo "Books, Papers & Extras" ;;
    *)             echo "$1" ;;
  esac
}

generate_readme() {
  log_step "Generating index: $README_FILE"
  mkdir -p "$INDEX_DIR"

  {
    echo "# Knowledge Base — Documentation Library"
    echo ""
    echo "> Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "> Location: \`${DOC_PATH}\`"
    echo ""
    echo "---"
    echo ""
    echo "## Table of Contents"
    echo ""

    # TOC
    for category_dir in "$DOC_PATH"/[0-9][0-9]-*/; do
      [[ -d "$category_dir" ]] || continue
      local category_name
      category_name=$(basename "$category_dir")
      [[ "$category_name" == "00-index" ]] && continue
      local display_name
      display_name=$(get_category_name "$category_name")
      local anchor
      anchor=$(echo "$display_name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
      echo "- [$display_name](#$anchor)"
    done

    echo ""
    echo "---"
    echo ""

    # Categories
    local total_size=0
    for category_dir in "$DOC_PATH"/[0-9][0-9]-*/; do
      [[ -d "$category_dir" ]] || continue
      local category_name
      category_name=$(basename "$category_dir")
      [[ "$category_name" == "00-index" ]] && continue

      local display_name
      display_name=$(get_category_name "$category_name")
      local cat_size
      cat_size=$(du -sh "$category_dir" 2>/dev/null | cut -f1)

      echo "## $display_name"
      echo ""
      echo "_Path: \`${category_dir}\` | Size: ${cat_size}_"
      echo ""

      # List subdirectories with sizes
      local has_content=0
      for subdir in "$category_dir"*/; do
        [[ -d "$subdir" ]] || continue
        has_content=1
        local sub_name sub_size
        sub_name=$(basename "$subdir")
        sub_size=$(du -sh "$subdir" 2>/dev/null | cut -f1)
        echo "- \`${sub_name}/\` — ${sub_size}"
      done

      # List top-level files (PDFs, HTML, etc.)
      for file in "$category_dir"*; do
        [[ -f "$file" ]] || continue
        has_content=1
        local file_name file_size
        file_name=$(basename "$file")
        file_size=$(du -sh "$file" 2>/dev/null | cut -f1)
        echo "- \`${file_name}\` — ${file_size}"
      done

      if [[ $has_content -eq 0 ]]; then
        echo "_Empty — run \`./setup.sh\` or \`./update.sh\` to populate_"
      fi

      echo ""
    done

    echo "---"
    echo ""
    echo "## Total Library Size"
    echo ""
    local total
    total=$(du -sh "$DOC_PATH" 2>/dev/null | cut -f1)
    echo "**${total}** stored in \`${DOC_PATH}\`"
    echo ""
    echo "---"
    echo ""
    echo "_To regenerate this index: \`./scripts/index.sh\`_"
    echo "_To update all sources: \`./update.sh\`_"

  } > "$README_FILE"

  log_success "Index written → $README_FILE"
}

generate_status() {
  log_step "Generating status: $STATUS_FILE"

  {
    echo "# Source Status"
    echo ""
    echo "> Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "| Source | Type | Category | Status | Size |"
    echo "|--------|------|----------|--------|------|"

    # Git sources
    local git_count
    git_count=$(yq '.git | length' "$SOURCES_FILE" 2>/dev/null || echo 0)
    for i in $(seq 0 $((git_count - 1))); do
      local name category
      name=$(yq ".git[$i].name" "$SOURCES_FILE")
      category=$(yq ".git[$i].category" "$SOURCES_FILE")
      local target="${DOC_PATH}/${category}/${name}"
      local status size
      if [[ -d "$target/.git" ]]; then
        status="✅ Installed"
        size=$(du -sh "$target" 2>/dev/null | cut -f1)
      else
        status="⬜ Not fetched"
        size="—"
      fi
      echo "| $name | git | $category | $status | $size |"
    done

    # Wget sources
    local wget_count
    wget_count=$(yq '.wget | length' "$SOURCES_FILE" 2>/dev/null || echo 0)
    for i in $(seq 0 $((wget_count - 1))); do
      local name category extract
      name=$(yq ".wget[$i].name" "$SOURCES_FILE")
      category=$(yq ".wget[$i].category" "$SOURCES_FILE")
      extract=$(yq ".wget[$i].extract // false" "$SOURCES_FILE")
      local target_dir="${DOC_PATH}/${category}"
      local status size
      if [[ "$extract" == "true" ]]; then
        local base="${name%.*}"; base="${base%.*}"
        if [[ -d "${target_dir}/${base}" ]]; then
          status="✅ Installed"
          size=$(du -sh "${target_dir}/${base}" 2>/dev/null | cut -f1)
        elif [[ -f "${target_dir}/${name}" ]]; then
          status="✅ Downloaded"
          size=$(du -sh "${target_dir}/${name}" 2>/dev/null | cut -f1)
        else
          status="⬜ Not fetched"
          size="—"
        fi
      else
        if [[ -f "${target_dir}/${name}" ]]; then
          status="✅ Downloaded"
          size=$(du -sh "${target_dir}/${name}" 2>/dev/null | cut -f1)
        else
          status="⬜ Not fetched"
          size="—"
        fi
      fi
      echo "| $name | wget | $category | $status | $size |"
    done

    # Zeal sources
    local zeal_count
    zeal_count=$(yq '.zeal | length' "$SOURCES_FILE" 2>/dev/null || echo 0)
    for i in $(seq 0 $((zeal_count - 1))); do
      local name category
      name=$(yq ".zeal[$i].name" "$SOURCES_FILE")
      category=$(yq ".zeal[$i].category" "$SOURCES_FILE")
      local docset_dir="${DOC_PATH}/${category}/${name}.docset"
      local status size
      if [[ -d "$docset_dir" ]]; then
        status="✅ Installed"
        size=$(du -sh "$docset_dir" 2>/dev/null | cut -f1)
      else
        status="⬜ Not fetched"
        size="—"
      fi
      echo "| ${name}.docset | zeal | $category | $status | $size |"
    done

  } > "$STATUS_FILE"

  log_success "Status written → $STATUS_FILE"
}

generate_curriculum_status() {
  [[ ! -d "$OBSIDIAN_VAULT_PATH" ]] && return

  log_step "Generating curriculum status: $OBSIDIAN_VAULT_PATH/status.md"

  local out="$OBSIDIAN_VAULT_PATH/status.md"
  local repo_curriculum="$REPO_DIR/curriculum/tracks"

  count_modules() {
    find "$repo_curriculum/$1" -maxdepth 1 -name "*.md" ! -name "index.md" 2>/dev/null | wc -l | tr -d ' '
  }

  doc_status() {
    local path="$DOC_PATH/$1"
    if [[ -d "$path" ]] && [[ -n "$(ls -A "$path" 2>/dev/null)" ]]; then
      echo "✅ $1"
    else
      echo "⬜ $1 — run \`./update.sh\`"
    fi
  }

  module_status() {
    local n
    n=$(count_modules "$1")
    if [[ "$n" -gt 0 ]]; then
      echo "✅ $n modules"
    else
      echo "🔜 Planned"
    fi
  }

  local ts
  ts=$(date '+%Y-%m-%d %H:%M')

  cat > "$out" << EOF
# Library Status

_Generated: ${ts}_

## Curriculum Readiness

| Track | Modules | Docs Installed |
|---|---|---|
| [00 — Foundations](curriculum/tracks/00-foundations/index.md) | $(module_status "00-foundations") | — (uses system docs) |
| [01 — Python](curriculum/tracks/01-languages/python/index.md) | $(module_status "01-languages/python") | $(doc_status "01-languages/python") |
| [02 — Web](curriculum/tracks/02-web/index.md) | $(module_status "02-web") | $(doc_status "02-web/html-css") |
| [01 — JavaScript](curriculum/tracks/01-languages/javascript/index.md) | $(module_status "01-languages/javascript") | $(doc_status "01-languages/javascript") |
| [01 — Rust](curriculum/tracks/01-languages/rust/index.md) | $(module_status "01-languages/rust") | $(doc_status "01-languages/rust") |
| [01 — C/C++](curriculum/tracks/01-languages/c-cpp/index.md) | $(module_status "01-languages/c-cpp") | $(doc_status "01-languages/c-cpp") |
| [03 — Systems](curriculum/tracks/03-systems/index.md) | $(module_status "03-systems") | $(doc_status "03-systems/linux") |
| [04 — Networking](curriculum/tracks/04-networking/index.md) | $(module_status "04-networking") | $(doc_status "04-networking/protocols") |
| [05 — Security](curriculum/tracks/05-security/index.md) | $(module_status "05-security") | $(doc_status "05-security/owasp") |
| [06 — Databases](curriculum/tracks/06-databases/index.md) | $(module_status "06-databases") | $(doc_status "06-databases/sql") |
| [07 — DevOps](curriculum/tracks/07-devops/index.md) | $(module_status "07-devops") | $(doc_status "07-devops/docker") |

## Full Source Status

See [${DOC_PATH}/00-index/status.md](${DOC_PATH}/00-index/status.md) for the complete
list of all documentation sources and their installation state.

---
_Update docs: \`./update.sh\` · Get new curriculum modules: \`git pull\` in the repo_
EOF

  log_success "Curriculum status written → $out"
}

patch_vault_home() {
  [[ ! -d "$OBSIDIAN_VAULT_PATH" ]] && return
  local home="$OBSIDIAN_VAULT_PATH/Home.md"
  [[ ! -f "$home" ]] && return
  if grep -q "## Start Learning" "$home"; then
    log_skip "Home.md already has Start Learning section"
    return
  fi
  cat >> "$home" << 'EOF'

---

## Start Learning

→ [[curriculum/overview|Curriculum Overview]] — Where to start and how to use these docs
EOF
  log_success "Home.md patched with Start Learning section"
}

main() {
  require_cmd yq

  if [[ ! -d "$DOC_PATH" ]]; then
    log_error "DOC_PATH does not exist: $DOC_PATH"
    log_error "Run ./setup.sh first"
    exit 1
  fi

  generate_readme
  generate_status
  generate_curriculum_status
  patch_vault_home
}

main "$@"
