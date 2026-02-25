#!/usr/bin/env bash
# ==============================================================================
# setup.sh — Bootstrap the knowledge-base documentation library
#
# Usage:
#   ./setup.sh              # Full setup: install deps, create dirs, fetch all docs
#   ./setup.sh --dry-run    # Show what would happen without doing it
#   ./setup.sh --skip-fetch # Set up structure only, skip downloading docs
#
# Environment overrides (set before running):
#   DOC_PATH=/path/to/docs ./setup.sh
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/scripts/lib.sh"
source "$REPO_DIR/config/settings.sh"

DRY_RUN=false
SKIP_FETCH=false

for arg in "$@"; do
  case "$arg" in
    --dry-run)    DRY_RUN=true ;;
    --skip-fetch) SKIP_FETCH=true ;;
    --help|-h)
      echo "Usage: ./setup.sh [--dry-run] [--skip-fetch]"
      echo ""
      echo "  --dry-run     Show what would happen without doing anything"
      echo "  --skip-fetch  Create directory structure only, skip downloading docs"
      echo ""
      echo "Environment variables:"
      echo "  DOC_PATH      Where to store documentation (default: ~/docs)"
      exit 0
      ;;
  esac
done

# ------------------------------------------------------------------------------
# 1. Detect OS and install dependencies
# ------------------------------------------------------------------------------

install_deps() {
  log_step "Installing dependencies"

  local os
  os=$(detect_os)
  log_info "Detected OS: $os"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would install: git wget curl yq p7zip/p7zip-full"
    return
  fi

  case "$os" in
    macos)
      if ! has_cmd brew; then
        log_error "Homebrew not found. Install it from https://brew.sh then re-run setup.sh"
        exit 1
      fi
      log_info "Installing via Homebrew..."
      brew install git wget curl yq p7zip 2>&1 | grep -E "(Installing|Already installed|Pouring)" || true
      ;;
    debian)
      log_info "Installing via apt..."
      sudo apt-get update -qq
      sudo apt-get install -y git wget curl p7zip-full
      # yq from binary release (apt version is often outdated)
      if ! has_cmd yq; then
        local yq_version="v4.40.5"
        local yq_binary="yq_linux_amd64"
        log_info "Installing yq ${yq_version}..."
        sudo wget -qO /usr/local/bin/yq \
          "https://github.com/mikefarah/yq/releases/download/${yq_version}/${yq_binary}"
        sudo chmod +x /usr/local/bin/yq
      fi
      ;;
    redhat|linux)
      log_info "Installing via yum/dnf..."
      if has_cmd dnf; then
        sudo dnf install -y git wget curl p7zip
      else
        sudo yum install -y git wget curl p7zip
      fi
      # yq from binary
      if ! has_cmd yq; then
        local yq_version="v4.40.5"
        local yq_binary="yq_linux_amd64"
        log_info "Installing yq ${yq_version}..."
        sudo wget -qO /usr/local/bin/yq \
          "https://github.com/mikefarah/yq/releases/download/${yq_version}/${yq_binary}"
        sudo chmod +x /usr/local/bin/yq
      fi
      ;;
    *)
      log_warn "Unknown OS. Please manually install: git wget curl yq p7zip"
      ;;
  esac

  # Verify critical tools
  require_cmd git
  require_cmd wget
  require_cmd yq

  log_success "Dependencies ready"
}

# ------------------------------------------------------------------------------
# 2. Create directory structure
# ------------------------------------------------------------------------------

create_directories() {
  log_step "Creating documentation directory structure"
  log_info "Location: $DOC_PATH"

  local dirs=(
    "00-index"
    "01-languages/python"
    "01-languages/javascript"
    "01-languages/c-cpp"
    "01-languages/rust"
    "01-languages/go"
    "01-languages/java"
    "02-web/html-css"
    "02-web/frontend-frameworks"
    "02-web/backend"
    "03-systems/linux"
    "03-systems/windows"
    "03-systems/unix"
    "03-systems/embedded"
    "04-networking/protocols"
    "04-networking/rfcs"
    "04-networking/tools"
    "05-security/owasp"
    "05-security/nist"
    "05-security/cryptography"
    "05-security/pentesting"
    "06-databases/sql"
    "06-databases/nosql"
    "06-databases/theory"
    "07-devops/docker"
    "07-devops/kubernetes"
    "07-devops/ci-cd"
    "07-devops/cloud"
    "08-tools/git"
    "08-tools/editors"
    "08-tools/build-systems"
    "09-algorithms/references"
    "10-architecture/patterns"
    "11-standards/iso"
    "11-standards/ieee"
    "11-standards/w3c"
    "99-extras/books"
    "99-extras/papers"
    "99-extras/cheatsheets"
  )

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would create ${#dirs[@]} directories under $DOC_PATH"
    for dir in "${dirs[@]}"; do
      echo "  $DOC_PATH/$dir"
    done
    return
  fi

  for dir in "${dirs[@]}"; do
    mkdir -p "${DOC_PATH}/${dir}"
  done

  log_success "Created ${#dirs[@]} directories under $DOC_PATH"
}

# ------------------------------------------------------------------------------
# 3. Initialize log file
# ------------------------------------------------------------------------------

init_log() {
  if [[ "$DRY_RUN" == "true" ]]; then return; fi

  mkdir -p "$(dirname "$LOG_FILE")"
  touch "$LOG_FILE"
  log_to_file "INFO" "=== knowledge-base setup started ==="
  log_to_file "INFO" "DOC_PATH: $DOC_PATH"
  log_to_file "INFO" "REPO_DIR: $REPO_DIR"
}

# ------------------------------------------------------------------------------
# 4. Set up Obsidian vault
# ------------------------------------------------------------------------------

setup_obsidian() {
  log_step "Setting up Obsidian vault"

  local vault_src="${REPO_DIR}/obsidian"
  local vault_dest="$OBSIDIAN_VAULT_PATH"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would copy Obsidian vault from $vault_src → $vault_dest"
    return
  fi

  if [[ -d "$vault_dest" ]]; then
    log_skip "Obsidian vault already exists at $vault_dest"
    return
  fi

  cp -r "$vault_src" "$vault_dest"

  # Update the Home.md with the actual DOC_PATH
  if [[ -f "$vault_dest/Home.md" ]]; then
    sed -i.bak "s|DOC_PATH_PLACEHOLDER|${DOC_PATH}|g" "$vault_dest/Home.md" && \
      rm -f "$vault_dest/Home.md.bak"
  fi

  log_success "Obsidian vault ready → $vault_dest"
  log_info "Open Obsidian → Open vault as folder → Select: $vault_dest"
}

# ------------------------------------------------------------------------------
# 5. Set up curriculum layer
# ------------------------------------------------------------------------------

setup_curriculum() {
  log_step "Setting up curriculum layer"

  local curriculum_src="${REPO_DIR}/curriculum"
  local curriculum_dest="${OBSIDIAN_VAULT_PATH}/curriculum"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would create symlink: $curriculum_dest -> $curriculum_src"
    return
  fi

  if [[ -L "$curriculum_dest" ]]; then
    log_skip "Curriculum symlink already exists at $curriculum_dest"
    return
  fi

  if [[ -d "$curriculum_dest" ]]; then
    log_skip "Curriculum directory already exists at $curriculum_dest (not a symlink)"
    return
  fi

  ln -s "$curriculum_src" "$curriculum_dest"
  log_success "Curriculum symlink created: $curriculum_dest -> $curriculum_src"
  log_info "git pull in the repo will automatically keep curriculum content current"
}

# ------------------------------------------------------------------------------
# 6. Fetch all documentation (was 5)
# ------------------------------------------------------------------------------

fetch_docs() {
  if [[ "$SKIP_FETCH" == "true" ]]; then
    log_warn "Skipping documentation fetch (--skip-fetch)"
    return
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would run: $REPO_DIR/scripts/fetch.sh install"
    return
  fi

  bash "$REPO_DIR/scripts/fetch.sh" install
}

# ------------------------------------------------------------------------------
# 7. Generate index (was 6)
# ------------------------------------------------------------------------------

generate_index() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would run: $REPO_DIR/scripts/index.sh"
    return
  fi

  bash "$REPO_DIR/scripts/index.sh"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${CYAN}║        knowledge-base setup              ║${RESET}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${RESET}"
  echo ""

  if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "DRY RUN MODE — no changes will be made"
  fi

  install_deps
  create_directories
  init_log
  setup_obsidian
  setup_curriculum
  fetch_docs
  generate_index

  echo ""
  print_summary "Setup Complete" \
    "Docs location : $DOC_PATH" \
    "Obsidian vault: $OBSIDIAN_VAULT_PATH" \
    "Index file    : $DOC_PATH/00-index/README.md" \
    "Status file   : $DOC_PATH/00-index/status.md" \
    "Log file      : $LOG_FILE" \
    "" \
    "Next steps:" \
    "  Update docs  : ./update.sh" \
    "  Sync to USB  : ./sync.sh /path/to/usb"
  echo ""

  log_to_file "INFO" "=== knowledge-base setup complete ==="
}

main "$@"
