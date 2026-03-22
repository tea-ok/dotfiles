# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Install

On a fresh machine, run:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tea-ok
```

This installs chezmoi (if needed), clones this repo, and applies the dotfiles.
The bootstrap scripts then run automatically to set up the rest of the environment.

## What the bootstrap installs

| Component | Notes |
|---|---|
| [Homebrew](https://brew.sh) | Package manager for macOS and Linux |
| [zsh](https://www.zsh.org) | Default shell, set as default via `chsh` |
| [Rust + Cargo](https://www.rust-lang.org) | Toolchain via rustup |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement (via cargo) |
| [yazi](https://github.com/sxyazi/yazi) | Terminal file manager (via cargo) |
| [chezmoi](https://chezmoi.io) | Dotfiles manager |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [Neovim](https://neovim.io) | Editor |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info tool |
| [GitHub CLI](https://cli.github.com) | GitHub CLI (auth not configured automatically) |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |
| [jq](https://jqlang.org) | JSON processor |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` replacement |
| [JetBrains Mono Nerd Font](https://www.jetbrains.com/lp/mono/) | Terminal font |
| [Ghostty](https://ghostty.org) | Terminal emulator — macOS only |
| [Alacritty](https://alacritty.org) | Terminal emulator — Linux GUI systems only |
| [TPM](https://github.com/tmux-plugins/tpm) | Tmux plugin manager |

## Auto-configured plugins

These are installed automatically the first time the shell, tmux, or Neovim launch — no manual steps needed.

**Shell** — managed by [Zinit](https://github.com/zdharma-continuum/zinit) (self-installs from `.zshrc`):

| Plugin | Notes |
|---|---|
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Zsh prompt theme |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Syntax highlighting in the shell |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | History-based command suggestions |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Additional tab completions |

**Tmux** — managed by TPM (from `.tmux.conf`):

| Plugin | Notes |
|---|---|
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless navigation between vim and tmux panes |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | System clipboard integration |
| [Dracula](https://github.com/dracula/tmux) | Color theme |

**Neovim** — managed by [lazy.nvim](https://github.com/folke/lazy.nvim):

| Component | Notes |
|---|---|
| [LazyVim](https://www.lazyvim.org) | Neovim configuration framework |

## Supported platforms

- macOS
- Ubuntu Linux
- `rpm-ostree` / atomic Linux (best-effort)

## Notes

- On macOS, **Caps Lock → Ctrl must be set manually**: System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys.
- After bootstrap, **open a new terminal** (or log out and back in) to pick up shell changes.
- On atomic Linux, a **reboot** may be required after `rpm-ostree` installs packages.
- The Alacritty `.desktop` icon path may need to be set manually on some systems — see the final bootstrap output for instructions.

## Updating

Pull the latest dotfiles and apply them:

```sh
chezmoi update
```

This syncs the repo and re-applies any changed config files. The bootstrap scripts
(`run_once_after_*`) only re-run if their content has changed — so adding a new tool
to a script will trigger that script on next update, but unchanged scripts are skipped.

To preview what would change before applying:

```sh
chezmoi diff
```

To edit a dotfile through chezmoi (keeps the source and home directory in sync):

```sh
chezmoi edit ~/.zshrc
chezmoi apply         # apply the edit
```

### Editing files directly

You can also edit files in their normal location (e.g. `~/.config/nvim/`) without going
through chezmoi first — but **`chezmoi update` will overwrite those changes** unless you
sync them back to the source directory beforehand:

```sh
# Sync your direct edits back into the chezmoi source
chezmoi re-add ~/.config/nvim/

# Then commit and push from the chezmoi source directory
chezmoi cd
git add .
git commit -m "update nvim config"
git push
exit
```

If you run `chezmoi update` before doing this, use `chezmoi diff` first to see what
would be overwritten, or `chezmoi merge <file>` to reconcile conflicts manually.

## How the bootstrap scripts work

chezmoi runs `run_once_after_*` scripts automatically, **once**, after applying dotfiles.
"Once" means per content hash — if a script changes, chezmoi will run it again on the
next `chezmoi update`. Scripts are numbered to control execution order.

| Script | What it does |
|---|---|
| `run_once_after_10-homebrew.sh.tmpl` | Installs [Homebrew](https://brew.sh) and (on Ubuntu) base apt dependencies. Persists `brew shellenv` to `~/.zprofile` / `~/.profile`. |
| `run_once_after_15-keyboard.sh.tmpl` | Remaps Caps Lock to Ctrl. On Linux: sets it persistently via `localectl` and `gsettings` (GNOME), and for the current X11 session via `setxkbmap`. On macOS: prints instructions to do it manually in System Settings. |
| `run_once_after_20-zsh.sh.tmpl` | Installs [zsh](https://www.zsh.org) and sets it as the default shell via `chsh`. |
| `run_once_after_30-rust.sh.tmpl` | Installs [Rust](https://www.rust-lang.org) via rustup, then installs [eza](https://github.com/eza-community/eza) and [yazi](https://github.com/sxyazi/yazi) via Cargo. |
| `run_once_after_40-tools.sh.tmpl` | Installs [chezmoi](https://chezmoi.io), [tmux](https://github.com/tmux/tmux), [Neovim](https://neovim.io), [fastfetch](https://github.com/fastfetch-cli/fastfetch), [gh](https://cli.github.com), [lazygit](https://github.com/jesseduffield/lazygit), [jq](https://jqlang.org), [fzf](https://github.com/junegunn/fzf), and [zoxide](https://github.com/ajeetdsouza/zoxide) via Homebrew. |
| `run_once_after_50-fonts.sh.tmpl` | Installs [JetBrains Mono Nerd Font](https://www.jetbrains.com/lp/mono/) (Homebrew cask on macOS, tarball to `~/.local/share/fonts` on Linux). |
| `run_once_after_60-terminal.sh.tmpl` | Installs [Ghostty](https://ghostty.org) (macOS) or [Alacritty](https://alacritty.org) (Linux GUI). Creates an Alacritty `.desktop` entry on Linux. |
| `run_once_after_70-tmux.sh.tmpl` | Clones [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm`. |
| `run_once_after_99-final-notes.sh.tmpl` | Prints manual next steps (refresh shell, install tmux plugins, reboot on atomic Linux). |

All scripts are idempotent — they check whether each thing is already installed and skip it if so.
