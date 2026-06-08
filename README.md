# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Flow 1: Update This Machine

Use this when you want the repo's config on the machine you're sitting at.

```sh
git clone https://github.com/tea-ok/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh        # auto-detects arch vs darwin and installs tools
./apply.sh          # auto-detects arch vs darwin and creates stow symlinks
sudo ./apply.sh keyd  # applies the system keyd config
# open a new shell so PATH includes ~/.cargo/bin and ~/.local/bin
nvim                # lazy.nvim auto-installs plugins + treesitter parsers on first launch
                    # restart nvim once after the initial sync completes
```

If the machine already has a different config in the way, move it aside first:

```sh
mv ~/.config/nvim ~/.config/nvim.backup
./apply.sh nvim
```

## Packages

| Package | Target |
|---|---|
| `zsh/` | `~/.zshrc`, `~/.p10k.zsh`, `~/.config/zsh/functions.zsh` |
| `tmux/` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim/` |
| `neovide/` | `~/.config/neovide/config.toml` |
| `vim/` | `~/.exrc`, `~/.vimrc` |
| `ideavim/` | `~/.ideavimrc` |
| `opencode/` | `~/.config/opencode/opencode.json` |
| `ghostty/` | `~/.config/ghostty/` on Linux, `~/Library/Application Support/com.mitchellh.ghostty/` on macOS |
| `hypr/` | `~/.config/hypr/` including `hyprlock.conf`, `hypridle.conf`, and wallpaper config |
| `niri/` | `~/.config/niri/` |
| `dank/` | `~/.config/DankMaterialShell/` |
| `quickshell/` | `~/.config/quickshell/` |
| `rofi/` | `~/.config/rofi/` |
| `theme/` | `~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-4.0/settings.ini`, `~/.config/kdeglobals` |
| `htop/` | `~/.config/htop/` |
| `btop/` | `~/.config/btop/` |
| `local/` | `~/.local/bin/`, `~/.local/share/applications/` |
| `keyd/` | `/etc/keyd/default.conf` |
| `zed/` | `~/.config/zed/settings.json`, `~/.config/zed/keymap.json` |

## Bootstrap

`install.sh` auto-detects `arch` vs `darwin` by default, and also accepts `--mode arch|darwin` if you want to override that choice for testing.

It is Homebrew-first and idempotent. It installs:

- `stow`, `neovim`, `tmux`, `lazygit`, `stylua`, and the rest of the common CLI tools via Homebrew
- `ruff` and `ty` globally via `uv tool install`
- `rustup` + `cargo` (used to build Alacritty on Linux and to install `tree-sitter-cli`)
- `tree-sitter-cli` via cargo — required by nvim-treesitter v1 to compile language parsers
- TPM (tmux plugin manager)
- `~/.config/zsh/local.zsh` stub if missing
- on Arch, desktop packages are installed via `pacman`
- on macOS, Ghostty and the JetBrains Mono Nerd Font are installed via Homebrew casks

`quickshell` itself is not in this bootstrap script right now. On this machine it is installed separately as `quickshell-git` from the AUR.

On Arch it still falls back to non-Brew paths where needed (Nerd Fonts, TPM).

Because `uv tool` installs into `~/.local/bin` and cargo installs into `~/.cargo/bin`, open a new shell after bootstrap before launching Neovim.

## Apply

`apply.sh` also auto-detects `arch` vs `darwin` by default, and supports `--mode arch|darwin` as an override. It is safe to run with the macOS system Bash 3.2.

Use `./apply.sh --dry-run` to preview links, `./apply.sh <package>` to apply a subset, and `./apply.sh --adopt` once if you already have live config files in place.

If you do not pass any packages, it applies the defaults for the resolved mode:

- `darwin`: shared shell/editor/CLI config plus macOS-safe packages like `ghostty`
- `arch`: the shared set plus Linux desktop packages like `hypr`, `niri`, `dank`, `quickshell`, `rofi`, `theme`, and `local`

If you explicitly request a package that is unsupported in the selected mode, the script fails with a clear error instead of half-applying it.

Packages target `~` by default. `keyd/` targets `/`, so apply it with:

```sh
sudo ./apply.sh keyd
```

Examples:

```sh
./apply.sh --mode darwin --dry-run ghostty
./apply.sh --mode arch niri
```

## Local config

`~/.config/zsh/local.zsh` is machine-local and intentionally not tracked. Put secrets and per-machine overrides there.
