# dotfiles

Personal dotfiles managed with Nix, nix-darwin, and Home Manager.

## Apply This Repo

Nix must already be installed before running the wrapper.

```sh
git clone https://github.com/tea-ok/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The wrapper auto-detects the current OS:

- macOS runs `darwin-rebuild switch --flake .#Taavis-MacBook-Air`
- Arch Linux runs `nix run home-manager -- switch --flake .#taavi@arch`

To preview or build manually:

```sh
nix build .#darwinConfigurations.Taavis-MacBook-Air.system --no-link
nix build '.#homeConfigurations."taavi@arch".activationPackage' --no-link
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
| `flake.nix` | Root flake wiring nix-darwin and Home Manager outputs |
| `hosts/darwin.nix` | macOS system-level nix-darwin configuration |
| `home/common.nix` | Cross-platform user packages, modules, and dotfiles |
| `home/darwin.nix` | macOS-specific Home Manager config |
| `home/linux.nix` | Arch/Niri-specific Home Manager config |

## Dotfiles

Home Manager now manages user symlinks and package installation. The old stow package directories stay in the repo as source directories for Home Manager.

Examples:

- `nvim/` -> `~/.config/nvim`
- `zsh/` -> `~/.zshrc`, `~/.p10k.zsh`, `~/.config/zsh/functions.zsh`
- `ideavim/` -> `~/.ideavimrc`
- `niri/` -> `~/.config/niri` on Arch
- `quickshell/`, `rofi/`, `theme/`, `dank/`, and `local/` -> Arch user config/assets

`~/.config/zsh/local.zsh` is machine-local and intentionally untracked. The Home Manager zsh config sources it when present, but does not create or manage it.

## Keyd Exception

`keyd/` still targets `/etc/keyd/default.conf` and is not managed by Home Manager. On Arch, apply it manually until the machine moves to NixOS:

```sh
sudo stow keyd
```

## Stow

`stow` is no longer part of the normal workflow. `apply.sh` now prints a migration notice instead of creating user symlinks.
