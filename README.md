# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```sh
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
./apply.sh
```

If the config already exists in your home directory, use a first pass with:

```sh
./apply.sh --adopt
```

## Packages

| Package | Target |
|---|---|
| `zsh/` | `~/.zshrc`, `~/.p10k.zsh`, `~/.config/zsh/functions.zsh` |
| `tmux/` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim/` |
| `opencode/` | `~/.config/opencode/opencode.json` |
| `alacritty/` | `~/.config/alacritty/alacritty.toml` |
| `ghostty/` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` |

## Bootstrap

`install.sh` is Homebrew-first and idempotent. It installs `stow` plus the common tools from this setup, creates `~/.config/zsh/local.zsh` if missing, and keeps system-level changes manual.

On Linux it still falls back to the previous non-Brew paths where needed, including Nerd Fonts, Rust/cargo for Alacritty, and TPM.

## Apply

Use `./apply.sh --dry-run` to preview links, `./apply.sh <package>` to apply a subset, and `./apply.sh --adopt` once if you already have live config files in place.

## Local config

`~/.config/zsh/local.zsh` is machine-local and intentionally not tracked. Put secrets and per-machine overrides there.

## Notes

- This repo no longer manages default shell changes or keyboard remapping.
- `nic` is still defined in `~/.config/zsh/functions.zsh`.
- `opencode` settings live in `~/.config/opencode/opencode.json`.
