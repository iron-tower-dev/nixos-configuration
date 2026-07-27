{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.terminal;
  configDir = ../../../config/alacritty;

  gen-alacritty-colors = pkgs.writeShellScriptBin "gen-alacritty-colors" ''
    set -euo pipefail

    COLORS_JSON="$HOME/.cache/theme/colors.json"
    OUTPUT_DIR="$HOME/.cache/theme"
    OUTPUT_FILE="$OUTPUT_DIR/alacritty-colors.toml"
    TMP_FILE="$OUTPUT_DIR/alacritty-colors.toml.tmp"

    # Check if colors.json exists
    if [ ! -f "$COLORS_JSON" ]; then
      echo "Error: colors.json not found at ~/.cache/theme/colors.json" >&2
      exit 1
    fi

    # Validate JSON
    if ! ${pkgs.jq}/bin/jq empty "$COLORS_JSON" 2>/dev/null; then
      echo "Error: failed to parse colors.json" >&2
      exit 1
    fi

    # Validate all 19 required keys are present
    REQUIRED_KEYS="background foreground cursor color0 color1 color2 color3 color4 color5 color6 color7 color8 color9 color10 color11 color12 color13 color14 color15"
    for key in $REQUIRED_KEYS; do
      if ! ${pkgs.jq}/bin/jq -e --arg k "$key" 'has($k)' "$COLORS_JSON" >/dev/null 2>&1; then
        echo "Error: colors.json missing required keys" >&2
        exit 1
      fi
    done

    # Extract color values
    background=$(${pkgs.jq}/bin/jq -r '.background' "$COLORS_JSON")
    foreground=$(${pkgs.jq}/bin/jq -r '.foreground' "$COLORS_JSON")
    cursor=$(${pkgs.jq}/bin/jq -r '.cursor' "$COLORS_JSON")
    color0=$(${pkgs.jq}/bin/jq -r '.color0' "$COLORS_JSON")
    color1=$(${pkgs.jq}/bin/jq -r '.color1' "$COLORS_JSON")
    color2=$(${pkgs.jq}/bin/jq -r '.color2' "$COLORS_JSON")
    color3=$(${pkgs.jq}/bin/jq -r '.color3' "$COLORS_JSON")
    color4=$(${pkgs.jq}/bin/jq -r '.color4' "$COLORS_JSON")
    color5=$(${pkgs.jq}/bin/jq -r '.color5' "$COLORS_JSON")
    color6=$(${pkgs.jq}/bin/jq -r '.color6' "$COLORS_JSON")
    color7=$(${pkgs.jq}/bin/jq -r '.color7' "$COLORS_JSON")
    color8=$(${pkgs.jq}/bin/jq -r '.color8' "$COLORS_JSON")
    color9=$(${pkgs.jq}/bin/jq -r '.color9' "$COLORS_JSON")
    color10=$(${pkgs.jq}/bin/jq -r '.color10' "$COLORS_JSON")
    color11=$(${pkgs.jq}/bin/jq -r '.color11' "$COLORS_JSON")
    color12=$(${pkgs.jq}/bin/jq -r '.color12' "$COLORS_JSON")
    color13=$(${pkgs.jq}/bin/jq -r '.color13' "$COLORS_JSON")
    color14=$(${pkgs.jq}/bin/jq -r '.color14' "$COLORS_JSON")
    color15=$(${pkgs.jq}/bin/jq -r '.color15' "$COLORS_JSON")

    # Build TOML output
    TOML_CONTENT="[colors.primary]
background = \"$background\"
foreground = \"$foreground\"

[colors.cursor]
cursor = \"$cursor\"
text = \"$background\"

[colors.normal]
black = \"$color0\"
red = \"$color1\"
green = \"$color2\"
yellow = \"$color3\"
blue = \"$color4\"
magenta = \"$color5\"
cyan = \"$color6\"
white = \"$color7\"

[colors.bright]
black = \"$color8\"
red = \"$color9\"
green = \"$color10\"
yellow = \"$color11\"
blue = \"$color12\"
magenta = \"$color13\"
cyan = \"$color14\"
white = \"$color15\""

    # Ensure output directory exists
    mkdir -p "$OUTPUT_DIR"

    # Write to temporary file
    if ! printf '%s\n' "$TOML_CONTENT" > "$TMP_FILE"; then
      echo "Error: cannot write to ~/.cache/theme/" >&2
      exit 1
    fi

    # Atomically rename to final location
    if ! mv "$TMP_FILE" "$OUTPUT_FILE"; then
      echo "Error: failed to write alacritty-colors.toml" >&2
      exit 1
    fi
  '';
in {
  options.custom.user.terminal = {
    enable = lib.mkEnableOption "Alacritty terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    # Install Alacritty (config is managed via static alacritty.toml)
    programs.alacritty = {
      enable = true;
    };

    # Make gen-alacritty-colors and jq available on PATH
    home.packages = [
      gen-alacritty-colors
      pkgs.jq
    ];

    # Symlink only the static config file (colors are generated at runtime into ~/.cache/theme/)
    xdg.configFile."alacritty/alacritty.toml".source = "${configDir}/alacritty.toml";

    # Generate initial alacritty-colors.toml with catppuccin-mocha defaults if it doesn't exist
    home.activation.generateAlacrittyColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.cache/theme/alacritty-colors.toml" ]; then
        mkdir -p "$HOME/.cache/theme"
        cat > "$HOME/.cache/theme/alacritty-colors.toml" << 'EOF'
[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"

[colors.cursor]
cursor = "#f5e0dc"
text = "#1e1e2e"

[colors.normal]
black = "#45475a"
red = "#f38ba8"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#f5c2e7"
cyan = "#94e2d5"
white = "#bac2de"

[colors.bright]
black = "#585b70"
red = "#f38ba8"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#f5c2e7"
cyan = "#94e2d5"
white = "#a6adc8"
EOF
      fi
    '';
  };
}
