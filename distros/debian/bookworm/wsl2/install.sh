#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

# shellcheck source=/dev/null
source "$REPO_ROOT/shared/lib/common.sh"

# Load defaults
# shellcheck source=/dev/null
source "$SCRIPT_DIR/config/defaults.env"

LOG_FILE="$REPO_ROOT/install-debian-bookworm-wsl2.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log "WSL2 Dev Distros - Debian Bookworm (terminal-only)"
log "Log file: $LOG_FILE"

if is_wsl; then
  log "Detected WSL environment: $(uname -r)"
else
  warn "WSL not detected. Continuing anyway."
fi

# Confirm
if ! ask_yn "This will install a full terminal dev environment (APT + pyenv + SDKMAN). Continue?" "Y"; then
  warn "Cancelled."
  exit 0
fi

# Sudo keep-alive
if command -v sudo >/dev/null 2>&1; then
  log "Requesting sudo..."
  sudo -v
else
  err "sudo not found. Install sudo or run as root."
  exit 1
fi

# ----------------------------
# APT: update / upgrade / core
# ----------------------------
log "Updating APT..."
sudo apt-get update -y
log "Upgrading packages..."
sudo apt-get full-upgrade -y

log "Installing APT core packages (terminal-only)..."
APT_LIST="$SCRIPT_DIR/packages/apt-core.txt"
sudo apt-get install -y --no-install-recommends $(grep -vE '^\s*(#|$)' "$APT_LIST" | tr '\n' ' ')

# curl sanity (binary install via apt)
require_cmd curl
log "curl installed: $(curl --version | head -n1)"

# ----------------------------
# pyenv (Python)
# ----------------------------
install_pyenv() {
  if [[ -d "$HOME/.pyenv" ]]; then
    log "pyenv already installed at ~/.pyenv"
    return 0
  fi

  log "Installing pyenv (official installer)..."
  # Official command from pyenv docs: curl -fsSL https://pyenv.run | bash
  curl -fsSL https://pyenv.run | bash

  log "Configuring shell for pyenv..."
  ensure_line_in_file '' "$HOME/.bashrc"
  ensure_line_in_file '# --- pyenv ---' "$HOME/.bashrc"
  ensure_line_in_file 'export PYENV_ROOT="$HOME/.pyenv"' "$HOME/.bashrc"
  ensure_line_in_file 'export PATH="$PYENV_ROOT/bin:$PATH"' "$HOME/.bashrc"
  ensure_line_in_file 'eval "$(pyenv init -)"' "$HOME/.bashrc"
  ensure_line_in_file '# --- /pyenv ---' "$HOME/.bashrc"

  # For login shells (optional but helps in some setups)
  ensure_line_in_file '' "$HOME/.profile"
  ensure_line_in_file '# --- pyenv ---' "$HOME/.profile"
  ensure_line_in_file 'export PYENV_ROOT="$HOME/.pyenv"' "$HOME/.profile"
  ensure_line_in_file 'export PATH="$PYENV_ROOT/bin:$PATH"' "$HOME/.profile"
  ensure_line_in_file '# --- /pyenv ---' "$HOME/.profile"

  log "pyenv installed."
}

load_pyenv_now() {
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
  fi
}

install_python_versions() {
  require_cmd pyenv

  log "Python setup (pyenv)."
  echo "Default (recommended): $PYTHON_DEFAULT"
  echo "Alternative (newest):  $PYTHON_ALT"
  echo

  local choice="1"
  read -r -p "Choose default Python to set globally: [1] $PYTHON_DEFAULT / [2] $PYTHON_ALT : " choice || true
  choice="${choice:-1}"

  local global_py="$PYTHON_DEFAULT"
  if [[ "$choice" == "2" ]]; then
    global_py="$PYTHON_ALT"
  fi

  log "Installing Python (this can take a while)..."
  pyenv install -s "$global_py"
  pyenv global "$global_py"

  log "Upgrading pip tooling on pyenv global Python..."
  python -m pip install --upgrade pip setuptools wheel

  if ask_yn "Also install the other Python version too (so you have both)?" "N"; then
    local other="$PYTHON_ALT"
    [[ "$global_py" == "$PYTHON_ALT" ]] && other="$PYTHON_DEFAULT"
    pyenv install -s "$other"
  fi

  log "Python ready: $(python --version)"
}

# ----------------------------
# SDKMAN (Java / Gradle)
# ----------------------------
install_sdkman() {
  if [[ -d "$HOME/.sdkman" ]]; then
    log "SDKMAN already installed at ~/.sdkman"
    return 0
  fi

  log "Installing SDKMAN (official installer)..."
  # Official: curl -s "https://get.sdkman.io" | bash
  curl -s "https://get.sdkman.io" | bash
}

load_sdkman_now() {
  # shellcheck disable=SC1090
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    # sdkman-init.sh can reference optional env vars directly; relax nounset while sourcing.
    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    set -u
  fi
  require_cmd sdk
}

run_sdk() {
  # SDKMAN scripts are not fully nounset-safe; execute sdk with nounset temporarily disabled.
  set +u
  sdk "$@"
  local rc=$?
  set -u
  return "$rc"
}

pick_java_identifier() {
  # Picks latest Temurin for a given LTS major (e.g., 25), fallback to another major if missing.
  local major="$1"
  local vendor_regex="$2"

  # sdk list java output includes ANSI; strip it and extract identifiers like 25.0.2-tem
  run_sdk list java \
    | strip_ansi \
    | grep -Eo "${major}\.[0-9]+\.[0-9]+-${vendor_regex}" \
    | head -n1 \
    || true
}

install_java_gradle() {
  require_cmd sdk

  local java_major="$JAVA_LTS_MAJOR_DEFAULT"
  read -r -p "Java LTS major to install [default: $JAVA_LTS_MAJOR_DEFAULT] (enter for default): " java_major || true
  java_major="${java_major:-$JAVA_LTS_MAJOR_DEFAULT}"

  log "Resolving Java Temurin identifier via SDKMAN..."
  local java_id
  java_id="$(pick_java_identifier "$java_major" "$JAVA_VENDOR_REGEX")"

  if [[ -z "$java_id" ]]; then
    warn "Could not find Java $java_major Temurin in SDKMAN list. Falling back to Java $JAVA_LTS_FALLBACK..."
    java_id="$(pick_java_identifier "$JAVA_LTS_FALLBACK" "$JAVA_VENDOR_REGEX")"
  fi

  if [[ -z "$java_id" ]]; then
    warn "Could not auto-pick Temurin Java. Installing SDKMAN default latest java instead..."
    run_sdk install java
  else
    log "Installing Java: $java_id"
    run_sdk install java "$java_id"
    run_sdk default java "$java_id"
  fi

  log "Installing Gradle..."
  if ask_yn "Install Gradle $GRADLE_VERSION specifically (recommended for reproducibility)?" "Y"; then
    if ! run_sdk install gradle "$GRADLE_VERSION"; then
      warn "Gradle $GRADLE_VERSION not found in SDKMAN. Installing latest Gradle instead..."
      run_sdk install gradle
    fi
  else
    run_sdk install gradle
  fi

  if ask_yn "Also install Maven (common for Java projects)?" "Y"; then
    run_sdk install maven
  fi

  log "Java:   $(java -version 2>&1 | head -n1 || true)"
  log "Gradle: $(gradle --version 2>/dev/null | head -n2 | tail -n1 || true)"
}

# ----------------------------
# Node (optional) via nvm
# ----------------------------
install_nvm_node() {
  if ! ask_yn "Install Node.js LTS via nvm (recommended for JS/TS dev)?" "Y"; then
    return 0
  fi

  if [[ -d "$HOME/.nvm" ]]; then
    log "nvm already installed at ~/.nvm"
  else
    log "Installing nvm..."
    # Official from nvm docs (example command uses a fixed version tag)
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  fi

  # Load nvm now
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1090
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

  if ! command -v nvm >/dev/null 2>&1; then
    warn "nvm did not load correctly. Open a new terminal and run again."
    return 0
  fi

  log "Installing Node LTS ($NODE_LTS_ALIAS)..."
  nvm install "$NODE_LTS_ALIAS"
  nvm alias default "$NODE_LTS_ALIAS"
  node -v
  npm -v
}

# ----------------------------
# Run
# ----------------------------
install_pyenv
load_pyenv_now
install_python_versions

install_sdkman
load_sdkman_now
install_java_gradle

install_nvm_node

log "Cleaning APT..."
sudo apt-get autoremove -y
sudo apt-get clean

log "DONE! Your Debian Bookworm WSL2 terminal dev environment is ready."
warn "Open a NEW terminal (or run: source ~/.bashrc) to ensure PATH changes are fully applied."