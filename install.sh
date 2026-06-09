#!/usr/bin/env bash
set -euo pipefail

log() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

os_is_mac() { [[ "$(uname -s)" == Darwin ]]; }
os_is_arch() { [[ -f /etc/os-release ]] && grep -qi '^ID=arch' /etc/os-release; }

usage() {
  cat <<'EOF'
Usage: ./install.sh

Nix must already be installed. This wrapper applies the flake for the current OS:
  macOS: darwin-rebuild switch --flake .#Taavis-MacBook-Air
  Arch:  nix run home-manager -- switch --flake .#taavi@arch
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

have nix || die "Nix is required before running this script."

if os_is_mac; then
  have darwin-rebuild || die "darwin-rebuild is required on macOS."
  log "Applying nix-darwin configuration."
  exec darwin-rebuild switch --flake .#Taavis-MacBook-Air
fi

if os_is_arch; then
  log "Applying standalone Home Manager configuration."
  exec nix run home-manager -- switch --flake .#taavi@arch
fi

die "Unsupported OS. This script currently supports macOS and Arch Linux."
