#!/usr/bin/env bash
set -euo pipefail

# Colors (safe)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}==>${NC} $*"; }
warn() { echo -e "${YELLOW}==> WARN:${NC} $*"; }
err()  { echo -e "${RED}==> ERROR:${NC} $*"; }

is_wsl() {
  grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null
}

ask_yn() {
  # usage: ask_yn "Question" "Y"|"N"
  local q="$1"
  local def="${2:-Y}"
  local prompt=""

  if [[ "$def" == "Y" ]]; then
    prompt="[Y/n]"
  else
    prompt="[y/N]"
  fi

  while true; do
    read -r -p "$q $prompt " ans || true
    ans="${ans:-$def}"
    case "$ans" in
      Y|y) return 0 ;;
      N|n) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

strip_ansi() {
  # removes ANSI color codes
  sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

ensure_line_in_file() {
  # usage: ensure_line_in_file "line" "$file"
  local line="$1"
  local file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing command: $1"; exit 1; }
}