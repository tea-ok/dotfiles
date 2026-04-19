# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Flow 1: Update This Machine

Use this when you want the repo's config on the machine you're sitting at.

```sh
git clone https://github.com/tea-ok/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
./apply.sh
```

If the machine already has a different config in the way, move it aside first:

```sh
mv ~/.config/nvim ~/.config/nvim.backup
./apply.sh nvim
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
