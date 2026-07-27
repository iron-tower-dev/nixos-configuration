#!/usr/bin/env bats
# Feature: hypr-quickshell-theming, Property 1: Color_JSON schema invariant
#
# For any valid color generation (whether from a wallpaper image via matugen or
# from a preset definition), the resulting ~/.cache/theme/colors.json file SHALL
# be valid JSON containing exactly 19 keys (background, foreground, cursor,
# color0–color15), where every value is a 7-character string matching the
# pattern #[0-9a-fA-F]{6}.
#
# **Validates: Requirements 3.2, 8.1**

# --- Setup / Teardown ---

setup() {
  export COLOR_DIR="${BATS_TMPDIR}/theme-test-$$"
  export HOME="${BATS_TMPDIR}/home-$$"
  mkdir -p "$COLOR_DIR"
  mkdir -p "$HOME/.cache/theme"
  # Remove any previous colors.json so tests start clean
  rm -f "$HOME/.cache/theme/colors.json"
  # Point theme-switch to our test cache directory
  export XDG_CACHE_HOME="${HOME}/.cache"

  # Ensure theme-switch is on PATH
  if ! command -v theme-switch &>/dev/null; then
    skip "theme-switch not on PATH (install via home-manager or set THEME_SWITCH_PATH)"
  fi
}

teardown() {
  rm -rf "$COLOR_DIR"
  rm -rf "$HOME"
}

# --- Helper Functions ---

# validate_color_json: verifies that the given file is valid Color_JSON
# Usage: validate_color_json <path-to-colors.json>
validate_color_json() {
  local file="$1"

  # Verify the file exists
  [ -f "$file" ] || {
    echo "ERROR: colors.json does not exist at $file" >&2
    return 1
  }

  # Verify it is valid JSON
  jq empty "$file" 2>/dev/null || {
    echo "ERROR: $file is not valid JSON" >&2
    return 1
  }

  # Verify exactly 19 keys
  local key_count
  key_count=$(jq 'keys | length' "$file")
  [ "$key_count" -eq 19 ] || {
    echo "ERROR: Expected 19 keys, got $key_count" >&2
    return 1
  }

  # Verify all expected keys are present
  local expected_keys="background foreground cursor color0 color1 color2 color3 color4 color5 color6 color7 color8 color9 color10 color11 color12 color13 color14 color15"
  for key in $expected_keys; do
    jq -e --arg k "$key" 'has($k)' "$file" >/dev/null 2>&1 || {
      echo "ERROR: Missing expected key '$key'" >&2
      return 1
    }
  done

  # Verify all values match the hex color pattern #[0-9a-fA-F]{6}
  local invalid_values
  invalid_values=$(jq -r 'to_entries[] | select(.value | test("^#[0-9a-fA-F]{6}$") | not) | "\(.key)=\(.value)"' "$file")
  [ -z "$invalid_values" ] || {
    echo "ERROR: Invalid hex color values found:" >&2
    echo "$invalid_values" >&2
    return 1
  }

  return 0
}

# --- Preset Tests ---

@test "preset catppuccin-mocha produces valid Color_JSON schema" {
  # Run theme-switch with catppuccin-mocha preset
  run theme-switch --preset catppuccin-mocha
  [ "$status" -eq 0 ]

  # Validate the output
  validate_color_json "$HOME/.cache/theme/colors.json"
}

@test "preset nord produces valid Color_JSON schema" {
  # Run theme-switch with nord preset
  run theme-switch --preset nord
  [ "$status" -eq 0 ]

  # Validate the output
  validate_color_json "$HOME/.cache/theme/colors.json"
}

# --- Wallpaper Property Test (100 iterations) ---

# Helper: generate a random hex color for ImageMagick
random_hex_color() {
  printf '#%06x' $((RANDOM * RANDOM % 16777216))
}

# Helper: generate a random dimension (16–2048)
random_dimension() {
  echo $(( (RANDOM % 2033) + 16 ))
}

@test "wallpaper generation: 100 random solid-color PNGs produce valid Color_JSON schema" {
  # Skip if ImageMagick (convert) is not available
  if ! command -v convert &>/dev/null; then
    skip "ImageMagick (convert) not available - skipping wallpaper generation tests"
  fi

  # Skip if matugen is not available
  if ! command -v matugen &>/dev/null; then
    skip "matugen not available in test environment - skipping wallpaper generation tests"
  fi

  local iterations=100
  local wallpaper_dir="${BATS_TMPDIR}/wallpapers-$$"
  mkdir -p "$wallpaper_dir"

  for i in $(seq 1 $iterations); do
    local color
    color=$(random_hex_color)
    local width
    width=$(random_dimension)
    local height
    height=$(random_dimension)
    local wallpaper_path="${wallpaper_dir}/test-wallpaper-${i}.png"

    # Generate a solid-color PNG of random dimensions
    convert -size "${width}x${height}" "xc:${color}" "$wallpaper_path"

    # Remove previous colors.json to ensure fresh output
    rm -f "$HOME/.cache/theme/colors.json"

    # Run theme-switch with the generated wallpaper
    run theme-switch --wallpaper "$wallpaper_path"
    if [ "$status" -ne 0 ]; then
      echo "FAIL at iteration $i: theme-switch exited with status $status" >&2
      echo "  wallpaper: ${width}x${height} color=${color}" >&2
      echo "  output: $output" >&2
      false
    fi

    # Validate the resulting colors.json
    if ! validate_color_json "$HOME/.cache/theme/colors.json"; then
      echo "FAIL at iteration $i: Color_JSON validation failed" >&2
      echo "  wallpaper: ${width}x${height} color=${color}" >&2
      false
    fi

    # Clean up wallpaper to save space
    rm -f "$wallpaper_path"
  done

  rm -rf "$wallpaper_dir"
}
