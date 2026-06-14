#!/usr/bin/env bash
set -euo pipefail

log() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

os_is_mac() { [[ "$(uname -s)" == Darwin ]]; }
os_is_nixos() { [[ -f /etc/os-release ]] && grep -qi '^ID=nixos' /etc/os-release; }

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
flake_path="$repo_root/flake.nix"
repo_dms_dir="$repo_root/dotfiles/dank/.config/DankMaterialShell"
local_dms_dir="${HOME:-}/.config/DankMaterialShell"

dms_config_exists() {
  local dir="$1"
  [[ -n "$dir" && -f "$dir/settings.json" ]]
}

copy_dms_config() {
  local src="$1"
  local dst="$2"

  mkdir -p "$dst"
  cp -a "$src"/. "$dst"/
}

sync_dms_config() {
  if [[ -z "${HOME:-}" ]]; then
    log "Skipping DMS config sync because HOME is not set."
    return
  fi

  local repo_has_config=0
  local local_has_config=0

  if dms_config_exists "$repo_dms_dir"; then
    repo_has_config=1
  fi

  if dms_config_exists "$local_dms_dir"; then
    local_has_config=1
  fi

  if (( repo_has_config == 1 && local_has_config == 0 )); then
    log "Restoring DMS config from repo to $local_dms_dir."
    copy_dms_config "$repo_dms_dir" "$local_dms_dir"
    return
  fi

  if (( repo_has_config == 0 && local_has_config == 1 )); then
    log "Importing DMS config from $local_dms_dir into the repo."
    mkdir -p "$(dirname "$repo_dms_dir")"
    copy_dms_config "$local_dms_dir" "$repo_dms_dir"
    return
  fi

  if (( repo_has_config == 1 && local_has_config == 1 )); then
    log "Leaving DMS config unchanged because both repo and local copies already exist."
    return
  fi

  log "Skipping DMS config sync because no settings.json exists in repo or local config."
}

usage() {
  cat <<'EOF'
Usage: ./install.sh

Nix must already be installed. This wrapper applies the flake for the current OS:
  macOS: creates /etc/nix-darwin/flake.nix, then runs darwin-rebuild switch
  NixOS: runs sudo nixos-rebuild switch

Before rebuilding, the script also bootstraps DankMaterialShell config by copying
`settings.json` and sibling files between:
  repo:   dotfiles/dank/.config/DankMaterialShell
  local:  ~/.config/DankMaterialShell

It only copies when exactly one side has a DMS config, so existing copies are not overwritten.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

have nix || die "Nix is required before running this script."
sync_dms_config

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
