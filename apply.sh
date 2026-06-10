#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
stow is no longer needed for this dotfiles repo.

User packages and symlinks are managed by Home Manager through:
  ./install.sh

This repo no longer relies on stow on either macOS or NixOS.
EOF
