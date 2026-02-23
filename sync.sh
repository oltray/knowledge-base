#!/usr/bin/env bash
# ==============================================================================
# sync.sh — Sync documentation library to an external drive or USB
#
# Usage:
#   ./sync.sh /Volumes/USB              # Sync to USB drive
#   ./sync.sh /Volumes/USB --dry-run    # Preview what would be synced
#   ./sync.sh /Volumes/USB --delete     # Mirror (delete files removed from source)
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/scripts/lib.sh"
source "$REPO_DIR/config/settings.sh"

DEST_PATH="${1:-}"
DRY_RUN=false
DELETE=false

for arg in "${@:2}"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --delete)  DELETE=true ;;
    --help|-h)
      echo "Usage: ./sync.sh <destination> [--dry-run] [--delete]"
      echo ""
      echo "  destination  Target path (e.g., /Volumes/USB or /mnt/usb)"
      echo "  --dry-run    Show what would be synced without doing it"
      echo "  --delete     Mirror mode: delete files at destination not in source"
      exit 0
      ;;
  esac
done

main() {
  if [[ -z "$DEST_PATH" ]]; then
    log_error "No destination provided"
    echo "Usage: ./sync.sh <destination> [--dry-run] [--delete]"
    exit 1
  fi

  if [[ ! -d "$DOC_PATH" ]]; then
    log_error "Source not found: $DOC_PATH"
    log_error "Run ./setup.sh first"
    exit 1
  fi

  if [[ ! -d "$DEST_PATH" ]]; then
    log_error "Destination not found: $DEST_PATH"
    log_error "Make sure the drive is mounted and the path exists"
    exit 1
  fi

  require_cmd rsync

  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${CYAN}║       knowledge-base sync                ║${RESET}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${RESET}"
  echo ""
  log_info "Source : $DOC_PATH"
  log_info "Dest   : $DEST_PATH/docs"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "DRY RUN — no changes will be made"
  fi

  local rsync_opts=("-avh" "--progress" "--stats"
    "--exclude='.git'"
    "--exclude='node_modules'"
    "--exclude='*.pyc'"
    "--exclude='__pycache__'"
  )

  if [[ "$DRY_RUN" == "true" ]]; then
    rsync_opts+=("--dry-run")
  fi

  if [[ "$DELETE" == "true" ]]; then
    rsync_opts+=("--delete")
    log_warn "Mirror mode: files at destination not in source will be deleted"
  fi

  log_step "Starting sync..."
  rsync "${rsync_opts[@]}" "$DOC_PATH/" "$DEST_PATH/docs/"

  if [[ "$DRY_RUN" == "false" ]]; then
    local dest_size
    dest_size=$(du -sh "$DEST_PATH/docs" 2>/dev/null | cut -f1)
    echo ""
    print_summary "Sync Complete" \
      "Source : $DOC_PATH" \
      "Dest   : $DEST_PATH/docs" \
      "Size   : $dest_size"
    echo ""
  fi
}

main "$@"
