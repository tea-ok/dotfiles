#!/bin/sh
set -eu

log() { printf '[install-vi] %s\n' "$*"; }
die() { printf '[install-vi] ERROR: %s\n' "$*" >&2; exit 1; }

MODE=link
REPO_ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

usage() {
  cat <<'EOF'
Usage: ./install-vi.sh [--copy]

Install the portable vi config into the current user's home directory.

Options:
  --copy   Copy files instead of creating symlinks
  -h       Show this help text
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --copy)
      MODE=copy
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
  src="$1"
  dst="$2"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      log "$dst already matches. Skipping."
      return 0
    fi
    die "$dst already exists and is not managed by this installer."
  fi

  case "$MODE" in
    copy)
      cp "$src" "$dst"
      log "Copied $dst"
      ;;
    link)
      if ln -s "$src" "$dst" 2>/dev/null; then
        log "Linked $dst"
      else
        cp "$src" "$dst"
        log "Copied $dst"
      fi
      ;;
  esac
}

install_one "$REPO_ROOT/vim/.exrc" "$HOME/.exrc"
install_one "$REPO_ROOT/vim/.vimrc" "$HOME/.vimrc"
