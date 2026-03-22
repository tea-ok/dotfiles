# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Install

On a fresh machine, run:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tea-ok
```

This installs chezmoi (if needed), clones this repo, and applies the dotfiles.
The bootstrap scripts then run automatically to set up the rest of the environment.

No GitHub authentication is required — this repo is public.

## What the bootstrap installs

| Component | Notes |
|---|---|
| Homebrew | Package manager for macOS and Linux |
| zsh | Default shell |
| Rust + Cargo | Toolchain via rustup |
| eza | Modern `ls` replacement |
| JetBrains Mono Nerd Font | Terminal font |
| tmux + TPM | Terminal multiplexer + plugin manager |
| neovim | Editor |
| fastfetch | System info tool |
| GitHub CLI (`gh`) | GitHub CLI (auth not configured automatically) |
| Ghostty | Terminal emulator — macOS only |
| Alacritty | Terminal emulator — Linux GUI systems only |

## Supported platforms

- macOS
- Ubuntu Linux
- `rpm-ostree` / atomic Linux (best-effort)

## Notes

- The dotfiles repo is public — no GitHub auth is needed for bootstrap.
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
| `run_once_after_10-homebrew.sh.tmpl` | Installs Homebrew and (on Ubuntu) base apt dependencies. Persists `brew shellenv` to `~/.zprofile` / `~/.profile`. |
| `run_once_after_15-keyboard.sh.tmpl` | Remaps Caps Lock to Ctrl. On Linux: sets it persistently via `localectl` and `gsettings` (GNOME), and for the current X11 session via `setxkbmap`. On macOS: prints instructions to do it manually in System Settings. |
| `run_once_after_20-zsh.sh.tmpl` | Installs zsh and sets it as the default shell via `chsh`. |
| `run_once_after_30-rust.sh.tmpl` | Installs Rust via rustup, then installs `eza` via Cargo. |
| `run_once_after_40-tools.sh.tmpl` | Installs `chezmoi`, `tmux`, `neovim`, `fastfetch`, and `gh` via Homebrew. |
| `run_once_after_50-fonts.sh.tmpl` | Installs JetBrains Mono Nerd Font (Homebrew cask on macOS, tarball to `~/.local/share/fonts` on Linux). |
| `run_once_after_60-terminal.sh.tmpl` | Installs Ghostty (macOS) or Alacritty (Linux GUI). Creates an Alacritty `.desktop` entry on Linux. |
| `run_once_after_70-tmux.sh.tmpl` | Clones [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm`. |
| `run_once_after_99-final-notes.sh.tmpl` | Prints manual next steps (refresh shell, install tmux plugins, reboot on atomic Linux). |

All scripts are idempotent — they check whether each thing is already installed and skip it if so.
