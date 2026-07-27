#!/usr/bin/env bash
# theme-switch.sh — Standalone theme switching script for Quickshell integration
# This is an alternative entry point to the Nix-built theme-switch script.
# It can be invoked directly by Quickshell to trigger theme changes.
#
# Requirements: 18.3, 18.5, 18.7

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/theming"
STATE_FILE="$STATE_DIR/active-theme"
MATUGEN_ERROR_LOG="$STATE_DIR/matugen-error.log"
mkdir -p "$STATE_DIR"

# Available preset themes
AVAILABLE_PRESETS="catppuccin-mocha, nord"

usage() {
  cat >&2 <<EOF
Usage: theme-switch [--wallpaper <path>] [--preset <name>]

Options:
  --wallpaper <path>   Generate color scheme from wallpaper image via matugen
  --preset <name>      Apply a predefined color scheme
  --help, -h           Show this help message

Available presets: $AVAILABLE_PRESETS
EOF
  exit 1
}

# Apply colors to GTK (writes gtk.css overrides)
apply_gtk() {
  local gtk_dir="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0"
  mkdir -p "$gtk_dir"
  # matugen handles GTK template generation when configured;
  # this ensures the GTK config directory exists for it
}

# Apply colors to Qt (via env var for qt5ct/qt6ct)
apply_qt() {
  # Qt theming is handled via the platform theme (gtk) set in Home Manager
  # matugen templates can override qt5ct/qt6ct color schemes if configured
  :
}

# Signal Hyprland to reload config (picks up color changes)
apply_hyprland() {
  if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null || true
  fi
}

# Signal terminal to reload (Alacritty watches config file changes automatically)
apply_terminal() {
  # Alacritty auto-reloads when its config file changes
  # Other terminals may need explicit signaling
  :
}

# Apply theme changes to all targets
apply_all() {
  apply_gtk
  apply_qt
  apply_terminal
  apply_hyprland
}

apply_preset() {
  local preset_name="$1"

  case "$preset_name" in
    catppuccin-mocha|nord)
      echo "Applying preset: $preset_name"
      echo "preset:$preset_name" > "$STATE_FILE"
      apply_all
      ;;
    *)
      echo "Error: Unknown preset '$preset_name'" >&2
      echo "Available presets: $AVAILABLE_PRESETS" >&2
      exit 1
      ;;
  esac
}

apply_wallpaper() {
  local wallpaper_path="$1"

  if [[ ! -f "$wallpaper_path" ]]; then
    echo "Error: Wallpaper file not found: $wallpaper_path" >&2
    exit 1
  fi

  echo "Generating color scheme from wallpaper: $wallpaper_path"

  # Run matugen and handle failure gracefully (Req 18.7)
  # On failure: retain previous theme, report error to stderr
  if matugen image "$wallpaper_path" 2>"$MATUGEN_ERROR_LOG"; then
    echo "wallpaper:$wallpaper_path" > "$STATE_FILE"
    apply_all
    echo "Theme generated successfully from wallpaper."
  else
    echo "Error: matugen failed to generate color scheme from wallpaper." >&2
    echo "Retaining previous theme." >&2
    if [[ -s "$MATUGEN_ERROR_LOG" ]]; then
      cat "$MATUGEN_ERROR_LOG" >&2
    fi
    exit 1
  fi
}

# --- Argument Parsing ---

MODE=""
VALUE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wallpaper)
      if [[ $# -lt 2 ]]; then
        echo "Error: --wallpaper requires a path argument" >&2
        exit 1
      fi
      MODE="wallpaper"
      VALUE="$2"
      shift 2
      ;;
    --preset)
      if [[ $# -lt 2 ]]; then
        echo "Error: --preset requires a name argument" >&2
        exit 1
      fi
      MODE="preset"
      VALUE="$2"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Error: Unknown option: $1" >&2
      usage
      ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Error: Must specify --wallpaper or --preset" >&2
  usage
fi

# --- Execute ---

case "$MODE" in
  wallpaper)
    apply_wallpaper "$VALUE"
    ;;
  preset)
    apply_preset "$VALUE"
    ;;
esac
