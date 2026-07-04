#!/usr/bin/env bash
set -euo pipefail

log() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

os_is_mac() { [[ "$(uname -s)" == Darwin ]]; }
os_is_nixos() { [[ -f /etc/os-release ]] && grep -qi '^ID=nixos' /etc/os-release; }

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
flake_path="$repo_root/flake.nix"

usage() {
  cat <<'EOF'
Usage: ./install.sh

Nix must already be installed. This wrapper applies the flake for the current OS:
  macOS: creates /etc/nix-darwin/flake.nix, then runs darwin-rebuild switch
  NixOS: runs sudo nixos-rebuild switch
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

have nix || die "Nix is required before running this script."

if os_is_mac; then
  have darwin-rebuild || die "darwin-rebuild is required on macOS."
  [[ -f "$flake_path" ]] || die "Expected flake at $flake_path."
  log "Linking /etc/nix-darwin/flake.nix to $flake_path."
  sudo mkdir -p /etc/nix-darwin
  sudo ln -sfn "$flake_path" /etc/nix-darwin/flake.nix
  log "Applying nix-darwin configuration."
  cd "$repo_root"
  exec darwin-rebuild switch --flake .#mac
fi

if os_is_nixos; then
  have nixos-rebuild || die "nixos-rebuild is required on NixOS."
  log "Applying NixOS configuration."
  cd "$repo_root"
  exec sudo nixos-rebuild switch --flake ".#nix"
fi

die "Unsupported OS. This script currently supports macOS and NixOS."
