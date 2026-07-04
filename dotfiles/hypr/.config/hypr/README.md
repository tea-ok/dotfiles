# Hyprland notes

This is my Hyprland config. Home Manager links `~/.config/hypr` here with an out-of-store symlink, so config edits can be applied with `hyprctl reload`.

## Layout

- `hyprland.lua`: main entrypoint
- `config/`: monitors, autostart, appearance, input, keybinds, rules
- `lib/apps.lua`: shared app commands
- `themes/`: Catppuccin palette files
- `wallpapers/`: tracked wallpapers

## Monitors

- `DP-5` is the left `1920x1080` monitor
- `DP-4` is the main `2560x1440` monitor
- workspaces `1..9` are persistent
- workspace `4` is on `DP-5`; the other persistent workspaces are on `DP-4`

## Startup

On login, Caelestia Shell is started by its Home Manager user service. Hyprland opens 1Password on workspace `4`.

## Idle

Current idle flow:

- after `10m`: lock the session
- after `15m`: turn displays off
- after `30m`: suspend

Caelestia owns these idle actions through its shell config.

## Main shortcuts

- `Super + T`: open Kitty
- `Super + Space`: open Caelestia explorer
- `Super + Shift + Space`: open Caelestia launcher
- `Super + E`: open Dolphin
- `Super + F`: maximize
- `Super + Shift + F`: toggle fullscreen
- `Super + Alt + L`: lock with Caelestia
- `Super + M`: open Caelestia session menu
- `Super + Q`: close focused window
- `Super + Shift + V`: toggle floating / tiled
- `Super + O`: toggle Caelestia dashboard
- `Super + W`: toggle Hyprland group mode
- `Super + -`: shrink the focused split
- `Super + =` / `Super + Shift + =`: grow the focused split
- `Super + I`: toggle split direction in dwindle
- `Super + J`: move focus down
- `Super + K`: move focus up
- `Super + L`: move focus right

## Navigation

- `Super + H/J/K/L`: move focus left/down/up/right
- `Super + Shift + H/J/K/L`: move focused window left/down/up/right
- `Super + 1..9`: switch workspace `1..9`
- `Super + Ctrl + 1..9`: move focused window to workspace `1..9`
- `Super + Shift + 1..9`: move focused window to workspace `1..9`
- `Super + N/P`: switch to next/previous workspace
- `Super + Shift + N/P`: move focused window to next/previous workspace
- `Super + Mouse Wheel`: cycle workspaces
- `Super + Left Click Drag`: move window
- `Super + Right Click Drag`: resize window

## Clipboard

This is set up to feel more Mac-like:

- `Super + C`: send `Ctrl + C`
- `Super + V`: send `Ctrl + V`

This works in common Linux apps, but it is still a Hyprland shortcut translation, not a full keyboard-layer remap.

## Scratchpad

- `Super + S`: toggle the special workspace named `magic`
- `Super + Shift + S`: move the focused window into that scratchpad

## Media keys

- volume keys control PipeWire via `wpctl`
- brightness keys use `brightnessctl`
- media transport keys use `playerctl`

## Screenshots

- `Print`: save a selected region with `screenshot-snip`
- `Ctrl + Print`: open the Caelestia picker in clipboard mode
- `Alt + Print`: open the Caelestia picker in freeze + clipboard mode

## Wallpaper

Current wallpaper directory:

- `~/dotfiles/dotfiles/wallpapers`

Caelestia reads wallpapers from that directory.

## Appearance

Animation tuning in `config/appearance.lua` was adapted from:

- `ilyamiro/nixos-configuration`
- `config/sessions/hyprland/config/settings.conf`
- https://github.com/ilyamiro/nixos-configuration/blob/master/config/sessions/hyprland/config/settings.conf

## Reloading

After config edits:

```sh
hyprctl reload
```

Most edits under `dotfiles/hypr/.config/hypr` do not need a NixOS rebuild because `~/.config/hypr` is a live symlink to this directory.

If you change Caelestia settings, restart the `caelestia` user service.

## Open the current folder

Mac-style `open .` is not built in by default here.

Use:

```sh
dolphin .
```

or:

```sh
xdg-open .
```
