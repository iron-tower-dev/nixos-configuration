#!/usr/bin/env bats
# Static verification checks for hypr-quickshell-theming consolidation
# Validates: Requirements 1.4, 6.1, 6.2, 7.1, 7.4, 3.3, 3.8, 3.9

REPO_ROOT="$BATS_TEST_DIRNAME/.."

# --- Requirement 1.4: hyprland.nix has no reference to config/hyprland ---
@test "hyprland.nix has no reference to config/hyprland" {
  run grep -n "config/hyprland" "$REPO_ROOT/modules/user/hyprland.nix"
  [ "$status" -ne 0 ]
}

# --- Requirement 6.2: hyprland.lua has exactly one quickshell exec_cmd ---
@test "hyprland.lua has exactly one quickshell exec_cmd" {
  # Match exec_cmd("quickshell") as a standalone command, not paths containing 'quickshell'
  count=$(grep -c 'exec_cmd("quickshell")' "$REPO_ROOT/config/hypr/hyprland.lua")
  [ "$count" -eq 1 ]
}

# --- Requirement 7.1, 7.4: hyprland.lua has no absolute paths in exec_cmd calls ---
@test "hyprland.lua has no absolute paths in exec_cmd calls" {
  # Check for exec_cmd containing absolute paths starting with / (not ~/), excluding comment lines
  # Absolute paths start with / followed by a word char (e.g., /nix/store/..., /home/ds/.cargo/bin/...)
  run bash -c "grep -n 'exec_cmd' \"$REPO_ROOT/config/hypr/hyprland.lua\" | grep -v '^[0-9]*:.*--' | grep -P '\"(/[a-zA-Z])'"
  [ "$status" -ne 0 ]
}

# --- Requirement 6.1: quickshell.nix has no quickshell-autostart.conf reference ---
@test "quickshell.nix has no quickshell-autostart.conf reference" {
  run grep -n "quickshell-autostart.conf" "$REPO_ROOT/modules/user/quickshell.nix"
  [ "$status" -ne 0 ]
}

# --- Requirement 3.3: shell.json points wallustColors to ~/.cache/theme/colors.json ---
@test "shell.json has wallustColors pointing to ~/.cache/theme/colors.json" {
  value=$(jq -r '.paths.wallustColors' "$REPO_ROOT/config/quickshell/shell.json")
  [ "$value" = "~/.cache/theme/colors.json" ]
}

# --- Requirement 3.8: WallpaperPicker.qml references theme-switch ---
@test "WallpaperPicker.qml references theme-switch" {
  run grep -n "theme-switch" "$REPO_ROOT/config/quickshell/modules/bar/components/WallpaperPicker.qml"
  [ "$status" -eq 0 ]
}

# --- Requirement 3.8: WallpaperPicker.qml does not reference wallust as a binary ---
@test "WallpaperPicker.qml does not reference wallust binary" {
  # Check for wallust as a command/process invocation (not as a service/color property name)
  run bash -c "grep -n 'wallust' \"$REPO_ROOT/config/quickshell/modules/bar/components/WallpaperPicker.qml\" | grep -iv 'Wallust\.' | grep -iv 'QsServices.Wallust' | grep -iv 'services.*Wallust'"
  [ "$status" -ne 0 ]
}

# --- Requirement 3.9: colors.json.wallust file is absent ---
@test "colors.json.wallust file does not exist" {
  run test -f "$REPO_ROOT/config/quickshell/colors.json.wallust"
  [ "$status" -ne 0 ]
}
