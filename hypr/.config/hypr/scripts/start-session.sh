#!/usr/bin/env bash
set -euo pipefail

main_monitor="DP-4"
side_monitor="DP-5"
main_workspace="1"
side_workspace="4"

sleep 1

hyprctl dispatch moveworkspacetomonitor "$main_workspace" "$main_monitor"
hyprctl dispatch moveworkspacetomonitor "$side_workspace" "$side_monitor"

hyprctl dispatch exec "[workspace $side_workspace silent] firefox"
sleep 0.3
hyprctl dispatch exec "[workspace $main_workspace silent] firefox"
sleep 0.3
hyprctl dispatch exec "[workspace $main_workspace silent] ghostty"
sleep 0.3
hyprctl dispatch exec "[workspace $main_workspace silent] ghostty"
sleep 0.8
hyprctl dispatch workspace "$main_workspace"
