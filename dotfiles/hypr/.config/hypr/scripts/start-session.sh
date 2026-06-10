#!/usr/bin/env bash
set -euo pipefail

sleep 1
hyprctl dispatch 'dofile(os.getenv("HOME") .. "/.config/hypr/scripts/start-session.lua")'
