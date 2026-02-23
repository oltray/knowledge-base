#!/usr/bin/env bash
# ==============================================================================
# index.sh — Generate a markdown index of what's installed in DOC_PATH
# Writes to DOC_PATH/00-index/README.md and DOC_PATH/00-index/status.md
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/../config/settings.sh"

INDEX_DIR="${DOC_PATH}/00-index"
README_FILE="${INDEX_DIR}/README.md"
STATUS_FILE="${INDEX_DIR}/status.md"

# Category display names
declare -A CATEGORY_NAMES=(
  ["00-index"]="Index"
  ["01-languages"]="Programming Languages"
  ["02-web"]="Web Technologies"
  ["03-systems"]="Operating Systems & Systems Programming"
  ["04-networking"]="Networking"
  ["05-security"]="Security"
  ["06-databases"]="Databases"
  ["07-devops"]="DevOps & Infrastructure"
  ["08-tools"]="Development Tools"
  ["09-algorithms"]="Algorithms & Data Structures"
  ["10-architecture"]="Software Architecture"
  ["11-standards"]="Standards Documents"
  ["99-extras"]="Books, Papers & Extras"
)

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
      local display_name="${CATEGORY_NAMES[$category_name]:-$category_name}"
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

      local display_name="${CATEGORY_NAMES[$category_name]:-$category_name}"
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

main() {
  require_cmd yq

  if [[ ! -d "$DOC_PATH" ]]; then
    log_error "DOC_PATH does not exist: $DOC_PATH"
    log_error "Run ./setup.sh first"
    exit 1
  fi

  generate_readme
  generate_status
}

main "$@"
