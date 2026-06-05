# Hyprland Notes

This folder is your live Hyprland config on Arch. `~/.config/hypr` is symlinked here from `~/dotfiles`.

## Files

- `hyprland.lua`: entrypoint that loads the module tree
- `config/`: monitors, autostart, appearance, input, keybinds, rules
- `lib/apps.lua`: app commands used by the config
- `scripts/start-session.sh`: startup workspace and window layout
- `hyprpaper.conf`: wallpaper config
- `themes/`: Catppuccin palette files
- `wallpapers/`: tracked wallpapers

## Monitor layout

- `DP-5` is the left `1920x1080` monitor
- `DP-4` is the main `2560x1440` monitor

## Startup layout

On login, the session script tries to do this:

- workspace `2` on the left monitor with one Firefox window
- workspace `1` on the main monitor with:
  - one Firefox window
  - two Ghostty windows

The script lives in `scripts/start-session.sh`.

## Main shortcuts

- `Super + T`: open Ghostty
- `Super + Space`: open app launcher (`rofi drun`)
- `Super + Shift + Space`: open command launcher (`rofi run`)
- `Super + E`: open Dolphin
- `Super + F`: toggle fullscreen
- `Super + M`: logout / shutdown helper
- `Super + Q`: close focused window
- `Super + Shift + V`: toggle floating
- `Super + P`: toggle pseudo-tiling
- `Super + J`: toggle split direction in dwindle

## Navigation

- `Super + Left/Right/Up/Down`: move focus
- `Super + 1..0`: switch workspace `1..10`
- `Super + Shift + 1..0`: move focused window to workspace `1..10`
- `Super + Mouse Wheel`: cycle workspaces
- `Super + Left Click Drag`: move window
- `Super + Right Click Drag`: resize window

## Clipboard behavior

You changed this to feel more Mac-like:

- `Super + C`: send `Ctrl + C`
- `Super + V`: send `Ctrl + V`

That works well in common Linux apps, but it is a Hyprland-level shortcut translation, not a full keyboard-layer remap.

## Scratchpad

- `Super + S`: toggle the special workspace named `magic`
- `Super + Shift + S`: move the focused window into that scratchpad

## Media keys

- volume keys control PipeWire via `wpctl`
- brightness keys use `brightnessctl`
- media transport keys use `playerctl`

## Wallpaper

The current wallpaper is:

- `wallpapers/wallhaven-k828w6.jpg`

Hyprpaper loads it for both monitors through `hyprpaper.conf`.

## Appearance and animation

The current animation tuning in `config/appearance.lua` was adapted from:

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

## Open the current folder from terminal

Mac-style `open .` is not built in by default here.

Use:

```sh
dolphin .
```

or:

```sh
xdg-open .
```
