#!/usr/bin/env bats
# Feature: hypr-quickshell-theming, Property 2: Error conditions preserve existing theme state
#
# For any invocation of theme-switch that results in an error (non-existent wallpaper path,
# unsupported image format, unknown preset name, or matugen execution failure), the script
# SHALL exit with a non-zero status code AND the content of ~/.cache/theme/colors.json SHALL
# be byte-for-byte identical to its content before the invocation.
#
# Validates: Requirements 3.6, 3.7, 8.4
#
# Property test approach:
# - Create a known-good colors.json, record its checksum
# - Generate random invalid inputs: non-existent paths, directories, non-image files,
#   random strings as preset names
# - Run theme-switch with each, verify non-zero exit AND checksum unchanged

ITERATIONS=100

# --- Setup / Teardown ---

setup() {
  # Ensure theme-switch is on PATH
  if ! command -v theme-switch &>/dev/null; then
    skip "theme-switch not found on PATH"
  fi

  # Create cache directory
  export COLOR_DIR="$BATS_TEST_TMPDIR/cache/theme"
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$COLOR_DIR"
  mkdir -p "$HOME/.cache/theme"

  # Write a known-good colors.json
  KNOWN_GOOD_JSON='{"background":"#1e1e2e","foreground":"#cdd6f4","cursor":"#f5e0dc","color0":"#45475a","color1":"#f38ba8","color2":"#a6e3a1","color3":"#f9e2af","color4":"#89b4fa","color5":"#f5c2e7","color6":"#94e2d5","color7":"#bac2de","color8":"#585b70","color9":"#f38ba8","color10":"#a6e3a1","color11":"#f9e2af","color12":"#89b4fa","color13":"#f5c2e7","color14":"#94e2d5","color15":"#a6adc8"}'
  echo "$KNOWN_GOOD_JSON" > "$HOME/.cache/theme/colors.json"

  # Record checksum of the known-good file
  ORIGINAL_CHECKSUM=$(sha256sum "$HOME/.cache/theme/colors.json" | awk '{print $1}')
  export ORIGINAL_CHECKSUM
}

# --- Helper Functions ---

# Verify that colors.json is byte-for-byte identical to the original
assert_colors_unchanged() {
  local current_checksum
  current_checksum=$(sha256sum "$HOME/.cache/theme/colors.json" | awk '{print $1}')
  [ "$current_checksum" = "$ORIGINAL_CHECKSUM" ]
}

# Generate a random string of given length using alphanumeric characters
random_string() {
  local length="${1:-16}"
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c "$length"
}

# Generate a random path that does not exist
random_nonexistent_path() {
  local base="/tmp/nonexistent_wallpapers_$$"
  local name
  name=$(random_string 12)
  local ext_choices=("png" "jpg" "jpeg" "webp" "bmp" "gif")
  local ext="${ext_choices[$((RANDOM % ${#ext_choices[@]}))]}"
  echo "${base}/${name}.${ext}"
}

# Generate a random preset name that is NOT one of the valid presets
random_invalid_preset() {
  local valid_presets=("catppuccin-mocha" "nord")
  local candidate
  while true; do
    candidate=$(random_string $((RANDOM % 20 + 3)))
    local is_valid=false
    for p in "${valid_presets[@]}"; do
      if [ "$candidate" = "$p" ]; then
        is_valid=true
        break
      fi
    done
    if [ "$is_valid" = "false" ]; then
      echo "$candidate"
      return
    fi
  done
}

# --- Property Tests ---

@test "Property 2: non-existent wallpaper paths produce non-zero exit and unchanged colors.json (100 iterations)" {
  local i
  for i in $(seq 1 $ITERATIONS); do
    local path
    path=$(random_nonexistent_path)

    # Run theme-switch with a non-existent path
    run theme-switch --wallpaper "$path"

    # Verify non-zero exit code
    [ "$status" -ne 0 ] || {
      echo "FAIL at iteration $i: expected non-zero exit for path '$path', got exit code $status"
      return 1
    }

    # Verify colors.json unchanged
    assert_colors_unchanged || {
      echo "FAIL at iteration $i: colors.json was modified for non-existent path '$path'"
      return 1
    }
  done
}

@test "Property 2: unknown preset names produce non-zero exit and unchanged colors.json (100 iterations)" {
  local i
  for i in $(seq 1 $ITERATIONS); do
    local preset
    preset=$(random_invalid_preset)

    # Run theme-switch with an invalid preset name
    run theme-switch --preset "$preset"

    # Verify non-zero exit code
    [ "$status" -ne 0 ] || {
      echo "FAIL at iteration $i: expected non-zero exit for preset '$preset', got exit code $status"
      return 1
    }

    # Verify colors.json unchanged
    assert_colors_unchanged || {
      echo "FAIL at iteration $i: colors.json was modified for unknown preset '$preset'"
      return 1
    }
  done
}

@test "Property 2: non-image files produce non-zero exit and unchanged colors.json" {
  # Create temporary non-image files with various extensions
  local extensions=("txt" "pdf" "doc" "csv" "xml" "html" "log" "conf" "ini" "yaml")
  local tmpdir="$BATS_TEST_TMPDIR/non_images"
  mkdir -p "$tmpdir"

  local i
  for i in $(seq 1 $ITERATIONS); do
    local ext="${extensions[$((RANDOM % ${#extensions[@]}))]}"
    local filename
    filename="$(random_string 8).${ext}"
    local filepath="${tmpdir}/${filename}"

    # Create the file with random content (not a valid image)
    head -c $((RANDOM % 1024 + 64)) /dev/urandom > "$filepath"

    # Run theme-switch with a non-image file
    run theme-switch --wallpaper "$filepath"

    # Verify non-zero exit code
    # Note: The script checks file existence first. Since the file exists but is not an image,
    # matugen should fail. If matugen is not available, this test may behave differently.
    # We accept non-zero exit (matugen failure) OR skip if matugen is not installed.
    if ! command -v matugen &>/dev/null; then
      # Without matugen, the script will fail when trying to run matugen (command not found)
      # which still results in non-zero exit and preserved colors.json
      [ "$status" -ne 0 ] || {
        echo "FAIL at iteration $i: expected non-zero exit for non-image file '$filepath' (matugen not available), got exit code $status"
        return 1
      }
    else
      [ "$status" -ne 0 ] || {
        echo "FAIL at iteration $i: expected non-zero exit for non-image file '$filepath', got exit code $status"
        return 1
      }
    fi

    # Verify colors.json unchanged
    assert_colors_unchanged || {
      echo "FAIL at iteration $i: colors.json was modified for non-image file '$filepath'"
      return 1
    }
  done
}

@test "Property 2: directories passed as wallpaper path produce non-zero exit and unchanged colors.json" {
  local tmpdir="$BATS_TEST_TMPDIR/dir_inputs"
  mkdir -p "$tmpdir"

  local i
  for i in $(seq 1 $ITERATIONS); do
    local dirname
    dirname="$(random_string 8)"
    local dirpath="${tmpdir}/${dirname}"
    mkdir -p "$dirpath"

    # Run theme-switch with a directory instead of a file
    run theme-switch --wallpaper "$dirpath"

    # Verify non-zero exit code (the script checks -f, so a directory should fail)
    [ "$status" -ne 0 ] || {
      echo "FAIL at iteration $i: expected non-zero exit for directory '$dirpath', got exit code $status"
      return 1
    }

    # Verify colors.json unchanged
    assert_colors_unchanged || {
      echo "FAIL at iteration $i: colors.json was modified for directory path '$dirpath'"
      return 1
    }
  done
}
