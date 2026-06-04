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

## Flow 1.5: Portable `vi` Over SSH

Use this when the remote machine has `git` and `vi`, but you do not want to install Stow, Neovim, or any plugins.

```sh
git clone --depth 1 https://github.com/tea-ok/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-vi.sh
```

That installs a small portable config to `~/.exrc` and `~/.vimrc`. If you prefer plain files instead of symlinks, use:

```sh
./install-vi.sh --copy
```

## Flow 2: Update The Repo

Use this when the current machine has changes you want to turn into the new source of truth.

```sh
cd ~/dotfiles
./apply.sh --adopt nvim
git diff
git commit -m "update nvim config"
git push
```

If you are editing the repo directly, just change the files under the package directories and commit them normally. Other machines pick the changes up with `git pull` and `./apply.sh`.

If the config already exists in your home directory and you want Stow to import it into the repo, use a first pass with:

```sh
./apply.sh --adopt
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
| `alacritty/` | `~/.config/alacritty/alacritty.toml` |
| `ghostty/` | `~/.config/ghostty/` on Linux, `~/Library/Application Support/com.mitchellh.ghostty/` on macOS |
| `hypr/` | `~/.config/hypr/` |
| `waybar/` | `~/.config/waybar/` |
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

On Arch, `install.sh` also installs `grim`, `slurp`, `wl-clipboard`, `pavucontrol`, `fzf`, and `zoxide` via `pacman`.

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
