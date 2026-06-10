# dotfiles

Personal dotfiles managed with Nix, nix-darwin, and Home Manager.

The root is intentionally small. Nix wiring lives in `outputs/` and `lib/`,
system-level macOS configuration lives in `system/`, Home Manager modules live
in `home/`, raw managed config assets live in `dotfiles/`, and the small
non-Nix emergency kit lives in `fallback/`.

## Apply This Repo

Nix must already be installed before running the wrapper.

```sh
git clone https://github.com/tea-ok/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The wrapper auto-detects the current OS:

- macOS creates `/etc/nix-darwin/flake.nix`, then runs `darwin-rebuild switch --flake .#Taavis-MacBook-Air`
- Arch Linux runs `nix run home-manager -- switch --flake .#taavi@arch`

To preview or build manually:

```sh
nix build .#darwinConfigurations.Taavis-MacBook-Air.system --no-link
nix eval '.#homeConfigurations."taavi@arch".activationPackage.drvPath'
```

## Flake Outputs

- `darwinConfigurations."Taavis-MacBook-Air"`: nix-darwin system config for macOS, with Home Manager attached for user config.
- `homeConfigurations."taavi@arch"`: standalone Home Manager config for Arch Linux.

The macOS flake symlink should point at the root flake:

```sh
/etc/nix-darwin/flake.nix -> /Users/taavi-ok/dotfiles/flake.nix
```

## Layout

| Path | Purpose |
|---|---|
| `flake.nix` | Root flake inputs and delegation to `outputs/` |
| `outputs/` | Public flake outputs for nix-darwin and Home Manager |
| `lib/` | Shared Nix helpers, host names, usernames, and package setup |
| `system/darwin/` | macOS system-level nix-darwin configuration |
| `home/profiles/` | Small Home Manager entrypoints for common, macOS, and Arch |
| `home/programs/` | Focused Home Manager modules for shell, CLI, editors, and AI tools |
| `home/desktop/` | Platform desktop modules such as Ghostty, Niri, Rofi, and Quickshell |
| `dotfiles/` | Raw config trees referenced by Home Manager or kept for archival use |
| `fallback/` | Minimal non-Nix fallback kit for zsh, vim, and IdeaVim |

## Dotfiles

Home Manager manages user symlinks and package installation. The old stow-style
package directories now live under `dotfiles/` as source directories.

Examples:

- `dotfiles/nvim/` -> `~/.config/nvim`
- `dotfiles/zsh/` -> `~/.p10k.zsh` and `~/.config/zsh/functions.zsh`
- `dotfiles/vim/` -> `~/.vimrc` and `~/.exrc`
- `dotfiles/ideavim/` -> `~/.ideavimrc`
- `dotfiles/niri/` -> `~/.config/niri` on Arch
- `dotfiles/quickshell/`, `dotfiles/rofi/`, `dotfiles/theme/`, `dotfiles/dank/`, and `dotfiles/local/` -> Arch user config/assets

`~/.config/zsh/local.zsh` is machine-local and intentionally untracked. The Home
Manager zsh config sources it when present, but does not create or manage it.

## Non-Nix Fallback

For machines where Nix is not available, use the intentionally small fallback
kit:

```sh
./fallback/install.sh
```

See `fallback/README.md` for details. This fallback is not the full managed
desktop setup; it only covers portable zsh, vim, and IdeaVim essentials.

## Keyd Exception

`dotfiles/keyd/` still targets `/etc/keyd/default.conf` and is not managed by
Home Manager. On Arch, apply it manually until the machine moves to NixOS:

```sh
cd dotfiles
sudo stow keyd
```

## Stow

`stow` is no longer part of the normal workflow. `apply.sh` now prints a
migration notice instead of creating user symlinks.
