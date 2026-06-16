#!/usr/bin/env bash
set -euo pipefail

mode=link
force=0
install_nvim=0

log() { printf '[fallback] %s\n' "$*"; }
die() { printf '[fallback] ERROR: %s\n' "$*" >&2; exit 1; }

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
src_root="$repo_root/fallback/essentials"

usage() {
  cat <<'EOF'
Usage: ./fallback/install.sh [--copy] [--force] [--nvim]

Install the minimal non-Nix fallback kit for zsh, tmux, and vim.

Options:
  --copy    Copy files instead of creating symlinks
  --force   Replace existing target files or symlinks
  --nvim    Also install the Neovim config to ~/.config/nvim
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
    --nvim|--with-nvim)
      install_nvim=1
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

install_tree() {
  local src="$1"
  local dst="$2"

  [[ -d "$src" ]] || die "Missing source directory: $src"
  mkdir -p "$(dirname -- "$dst")"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ "$mode" == link && -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
      log "$dst already links to $src. Skipping."
      return 0
    fi

    if [[ "$mode" == copy && -d "$dst" ]] && diff -qr "$src" "$dst" >/dev/null 2>&1; then
      log "$dst already matches. Skipping."
      return 0
    fi

    if [[ "$force" != 1 ]]; then
      die "$dst already exists. Re-run with --force to replace it."
    fi

    rm -rf -- "$dst"
  fi

  case "$mode" in
    copy)
      mkdir -p "$dst"
      cp -a "$src"/. "$dst"/
      log "Copied $dst"
      ;;
    link)
      ln -s "$src" "$dst"
      log "Linked $dst"
      ;;
  esac
}

ensure_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [[ -d "$tpm_dir/.git" ]]; then
    log "TPM already installed. Skipping."
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    die "git is required to install tmux plugin manager at $tpm_dir"
  fi

  mkdir -p "$(dirname -- "$tpm_dir")"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
  log "Installed TPM. Start tmux and press prefix + I to install tmux plugins."
}

install_one "$src_root/zsh/.zshrc" "$HOME/.zshrc"
install_one "$src_root/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
install_one "$src_root/zsh/.config/zsh/functions.zsh" "$HOME/.config/zsh/functions.zsh"
install_one "$src_root/tmux/.tmux.conf" "$HOME/.tmux.conf"
install_one "$src_root/vim/.vimrc" "$HOME/.vimrc"
install_one "$src_root/vim/.exrc" "$HOME/.exrc"
if [[ "$install_nvim" == 1 ]]; then
  install_tree "$repo_root/dotfiles/nvim/.config/nvim" "$HOME/.config/nvim"
fi
ensure_tpm

log "Installed fallback essentials."
