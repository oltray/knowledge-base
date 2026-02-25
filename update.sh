#!/usr/bin/env bash
# ==============================================================================
# update.sh — Update all documentation sources
#
# Usage:
#   ./update.sh             # Update all sources
#   ./update.sh --git-only  # Only update git repositories
#   ./update.sh --no-index  # Skip regenerating the index
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/scripts/lib.sh"
source "$REPO_DIR/config/settings.sh"

GIT_ONLY=false
NO_INDEX=false

for arg in "$@"; do
  case "$arg" in
    --git-only) GIT_ONLY=true ;;
    --no-index) NO_INDEX=true ;;
    --help|-h)
      echo "Usage: ./update.sh [--git-only] [--no-index]"
      echo ""
      echo "  --git-only  Only git pull existing repos (fast)"
      echo "  --no-index  Skip regenerating the index after update"
      exit 0
      ;;
  esac
done

sync_curriculum() {
  local curriculum_src="${REPO_DIR}/curriculum"
  local curriculum_dest="${OBSIDIAN_VAULT_PATH}/curriculum"

  if [[ -L "$curriculum_dest" ]]; then
    log_info "Curriculum symlink up to date via git pull"
    return
  fi

  if [[ -d "$curriculum_dest" ]]; then
    log_step "Syncing curriculum directory (plain copy, not symlink)"
    if has_cmd rsync; then
      rsync -r --delete "$curriculum_src/" "$curriculum_dest/"
      log_success "Curriculum synced via rsync"
    else
      rm -rf "$curriculum_dest"
      cp -r "$curriculum_src" "$curriculum_dest"
      log_success "Curriculum synced via cp"
    fi
    return
  fi

  # Missing entirely — recreate
  log_step "Curriculum missing from vault — recreating"
  if [[ -d "$OBSIDIAN_VAULT_PATH" ]]; then
    ln -s "$curriculum_src" "$curriculum_dest"
    log_success "Curriculum symlink created: $curriculum_dest -> $curriculum_src"
  else
    log_warn "Obsidian vault not found at $OBSIDIAN_VAULT_PATH — skipping curriculum sync"
  fi
}

main() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${CYAN}║       knowledge-base update              ║${RESET}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${RESET}"
  echo ""

  require_cmd yq
  require_cmd git
  require_cmd wget

  if [[ ! -d "$DOC_PATH" ]]; then
    log_error "DOC_PATH not found: $DOC_PATH"
    log_error "Run ./setup.sh first to initialize the library"
    exit 1
  fi

  log_to_file "INFO" "=== Update started ==="

  if [[ "$GIT_ONLY" == "true" ]]; then
    log_info "Running git-only update..."
    bash "$REPO_DIR/scripts/fetch.sh" update
  else
    bash "$REPO_DIR/scripts/fetch.sh" update
  fi

  sync_curriculum

  if [[ "$NO_INDEX" == "false" ]]; then
    bash "$REPO_DIR/scripts/index.sh"
  fi

  log_to_file "INFO" "=== Update complete ==="

  echo ""
  print_summary "Update Complete" \
    "Library: $DOC_PATH" \
    "Index  : $DOC_PATH/00-index/README.md" \
    "Log    : $LOG_FILE"
  echo ""
}

main "$@"
