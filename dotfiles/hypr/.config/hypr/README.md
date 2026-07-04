# Hyprland notes

This is my Hyprland config. Home Manager links `~/.config/hypr` here with an out-of-store symlink, so config edits can be applied with `hyprctl reload`.

## Layout

- `hyprland.lua`: main entrypoint
- `config/`: monitors, autostart, appearance, input, keybinds, rules
- `lib/apps.lua`: shared app commands
- `hyprpaper.conf`: wallpaper config
- `hyprlock.conf`: lock screen config
- `hypridle.conf`: idle timers
- `themes/`: Catppuccin palette files
- `wallpapers/`: tracked wallpapers

## Monitors

- `DP-5` is the left `1920x1080` monitor
- `DP-4` is the main `2560x1440` monitor
- workspaces `1..9` are persistent
- workspace `4` is on `DP-5`; the other persistent workspaces are on `DP-4`

## Startup

On login, DankMaterialShell is started by the NixOS `dms` user service. Hyprland starts `hypridle`, `hyprpaper`, and 1Password on workspace `4`.

## Idle

Current idle flow:

- after `10m`: lock the session
- after `15m`: turn displays off
- after `30m`: suspend

On resume, displays are turned back on.

## Main shortcuts

- `Super + T`: open Kitty
- `Super + Space`: open Dank spotlight
- `Super + Shift + Space`: open Dank launcher
- `Super + E`: open Dolphin
- `Super + F`: maximize
- `Super + Shift + F`: toggle fullscreen
- `Super + Alt + L`: lock with Dank
- `Super + M`: open Dank power menu
- `Super + Q`: close focused window
- `Super + Shift + V`: toggle floating / tiled
- `Super + O`: toggle Dank/Hyprland overview
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

## Wallpaper

Current wallpaper:

- `wallpapers/wallhaven-k828w6.jpg`

Hyprpaper loads it on both monitors through `hyprpaper.conf`.

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

If the wallpaper does not update immediately:

```sh
pkill hyprpaper
hyprpaper &
```

If you change idle settings:

```sh
pkill hypridle
hypridle &
```

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
