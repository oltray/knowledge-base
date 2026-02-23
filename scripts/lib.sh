#!/usr/bin/env bash
# ==============================================================================
# lib.sh — Shared utilities for knowledge-base scripts
# ==============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Logging
log_info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
log_success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
log_step()    { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }
log_skip()    { echo -e "${YELLOW}[SKIP]${RESET}  $*"; }

# Log to file as well (call after LOG_FILE is set)
log_to_file() {
  local level="$1"; shift
  local message="$*"
  if [[ -n "${LOG_FILE:-}" ]] && [[ -f "$LOG_FILE" || -d "$(dirname "$LOG_FILE")" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
  fi
}

# Detect OS
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ -f /etc/debian_version ]]; then
    echo "debian"
  elif [[ -f /etc/redhat-release ]]; then
    echo "redhat"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

# Check if a command exists
has_cmd() {
  command -v "$1" &>/dev/null
}

# Require a command or exit
require_cmd() {
  if ! has_cmd "$1"; then
    log_error "Required command not found: $1"
    log_error "Please install it and re-run setup.sh"
    exit 1
  fi
}

# Check if a category should be skipped
should_skip_category() {
  local category="$1"
  if [[ -z "${SKIP_CATEGORIES:-}" ]]; then
    return 1  # don't skip
  fi
  for skip in $SKIP_CATEGORIES; do
    if [[ "$category" == "$skip"* ]]; then
      return 0  # skip it
    fi
  done
  return 1
}

# Human-readable size of a directory
dir_size() {
  local path="$1"
  if [[ -d "$path" ]]; then
    du -sh "$path" 2>/dev/null | cut -f1
  else
    echo "0"
  fi
}

# Print a summary box
print_summary() {
  local title="$1"; shift
  echo -e "\n${BOLD}${CYAN}┌─────────────────────────────────────────┐${RESET}"
  echo -e "${BOLD}${CYAN}│${RESET} ${BOLD}${title}${RESET}"
  echo -e "${BOLD}${CYAN}├─────────────────────────────────────────┤${RESET}"
  for line in "$@"; do
    echo -e "${BOLD}${CYAN}│${RESET}  ${line}"
  done
  echo -e "${BOLD}${CYAN}└─────────────────────────────────────────┘${RESET}"
}
