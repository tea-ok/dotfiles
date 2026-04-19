#!/usr/bin/env bash
set -euo pipefail

log() { printf '[apply] %s\n' "$*"; }
die() { printf '[apply] ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PACKAGES=(zsh tmux nvim opencode alacritty ghostty)
PACKAGES=()
DRY_RUN=0
ADOPT=0

usage() {
  cat <<'EOF'
Usage: ./apply.sh [options] [package ...]

Options:
  -n, --dry-run   Show the stow plan without writing files
  -a, --adopt     Move existing home files into the repo packages
  -h, --help      Show this help text

If no packages are provided, all default packages are applied.
EOF
}

while (($#)); do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      ;;
    -a|--adopt)
      ADOPT=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while (($#)); do
        PACKAGES+=("$1")
        shift
      done
      break
      ;;
    *)
      PACKAGES+=("$1")
      ;;
  esac
  shift || true
done

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  PACKAGES=("${DEFAULT_PACKAGES[@]}")
fi

have stow || die "stow is required. Run ./install.sh first."

for pkg in "${PACKAGES[@]}"; do
  [[ -d "$REPO_ROOT/$pkg" ]] || die "Missing package directory: $pkg"
done

for pkg in "${PACKAGES[@]}"; do
  log "Applying $pkg"
  stow_args=(--dir="$REPO_ROOT" --target="$HOME" --restow)
  if (( DRY_RUN )); then
    stow_args+=(--no --verbose=2)
  fi
  if (( ADOPT )); then
    stow_args+=(--adopt)
  fi
  stow "${stow_args[@]}" "$pkg"
done

log "Done."
