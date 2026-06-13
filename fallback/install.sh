#!/usr/bin/env bash
set -euo pipefail

mode=link
force=0

log() { printf '[fallback] %s\n' "$*"; }
die() { printf '[fallback] ERROR: %s\n' "$*" >&2; exit 1; }

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
src_root="$repo_root/fallback/essentials"

usage() {
  cat <<'EOF'
Usage: ./fallback/install.sh [--copy] [--force]

Install the minimal non-Nix fallback kit for zsh, tmux, vim, and IdeaVim.

Options:
  --copy    Copy files instead of creating symlinks
  --force   Replace existing target files or symlinks
  -h        Show this help text
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --copy)
      mode=copy
      ;;
    --force)
      force=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

install_one() {
  local src="$1"
  local dst="$2"

  [[ -f "$src" ]] || die "Missing source: $src"
  mkdir -p "$(dirname -- "$dst")"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      log "$dst already matches. Skipping."
      return 0
    fi

    if [[ "$force" != 1 ]]; then
      die "$dst already exists. Re-run with --force to replace it."
    fi

    rm -f -- "$dst"
  fi

  case "$mode" in
    copy)
      cp "$src" "$dst"
      log "Copied $dst"
      ;;
    link)
      ln -s "$src" "$dst"
      log "Linked $dst"
      ;;
  esac
}

install_one "$src_root/zsh/.zshrc" "$HOME/.zshrc"
install_one "$src_root/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
install_one "$src_root/zsh/.config/zsh/functions.zsh" "$HOME/.config/zsh/functions.zsh"
install_one "$src_root/tmux/.tmux.conf" "$HOME/.tmux.conf"
install_one "$src_root/vim/.vimrc" "$HOME/.vimrc"
install_one "$src_root/vim/.exrc" "$HOME/.exrc"
install_one "$src_root/ideavim/.ideavimrc" "$HOME/.ideavimrc"

log "Installed fallback essentials."
