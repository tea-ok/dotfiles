# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Flow 1: Update This Machine

Use this when you want the repo's config on the machine you're sitting at.

```sh
git clone https://github.com/tea-ok/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh        # installs tools, tree-sitter-cli, TPM
./apply.sh          # creates stow symlinks
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
| `quickshell/` | `~/.config/quickshell/` |
| `rofi/` | `~/.config/rofi/` |
| `theme/` | `~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-4.0/settings.ini`, `~/.config/kdeglobals` |
| `htop/` | `~/.config/htop/` |
| `btop/` | `~/.config/btop/` |
| `local/` | `~/.local/bin/`, `~/.local/share/applications/` |
| `keyd/` | `/etc/keyd/default.conf` |
| `zed/` | `~/.config/zed/settings.json`, `~/.config/zed/keymap.json` |

## Bootstrap

`install.sh` is Homebrew-first and idempotent. It installs:

- `stow`, `neovim`, `tmux`, `lazygit`, `stylua`, and the rest of the common CLI tools via Homebrew
- `ruff` and `ty` globally via `uv tool install`
- `rustup` + `cargo` (used to build Alacritty on Linux and to install `tree-sitter-cli`)
- `tree-sitter-cli` via cargo — required by nvim-treesitter v1 to compile language parsers
- TPM (tmux plugin manager)
- `~/.config/zsh/local.zsh` stub if missing
- on Arch, a few more packages are installed via pacman

`quickshell` itself is not in this bootstrap script right now. On this machine it is installed separately as `quickshell-git` from the AUR.

On Linux it falls back to non-Brew paths where needed (Nerd Fonts, Alacritty build, TPM).

Because `uv tool` installs into `~/.local/bin` and cargo installs into `~/.cargo/bin`, open a new shell after bootstrap before launching Neovim.

## Apply

Use `./apply.sh --dry-run` to preview links, `./apply.sh <package>` to apply a subset, and `./apply.sh --adopt` once if you already have live config files in place.

Packages target `~` by default. `keyd/` targets `/`, so apply it with:

```sh
sudo ./apply.sh keyd
```

## Local config

`~/.config/zsh/local.zsh` is machine-local and intentionally not tracked. Put secrets and per-machine overrides there.
