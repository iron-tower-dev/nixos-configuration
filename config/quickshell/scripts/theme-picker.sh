#!/usr/bin/env bash
set -euo pipefail

PRESETS="catppuccin-mocha\nnord"

selection=$(echo -e "$PRESETS" | rofi -dmenu -p "Theme" -i) || exit 0

[[ -z "$selection" ]] && exit 0

theme-switch --preset "$selection"
