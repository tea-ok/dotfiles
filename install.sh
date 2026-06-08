#!/usr/bin/env bash
set -euo pipefail

log() { printf '[install] %s\n' "$*"; }
warn() { printf '[install] WARNING: %s\n' "$*" >&2; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
os_is_mac() { [[ "$(uname -s)" == Darwin ]]; }
os_is_arch() { [[ -f /etc/os-release ]] && grep -qi '^ID=arch' /etc/os-release; }

detect_mode() {
  if os_is_mac; then
    printf 'darwin\n'
    return 0
  fi

  if os_is_arch; then
    printf 'arch\n'
    return 0
  fi

  return 1
}

resolve_mode() {
  local requested="${1:-auto}"

  case "$requested" in
    auto)
      detect_mode || die "Could not auto-detect mode for this host. Use --mode arch or --mode darwin."
      ;;
    arch|darwin)
      printf '%s\n' "$requested"
      ;;
    *)
      die "Unsupported mode: $requested (expected arch or darwin)."
      ;;
  esac
}

usage() {
  cat <<'EOF'
Usage: ./install.sh [--mode arch|darwin]

Options:
  --mode MODE   Override auto-detected mode (arch or darwin)
  -h, --help    Show this help text
EOF
}

eval_brew_shellenv() {
  local brew_bin

  if [[ "$MODE" == "darwin" ]]; then
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

brew_has_formula() { brew list --formula "$1" >/dev/null 2>&1; }
brew_has_cask() { brew list --cask "$1" >/dev/null 2>&1; }

brew_install_formula_if_missing() {
  local pkg="$1"

  if brew_has_formula "$pkg" || have "$pkg"; then
    log "$pkg already installed. Skipping."
    return 0
  fi

  log "Installing $pkg via Homebrew..."
  brew install "$pkg" || warn "brew install $pkg failed; install manually if needed."
}

brew_install_cask_if_missing() {
  local pkg="$1"

  if brew_has_cask "$pkg"; then
    log "$pkg already installed via Homebrew cask. Skipping."
    return 0
  fi

  log "Installing $pkg via Homebrew cask..."
  brew install --cask "$pkg" || warn "brew install --cask $pkg failed; install manually if needed."
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

ensure_startup_access() {
  if [[ "$MODE" != "arch" ]]; then
    return 0
  fi

  log "Requesting sudo credentials for Arch setup..."
  sudo -v
}

install_brew_formulas() {
  local pkg

  for pkg in "${COMMON_BREW_FORMULAS[@]}"; do
    brew_install_formula_if_missing "$pkg"
  done

  :
}

install_darwin_casks() {
  local pkg

  for pkg in "${DARWIN_BREW_CASKS[@]}"; do
    case "$pkg" in
      ghostty)
        if [[ -d "/Applications/Ghostty.app" || -d "$HOME/Applications/Ghostty.app" ]]; then
          log "Ghostty.app already present. Skipping cask install."
        else
          brew_install_cask_if_missing "$pkg"
        fi
        ;;
      *)
        brew_install_cask_if_missing "$pkg"
        ;;
    esac
  done
}

ensure_arch_prereqs() {
  local pkg

  log "Installing Arch desktop packages via pacman..."
  sudo pacman -Syu --needed --noconfirm "${ARCH_PACMAN_PACKAGES[@]}"

  log "Ensuring niri.service wants dms..."
  systemctl --user add-wants niri.service dms || \
    warn "systemctl --user add-wants niri.service dms failed; run manually if needed."
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

install_nerd_font_arch() {
  local font_dir="$HOME/.local/share/fonts"
  local font_check="$font_dir/JetBrainsMonoNerdFont-Regular.ttf"
  local latest_tag tarball_url tmpdir ttf_count

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

  cleanup_font_tmpdir() {
    rm -rf "$tmpdir"
  }

  trap cleanup_font_tmpdir RETURN

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

  ttf_count="$(find "$tmpdir" -name '*.ttf' | wc -l | tr -d ' ')"
  if [[ "$ttf_count" -eq 0 ]]; then
    warn "No .ttf files found in archive. Skipping font copy."
    return 0
  fi

  log "Copying $ttf_count .ttf files to $font_dir..."
  find "$tmpdir" -name '*.ttf' -exec cp {} "$font_dir/" \;

  if have fc-cache; then
    log "Refreshing font cache..."
    fc-cache -fv "$font_dir" || warn "fc-cache failed; fonts may not be immediately available."
  else
    warn "fc-cache not found; font cache not refreshed. Install fontconfig or run fc-cache manually."
  fi
}

ensure_tree_sitter_cli() {
  load_cargo_env

  if have tree-sitter; then
    log "tree-sitter CLI already on PATH at $(command -v tree-sitter). Skipping."
    return 0
  fi

  if ! have cargo; then
    warn "cargo not found; cannot install tree-sitter-cli. Neovim parsers will need manual installation via :TSUpdate."
    return 0
  fi

  log "Installing tree-sitter-cli via cargo..."
  cargo install tree-sitter-cli || warn "cargo install tree-sitter-cli failed; run manually if needed."
}

ensure_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [[ -d "$tpm_dir" ]]; then
    log "TPM already present at $tpm_dir. Skipping."
    return 0
  fi

  if ! have git; then
    warn "git not found; cannot clone TPM."
    return 0
  fi

  log "Cloning TPM into $tpm_dir..."
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir" || \
    warn "TPM clone failed; run manually: git clone https://github.com/tmux-plugins/tpm $tpm_dir"
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
# Machine-local configuration - not tracked in version control.
# Add secrets, API keys, tokens, and machine-specific settings here.

# export OPENAI_API_KEY=""
# export ANTHROPIC_API_KEY=""
# export GITHUB_TOKEN=""
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
# export AWS_DEFAULT_REGION=""
EOF
  log "Created $local_zsh; fill in your local settings there."
}

ensure_uv_tool_latest() {
  local pkg="$1"

  if ! have uv; then
    warn "uv not found; cannot manage $pkg. Install uv and rerun bootstrap."
    return 0
  fi

  if have "$pkg"; then
    log "$pkg already on PATH at $(command -v "$pkg"). Upgrading via uv..."
    uv tool upgrade "$pkg" || warn "uv tool upgrade $pkg failed; update manually if needed."
    return 0
  fi

  log "Installing $pkg via uv..."
  uv tool install "$pkg@latest" || warn "uv tool install $pkg@latest failed; install manually if needed."
}

ensure_gopls() {
  if have gopls; then
    log "gopls already on PATH at $(command -v gopls). Skipping."
    return 0
  fi

  if ! have go; then
    warn "go not found; cannot install gopls. Install Go first."
    return 0
  fi

  log "Installing gopls via go install..."
  go install golang.org/x/tools/gopls@latest || warn "go install gopls failed; install manually: go install golang.org/x/tools/gopls@latest"
}

install_shared_tooling() {
  ensure_homebrew
  install_brew_formulas
  ensure_uv_tool_latest ruff
  ensure_uv_tool_latest ty
  ensure_rustup
  ensure_tree_sitter_cli
  ensure_gopls
  ensure_tpm
  ensure_local_zsh_stub
}

install_arch_mode() {
  log "Resolved mode: arch"
  ensure_arch_prereqs
  install_shared_tooling

  if [[ "${INSTALL_NERD_FONT:-yes}" == "yes" ]]; then
    install_nerd_font_arch
  else
    log "INSTALL_NERD_FONT=${INSTALL_NERD_FONT}; skipping font install."
  fi
}

install_darwin_mode() {
  log "Resolved mode: darwin"
  install_shared_tooling
  install_darwin_casks

  if [[ "${INSTALL_NERD_FONT:-yes}" == "yes" ]]; then
    log "JetBrainsMono Nerd Font is handled via Homebrew cask on macOS."
  else
    log "INSTALL_NERD_FONT=${INSTALL_NERD_FONT}; skipping font install."
  fi
}

print_next_steps() {
  cat <<EOF

Bootstrap complete for $MODE mode.

Next steps:
  1. Run ./apply.sh to create stow-managed symlinks.
  2. Open a new shell so updated PATH/cargo env is loaded.
  3. Run nvim - lazy.nvim will auto-install all plugins on first launch.
     Treesitter parsers (rust, lua, python, etc.) will compile automatically.
     Restart nvim once after the initial sync is done.
  4. Start tmux and press prefix + I to install TPM plugins.

EOF
}

COMMON_BREW_FORMULAS=(stow zsh tmux neovim uv fastfetch gh lazygit ripgrep fd jq fzf zoxide eza yazi unzip bat btop neovide stylua go prettier markdownlint-cli2)
DARWIN_BREW_CASKS=(font-jetbrains-mono-nerd-font ghostty)
ARCH_PACMAN_PACKAGES=(ghostty niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk dms-shell-niri matugen cava qt6-multimedia-ffmpeg grim hypridle hyprshutdown papirus-icon-theme pavucontrol qt5-quickcontrols2 qt6-declarative qt6-svg slurp wl-clipboard discord toolbox)
MODE="auto"

while (($#)); do
  case "$1" in
    --mode)
      shift || die "--mode requires a value."
      (($#)) || die "--mode requires a value."
      MODE="$1"
      ;;
    --mode=*)
      MODE="${1#*=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
  shift || true
done

MODE="$(resolve_mode "$MODE")"
ensure_startup_access

case "$MODE" in
  arch)
    install_arch_mode
    ;;
  darwin)
    install_darwin_mode
    ;;
esac

print_next_steps
