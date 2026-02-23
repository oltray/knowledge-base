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
