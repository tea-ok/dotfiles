#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
stow is no longer needed for this dotfiles repo.

User packages and symlinks are managed by Home Manager through:
  ./install.sh

The only remaining manual stow exception is keyd on Arch:
  sudo stow keyd

That exception can go away once the Arch machine moves to NixOS.
EOF
