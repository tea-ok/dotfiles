#!/usr/bin/env bash
set -euo pipefail

log() { printf '[apply] %s\n' "$*"; }
die() { printf '[apply] ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
resolve_stow() {
  local candidate
  for candidate in \
    "${STOW_BIN:-}" \
    "$(command -v stow 2>/dev/null || true)" \
    /home/linuxbrew/.linuxbrew/bin/stow \
    /usr/local/bin/stow \
    /opt/homebrew/bin/stow \
    /usr/bin/stow
  do
    [[ -n "$candidate" && -x "$candidate" ]] && printf '%s\n' "$candidate" && return 0
  done
  return 1
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PACKAGES=(zsh tmux nvim neovide opencode ghostty hypr waybar rofi swaync theme htop btop local ideavim zed vim)
ROOT_PACKAGES=(keyd)
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

STOW_BIN="$(resolve_stow)" || die "stow is required. Run ./install.sh first."

for pkg in "${PACKAGES[@]}"; do
  [[ -d "$REPO_ROOT/$pkg" ]] || die "Missing package directory: $pkg"
done

for pkg in "${PACKAGES[@]}"; do
  log "Applying $pkg"
  target="$HOME"
  for root_pkg in "${ROOT_PACKAGES[@]}"; do
    if [[ "$pkg" == "$root_pkg" ]]; then
      target="/"
      break
    fi
  done
  if [[ "$target" == "/" && "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Package $pkg targets / and must be applied with sudo."
  fi
  stow_args=(--dir="$REPO_ROOT" --target="$target" --restow)
  if (( DRY_RUN )); then
    stow_args+=(--no --verbose=2)
  fi
  if (( ADOPT )); then
    stow_args+=(--adopt)
  fi
  "$STOW_BIN" "${stow_args[@]}" "$pkg"
done

log "Done."
