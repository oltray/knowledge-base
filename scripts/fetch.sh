#!/usr/bin/env bash
# ==============================================================================
# fetch.sh — Core fetch engine
# Reads sources.yaml and downloads/clones all documentation sources
#
# Usage:
#   fetch.sh [install|update]
#   install (default) — fresh clone/download
#   update            — git pull existing repos, skip existing files
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/../config/settings.sh"

MODE="${1:-install}"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi
}

extract_archive() {
  local file="$1"
  local dest_dir="$(dirname "$file")"

  log_info "Extracting $(basename "$file")..."
  case "$file" in
    *.zip)
      unzip -q -o "$file" -d "$dest_dir" && rm -f "$file"
      ;;
    *.tar.gz|*.tgz)
      tar -xzf "$file" -C "$dest_dir" && rm -f "$file"
      ;;
    *.tar.bz2)
      tar -xjf "$file" -C "$dest_dir" && rm -f "$file"
      ;;
    *)
      log_warn "Unknown archive format, skipping extraction: $(basename "$file")"
      ;;
  esac
}

# ------------------------------------------------------------------------------
# Git sources
# ------------------------------------------------------------------------------

fetch_git_sources() {
  log_step "Processing Git repositories"

  local count
  count=$(yq '.git | length' "$SOURCES_FILE")

  if [[ "$count" == "0" ]] || [[ "$count" == "null" ]]; then
    log_warn "No git sources defined in sources.yaml"
    return
  fi

  local success=0 skipped=0 failed=0

  for i in $(seq 0 $((count - 1))); do
    local name url category depth
    name=$(yq ".git[$i].name" "$SOURCES_FILE")
    url=$(yq ".git[$i].url" "$SOURCES_FILE")
    category=$(yq ".git[$i].category" "$SOURCES_FILE")
    depth=$(yq ".git[$i].depth // 1" "$SOURCES_FILE")

    if should_skip_category "$category"; then
      log_skip "$name (category $category skipped)"
      ((skipped++)) || true
      continue
    fi

    local target_dir="${DOC_PATH}/${category}/${name}"
    ensure_dir "${DOC_PATH}/${category}"

    if [[ "$MODE" == "update" && -d "$target_dir/.git" ]]; then
      log_info "Updating $name..."
      if git -C "$target_dir" pull --rebase --autostash -q 2>&1; then
        log_success "$name updated"
        log_to_file "INFO" "Updated git repo: $name"
        ((success++)) || true
      else
        log_error "Failed to update $name"
        log_to_file "ERROR" "Failed to update git repo: $name"
        ((failed++)) || true
      fi
    elif [[ -d "$target_dir/.git" ]]; then
      log_skip "$name (already cloned — run update.sh to refresh)"
      ((skipped++)) || true
    else
      log_info "Cloning $name (depth=$depth)..."
      if git clone --depth="$depth" --quiet "$url" "$target_dir" 2>&1; then
        log_success "$name cloned → ${category}/${name}"
        log_to_file "INFO" "Cloned git repo: $name"
        ((success++)) || true
      else
        log_error "Failed to clone $name from $url"
        log_to_file "ERROR" "Failed to clone git repo: $name ($url)"
        ((failed++)) || true
      fi
    fi
  done

  log_info "Git sources — success: $success, skipped: $skipped, failed: $failed"
}

# ------------------------------------------------------------------------------
# Wget / download sources
# ------------------------------------------------------------------------------

fetch_wget_sources() {
  log_step "Processing file downloads"

  local count
  count=$(yq '.wget | length' "$SOURCES_FILE")

  if [[ "$count" == "0" ]] || [[ "$count" == "null" ]]; then
    log_warn "No wget sources defined in sources.yaml"
    return
  fi

  local success=0 skipped=0 failed=0

  for i in $(seq 0 $((count - 1))); do
    local name url category extract
    name=$(yq ".wget[$i].name" "$SOURCES_FILE")
    url=$(yq ".wget[$i].url" "$SOURCES_FILE")
    category=$(yq ".wget[$i].category" "$SOURCES_FILE")
    extract=$(yq ".wget[$i].extract // false" "$SOURCES_FILE")

    if should_skip_category "$category"; then
      log_skip "$name (category $category skipped)"
      ((skipped++)) || true
      continue
    fi

    local category_dir="${DOC_PATH}/${category}"
    local target_file="${category_dir}/${name}"
    ensure_dir "$category_dir"

    # Skip if already downloaded and not in update mode
    if [[ "$MODE" != "update" && -f "$target_file" ]]; then
      log_skip "$name (already exists)"
      ((skipped++)) || true
      continue
    fi

    # Skip if extracted directory already exists (for zip/tar)
    if [[ "$extract" == "true" && "$MODE" != "update" ]]; then
      local base_name="${name%.*}"
      base_name="${base_name%.*}"  # strip double extension e.g. .tar.gz
      if [[ -d "${category_dir}/${base_name}" ]]; then
        log_skip "$name (already extracted as ${base_name}/)"
        ((skipped++)) || true
        continue
      fi
    fi

    log_info "Downloading $name..."
    if wget -q --show-progress --retry-connrefused --waitretry=5 --tries=3 \
         -O "$target_file" "$url" 2>&1; then
      log_success "$name → ${category}/${name}"
      log_to_file "INFO" "Downloaded: $name"

      if [[ "$extract" == "true" ]]; then
        extract_archive "$target_file"
      fi

      ((success++)) || true
    else
      log_error "Failed to download $name from $url"
      log_to_file "ERROR" "Failed to download: $name ($url)"
      rm -f "$target_file"  # clean up partial download
      ((failed++)) || true
    fi
  done

  log_info "File downloads — success: $success, skipped: $skipped, failed: $failed"
}

# ------------------------------------------------------------------------------
# Zeal / Dash docsets
# ------------------------------------------------------------------------------

fetch_zeal_sources() {
  log_step "Processing Zeal/Dash docsets"

  local count
  count=$(yq '.zeal | length' "$SOURCES_FILE")

  if [[ "$count" == "0" ]] || [[ "$count" == "null" ]]; then
    log_warn "No zeal sources defined in sources.yaml"
    return
  fi

  local success=0 skipped=0 failed=0

  for i in $(seq 0 $((count - 1))); do
    local name category
    name=$(yq ".zeal[$i].name" "$SOURCES_FILE")
    category=$(yq ".zeal[$i].category" "$SOURCES_FILE")

    if should_skip_category "$category"; then
      log_skip "$name docset (category $category skipped)"
      ((skipped++)) || true
      continue
    fi

    local category_dir="${DOC_PATH}/${category}"
    local docset_dir="${category_dir}/${name}.docset"
    local tgz_file="${category_dir}/${name}.tgz"
    local docset_url="http://${ZEAL_CDN}.kapeli.com/feeds/${name}.tgz"
    ensure_dir "$category_dir"

    if [[ -d "$docset_dir" ]]; then
      log_skip "$name.docset (already installed)"
      ((skipped++)) || true
      continue
    fi

    log_info "Downloading $name docset..."
    if wget -q --show-progress --retry-connrefused --waitretry=5 --tries=3 \
         -O "$tgz_file" "$docset_url" 2>&1; then
      log_info "Extracting $name docset..."
      if tar -xzf "$tgz_file" -C "$category_dir" 2>&1; then
        rm -f "$tgz_file"
        log_success "$name.docset → ${category}/"
        log_to_file "INFO" "Installed docset: $name"
        ((success++)) || true
      else
        log_error "Failed to extract $name docset"
        rm -f "$tgz_file"
        ((failed++)) || true
      fi
    else
      log_error "Failed to download $name docset from $docset_url"
      log_to_file "ERROR" "Failed to download docset: $name"
      rm -f "$tgz_file"
      ((failed++)) || true
    fi
  done

  log_info "Docsets — success: $success, skipped: $skipped, failed: $failed"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
  require_cmd yq
  require_cmd git
  require_cmd wget

  if [[ ! -f "$SOURCES_FILE" ]]; then
    log_error "sources.yaml not found at: $SOURCES_FILE"
    exit 1
  fi

  log_step "Fetch mode: $MODE"
  log_info "Documentation path: $DOC_PATH"
  log_info "Sources file: $SOURCES_FILE"

  fetch_git_sources
  fetch_wget_sources
  fetch_zeal_sources

  log_step "Fetch complete"
}

main "$@"
