#!/usr/bin/env bash
set -euo pipefail

log() { printf '[install] %s\n' "$*"; }
warn() { printf '[install] WARNING: %s\n' "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

os_is_mac() { [[ "$(uname -s)" == Darwin ]]; }
os_is_ubuntu() { [[ -f /etc/os-release ]] && grep -qi '^ID=ubuntu' /etc/os-release; }
os_is_atomic() { have rpm-ostree; }

eval_brew_shellenv() {
  local brew_bin

  if os_is_mac; then
    brew_bin="/opt/homebrew/bin/brew"
    [[ -x "$brew_bin" ]] || brew_bin="/usr/local/bin/brew"
  else
    brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
    [[ -x "$brew_bin" ]] || brew_bin="$HOME/.linuxbrew/bin/brew"
  fi

  if [[ -x "$brew_bin" ]]; then
    eval "$("$brew_bin" shellenv)"
  fi
}

persist_line() {
  local file="$1" line="$2"
  mkdir -p "$(dirname "$file")"
  [[ -e "$file" ]] || : >"$file"
  grep -qxF "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >>"$file"
}

brew_has_formula() { brew list --formula "$1" >/dev/null 2>&1; }
brew_has_cask() { brew list --cask "$1" >/dev/null 2>&1; }

brew_install_formula_if_missing() {
  local pkg="$1"
  if brew_has_formula "$pkg" || have "$pkg"; then
    log "$pkg already installed. Skipping."
    return 0
  fi

  log "Installing $pkg via Homebrew..."
  brew install "$pkg" || warn "brew install $pkg failed — install manually if needed."
}

brew_install_cask_if_missing() {
  local pkg="$1"
  if brew_has_cask "$pkg"; then
    log "$pkg already installed via Homebrew cask. Skipping."
    return 0
  fi

  log "Installing $pkg via Homebrew cask..."
  brew install --cask "$pkg" || warn "brew install --cask $pkg failed — install manually if needed."
}

ensure_homebrew() {
  eval_brew_shellenv

  if have brew; then
    log "Homebrew already installed at $(command -v brew)."
    return 0
  fi

  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval_brew_shellenv
}

ensure_linux_prereqs() {
  if os_is_mac; then
    return 0
  fi

  log "Requesting sudo credentials for Linux setup..."
  sudo -v

  if os_is_ubuntu; then
    log "Installing base dependencies via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y \
      build-essential \
      ca-certificates \
      curl \
      file \
      fontconfig \
      git \
      pkg-config \
      xz-utils
  elif os_is_atomic; then
    warn "Atomic Linux detected. Skipping apt dependencies — ensure build tools are available."
  else
    warn "Unknown Linux distro. Skipping apt dependencies — ensure build tools are available."
  fi
}

load_cargo_env() {
  [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
}

ensure_rustup() {
  load_cargo_env

  if have cargo; then
    return 0
  fi

  if have rustup; then
    load_cargo_env
    return 0
  fi

  log "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  load_cargo_env
}

install_nerd_font_linux() {
  local font_dir="$HOME/.local/share/fonts"
  local font_check="$font_dir/JetBrainsMonoNerdFont-Regular.ttf"
  local latest_tag tarball_url tmpdir

  if [[ -f "$font_check" ]]; then
    log "JetBrainsMono Nerd Font already installed at $font_dir. Skipping."
    return 0
  fi

  log "Fetching latest Nerd Fonts release info..."
  latest_tag="$(curl -fsSL 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | awk 'NR == 1 { print; exit }')" || {
    warn "Could not fetch Nerd Fonts release info. Skipping font install."
    return 0
  }

  if [[ -z "$latest_tag" ]]; then
    warn "Could not determine latest Nerd Fonts tag. Skipping font install."
    return 0
  fi

  tarball_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${latest_tag}/JetBrainsMono.tar.xz"
  tmpdir="$(mktemp -d)"

  cleanup() { rm -rf "$tmpdir"; }
  trap cleanup EXIT

  log "Downloading JetBrainsMono Nerd Font ($latest_tag)..."
  if ! curl -fsSL "$tarball_url" -o "$tmpdir/JetBrainsMono.tar.xz"; then
    warn "Download failed. Skipping font install."
    return 0
  fi

  log "Extracting font archive..."
  if ! tar -xf "$tmpdir/JetBrainsMono.tar.xz" -C "$tmpdir"; then
    warn "Extraction failed. Skipping font install."
    return 0
  fi

  mkdir -p "$font_dir"

  local ttf_count
  ttf_count="$(find "$tmpdir" -name '*.ttf' | wc -l | tr -d ' ')"
  if [[ "$ttf_count" -eq 0 ]]; then
    warn "No .ttf files found in archive. Skipping font copy."
    return 0
  fi

  log "Copying $ttf_count .ttf files to $font_dir..."
  find "$tmpdir" -name '*.ttf' -exec cp {} "$font_dir/" \;

  if have fc-cache; then
    log "Refreshing font cache..."
    fc-cache -fv "$font_dir" || warn "fc-cache failed — fonts may not be immediately available."
  else
    warn "fc-cache not found — font cache not refreshed. Install fontconfig or run fc-cache manually."
  fi
}

install_terminal_linux() {
  local desktop_dir desktop_file icon_path candidate expanded

  if [[ "${INSTALL_GUI_TERMINAL:-auto}" == "no" ]]; then
    log "INSTALL_GUI_TERMINAL=no — skipping terminal emulator install."
    return 0
  fi

  if [[ "${INSTALL_GUI_TERMINAL:-auto}" == "auto" ]]; then
    if [[ -n "${SSH_CONNECTION:-}" || -n "${SSH_CLIENT:-}" || -n "${SSH_TTY:-}" ]]; then
      log "Headless SSH session detected. Skipping terminal emulator install."
      return 0
    fi
    if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
      log "No GUI display detected. Skipping terminal emulator install."
      return 0
    fi
  fi

  if have alacritty; then
    log "Alacritty already on PATH at $(command -v alacritty). Skipping build."
  else
    if os_is_ubuntu; then
      log "Installing Alacritty build dependencies via apt..."
      sudo apt-get install -y \
        cmake \
        pkg-config \
        libfreetype6-dev \
        libfontconfig1-dev \
        libxcb-xfixes0-dev \
        libxkbcommon-dev \
        python3 \
        desktop-file-utils || warn "Some apt deps may have failed — Alacritty build might fail."
    fi

    ensure_rustup

    if ! have cargo; then
      warn "cargo not found — cannot build Alacritty. Install Rust first."
      return 0
    fi

    log "Installing Alacritty via cargo..."
    cargo install alacritty || {
      warn "cargo install alacritty failed — install manually if needed."
      return 0
    }
  fi

  if [[ "${INSTALL_ALACRITTY_DESKTOP:-yes}" != "yes" ]]; then
    log "INSTALL_ALACRITTY_DESKTOP=${INSTALL_ALACRITTY_DESKTOP} — skipping desktop entry."
    return 0
  fi

  if ! have alacritty; then
    warn "alacritty not on PATH — skipping .desktop file creation."
    return 0
  fi

  desktop_dir="$HOME/.local/share/applications"
  desktop_file="$desktop_dir/alacritty.desktop"

  if [[ -f "$desktop_file" ]]; then
    log "Desktop entry already exists at $desktop_file. Skipping (preserving any manual edits)."
    return 0
  fi

  icon_path=""
  for candidate in \
    "$HOME/.cargo/registry/src"/*/alacritty-*/extra/logo/alacritty-term.svg \
    "$HOME/.cargo/registry/src"/*/alacritty-*/extra/logo/alacritty.svg \
    /usr/share/pixmaps/Alacritty.svg \
    /usr/share/pixmaps/alacritty.svg \
    /usr/share/icons/hicolor/scalable/apps/Alacritty.svg \
    /usr/share/icons/hicolor/scalable/apps/alacritty.svg; do
    for expanded in $candidate; do
      if [[ -f "$expanded" ]]; then
        icon_path="$expanded"
        break 2
      fi
    done
  done

  if [[ -n "$icon_path" ]]; then
    log "Found Alacritty icon at: $icon_path"
  else
    warn "Could not auto-detect Alacritty icon path."
    warn "The .desktop file will be created with an empty Icon= field."
    warn "Edit $desktop_file and set the correct Icon= path manually."
  fi

  mkdir -p "$desktop_dir"
  log "Writing $desktop_file..."
  cat >"$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=Alacritty
Exec=alacritty
Icon=${icon_path}
Terminal=false
Categories=System;TerminalEmulator;
StartupWMClass=Alacritty
EOF

  if have update-desktop-database; then
    update-desktop-database "$desktop_dir" 2>/dev/null || \
      warn "update-desktop-database failed — desktop entry may not be immediately visible."
  fi

  log "Desktop entry created at $desktop_file"
}

ensure_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [[ -d "$tpm_dir" ]]; then
    log "TPM already present at $tpm_dir. Skipping."
    return 0
  fi

  if ! have git; then
    warn "git not found — cannot clone TPM."
    return 0
  fi

  log "Cloning TPM into $tpm_dir..."
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir" || \
    warn "TPM clone failed — run manually: git clone https://github.com/tmux-plugins/tpm $tpm_dir"
}

ensure_local_zsh_stub() {
  local local_zsh="$HOME/.config/zsh/local.zsh"

  if [[ -f "$local_zsh" ]]; then
    log "$local_zsh already exists. Skipping."
    return 0
  fi

  mkdir -p "$(dirname "$local_zsh")"
  cat >"$local_zsh" <<'EOF'
# ~/.config/zsh/local.zsh
# Machine-local configuration — not tracked in version control.
# Add secrets, API keys, tokens, and machine-specific settings here.

# export OPENAI_API_KEY=""
# export ANTHROPIC_API_KEY=""
# export GITHUB_TOKEN=""
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
# export AWS_DEFAULT_REGION=""
EOF
  log "Created $local_zsh — fill in your local settings there."
}

install_brew_packages() {
  local pkg

  for pkg in stow zsh tmux neovim fastfetch gh lazygit ripgrep jq fzf zoxide eza yazi unzip; do
    brew_install_formula_if_missing "$pkg"
  done

  if os_is_mac; then
    brew_install_cask_if_missing font-jetbrains-mono-nerd-font
    if [[ -d "/Applications/Ghostty.app" || -d "$HOME/Applications/Ghostty.app" ]]; then
      log "Ghostty.app already present. Skipping cask install."
    else
      brew_install_cask_if_missing ghostty
    fi
  fi
}

main() {
  if ! os_is_mac; then
    ensure_linux_prereqs
  fi

  ensure_homebrew
  install_brew_packages

  if os_is_mac; then
    if [[ "${INSTALL_NERD_FONT:-yes}" == "yes" ]]; then
      log "JetBrainsMono Nerd Font is handled via Homebrew cask on macOS."
    else
      log "INSTALL_NERD_FONT=${INSTALL_NERD_FONT} — skipping font install."
    fi
  else
    if [[ "${INSTALL_NERD_FONT:-yes}" == "yes" ]]; then
      install_nerd_font_linux
    else
      log "INSTALL_NERD_FONT=${INSTALL_NERD_FONT} — skipping font install."
    fi
  fi

  if os_is_mac; then
    log "Ghostty is handled via Homebrew cask on macOS."
  else
    install_terminal_linux
  fi

  ensure_tpm
  ensure_local_zsh_stub

  cat <<'EOF'

Bootstrap complete.

Next steps:
  1. Run ./apply.sh to create stow-managed symlinks.
  2. Open a new shell so updated PATH entries are loaded.
  3. Start tmux and press prefix + I to install TPM plugins.

EOF
}

main "$@"
