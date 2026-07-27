#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="${HOME}/.config/wallpapers"

# List image files and present selection via rofi
selection=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
  \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \
     -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" \) \
  -printf "%f\n" | sort | rofi -dmenu -p "Wallpaper" -i) || true

# Exit gracefully if rofi dismissed
[[ -z "$selection" ]] && exit 0

path="${WALLPAPER_DIR}/${selection}"
swww img "$path"
theme-switch --wallpaper "$path"
