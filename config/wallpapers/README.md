# Wallpapers

This directory is symlinked to `~/.config/wallpapers/` by the Hyprland NixOS module.

## Required Asset

The Hyprland autostart config (`config/hypr/hyprland.lua`) references:

```
~/.config/wallpapers/Fantasy-Landscape2.png
```

You must place a wallpaper image named `Fantasy-Landscape2.png` in this directory
for the default wallpaper to load on startup. Any PNG, JPG, JPEG, GIF, WEBP, or BMP
image will work — just name it `Fantasy-Landscape2.png`.

Alternatively, update the filename in `hyprland.lua` to match your preferred wallpaper.

## Adding Wallpapers

Place any image files here. The wallpaper-picker script will list all supported
image files (`.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.bmp`) from this directory
for selection via rofi.
