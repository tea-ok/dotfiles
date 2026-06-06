# Hyprland notes

This is my Hyprland config. On Arch, `~/.config/hypr` points here from `~/dotfiles`.

## Layout

- `hyprland.lua`: main entrypoint
- `config/`: monitors, autostart, appearance, input, keybinds, rules
- `lib/apps.lua`: shared app commands
- `scripts/start-session.sh`: startup workspace layout
- `hyprpaper.conf`: wallpaper config
- `hyprlock.conf`: lock screen config
- `hypridle.conf`: idle timers
- `themes/`: Catppuccin palette files
- `wallpapers/`: tracked wallpapers

## Monitors

- `DP-5` is the left `1920x1080` monitor
- `DP-4` is the main `2560x1440` monitor
- workspace `4` is pinned to `DP-5`

## Startup

On login, the session script tries to do this:

- workspace `4` on the left monitor with one Firefox window
- workspace `1` on the main monitor with:
  - one Firefox window
  - two Ghostty windows
- starts `hypridle`, `swaync`, `quickshell`, and `hyprpaper`

## Idle

Current idle flow:

- after `10m`: lock the session
- after `15m`: turn displays off
- after `30m`: suspend

On resume, displays are turned back on.

## Main shortcuts

- `Super + T`: open Ghostty
- `Super + Space`: open app launcher (`rofi drun`)
- `Super + Shift + Space`: open command launcher (`rofi run`)
- `Super + E`: open Dolphin
- `Super + F`: toggle fullscreen
- `Super + Shift + L`: lock with `hyprlock`
- `Super + M`: logout / shutdown helper
- `Super + Q`: close focused window
- `Super + Shift + V`: toggle floating / tiled
- `Super + P`: toggle pseudo-tiling
- `Super + I`: toggle split direction in dwindle
- `Super + J`: move focus down
- `Super + K`: move focus up
- `Super + L`: move focus right

## Navigation

- `Super + H/J/K/L`: move focus left/down/up/right
- `Super + 1..0`: switch workspace `1..10`
- `Super + Shift + 1..0`: move focused window to workspace `1..10`
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
