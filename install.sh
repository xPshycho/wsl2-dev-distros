#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Distro detection (por ahora solo Debian Bookworm WSL2)
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
else
  echo "Cannot detect distro (missing /etc/os-release)."
  exit 1
fi

if [[ "${ID:-}" != "debian" ]]; then
  echo "This installer currently supports Debian only. Detected: ${ID:-unknown}"
  exit 1
fi

exec bash "$REPO_ROOT/distros/debian/bookworm/wsl2/install.sh"#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Distro detection (por ahora solo Debian Bookworm WSL2)
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
else
  echo "Cannot detect distro (missing /etc/os-release)."
  exit 1
fi

if [[ "${ID:-}" != "debian" ]]; then
  echo "This installer currently supports Debian only. Detected: ${ID:-unknown}"
  exit 1
fi

exec bash "$REPO_ROOT/distros/debian/bookworm/wsl2/install.sh"