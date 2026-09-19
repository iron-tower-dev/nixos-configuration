{ lib, pkgs, inputs, ... }:
let
  common = import ../../lib/common.nix { inherit lib; };
  matugenDir = common.assertFileExists ../../config/matugen
    "Config source directory 'config/matugen/' not found. Required by modules/desktop/theming.nix.";

  # Preset color themes with the full 19-key color set matugen also produces,
  # so theme-switch can apply either a wallpaper-derived or a preset scheme.
  presets = {
    catppuccin-mocha = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#f5e0dc";
      color0 = "#45475a";
      color1 = "#f38ba8";
      color2 = "#a6e3a1";
      color3 = "#f9e2af";
      color4 = "#89b4fa";
      color5 = "#f5c2e7";
      color6 = "#94e2d5";
      color7 = "#bac2de";
      color8 = "#585b70";
      color9 = "#f38ba8";
      color10 = "#a6e3a1";
      color11 = "#f9e2af";
      color12 = "#89b4fa";
      color13 = "#f5c2e7";
      color14 = "#94e2d5";
      color15 = "#a6adc8";
    };
    nord = {
      background = "#2e3440";
      foreground = "#eceff4";
      cursor = "#d8dee9";
      color0 = "#3b4252";
      color1 = "#bf616a";
      color2 = "#a3be8c";
      color3 = "#ebcb8b";
      color4 = "#81a1c1";
      color5 = "#b48ead";
      color6 = "#88c0d0";
      color7 = "#e5e9f0";
      color8 = "#4c566a";
      color9 = "#bf616a";
      color10 = "#a3be8c";
      color11 = "#ebcb8b";
      color12 = "#81a1c1";
      color13 = "#b48ead";
      color14 = "#8fbcbb";
      color15 = "#eceff4";
    };
  };

  stateDir = "\${XDG_STATE_HOME:-$HOME/.local/state}/theming";
  stateFile = "${stateDir}/active-theme";

  theme-switch = pkgs.writeShellScriptBin "theme-switch" ''
    set -uo pipefail

    STATE_DIR="${stateDir}"
    STATE_FILE="${stateFile}"
    COLOR_DIR="$HOME/.cache/theme"
    COLOR_FILE="$COLOR_DIR/colors.json"
    COLOR_TMP="$COLOR_DIR/colors.json.tmp"

    mkdir -p "$STATE_DIR"
    mkdir -p "$COLOR_DIR"

    usage() {
      echo "Usage: theme-switch [--wallpaper <path>] [--preset <name>]" >&2
      echo "" >&2
      echo "Available presets: ${builtins.concatStringsSep ", " (builtins.attrNames presets)}" >&2
      exit 1
    }

    MODE=""
    VALUE=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --wallpaper)
          MODE="wallpaper"
          VALUE="''${2:-}"
          shift 2
          ;;
        --preset)
          MODE="preset"
          VALUE="''${2:-}"
          shift 2
          ;;
        --help|-h)
          usage
          ;;
        *)
          echo "Unknown option: $1" >&2
          usage
          ;;
      esac
    done

    if [[ -z "$MODE" ]]; then
      echo "Error: Must specify --wallpaper or --preset" >&2
      usage
    fi

    apply_preset() {
      local preset_name="$1"
      local json=""

      case "$preset_name" in
        catppuccin-mocha)
          json='${builtins.toJSON presets.catppuccin-mocha}'
          ;;
        nord)
          json='${builtins.toJSON presets.nord}'
          ;;
        *)
          echo "Error: Unknown preset '$preset_name'" >&2
          echo "Available presets: ${builtins.concatStringsSep ", " (builtins.attrNames presets)}" >&2
          exit 1
          ;;
      esac

      if printf '%s' "$json" > "$COLOR_TMP"; then
        mv "$COLOR_TMP" "$COLOR_FILE"
        echo "preset:$preset_name" > "$STATE_FILE"
        echo "Preset '$preset_name' applied successfully."
        gen-alacritty-colors || echo "Warning: Failed to update Alacritty colors" >&2
      else
        echo "Error: Failed to write preset colors." >&2
        rm -f "$COLOR_TMP"
        exit 1
      fi
    }

    apply_wallpaper() {
      local wallpaper_path="$1"

      if [[ ! -f "$wallpaper_path" ]]; then
        echo "Error: Wallpaper file not found: $wallpaper_path" >&2
        exit 1
      fi

      echo "Generating color scheme from wallpaper: $wallpaper_path"

      if matugen image "$wallpaper_path" --source-color-index 0 2>/tmp/matugen-error.log; then
        if [[ ! -f "$COLOR_TMP" ]]; then
          echo "Error: matugen did not produce output file." >&2
          exit 1
        fi
        mv "$COLOR_TMP" "$COLOR_FILE"
        echo "wallpaper:$wallpaper_path" > "$STATE_FILE"
        echo "Theme generated successfully from wallpaper."
        gen-alacritty-colors || echo "Warning: Failed to update Alacritty colors" >&2
      else
        echo "Error: matugen failed to generate color scheme." >&2
        cat /tmp/matugen-error.log >&2
        rm -f "$COLOR_TMP"
        exit 1
      fi
    }

    case "$MODE" in
      wallpaper)
        apply_wallpaper "$VALUE"
        ;;
      preset)
        apply_preset "$VALUE"
        ;;
    esac
  '';
in
{
  config = {
    # No nixpkgs package for matugen — comes from the pinned flake input.
    home.packages = [
      inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
      theme-switch
      pkgs.phinger-cursors
      pkgs.papirus-icon-theme
      pkgs.nerd-fonts.jetbrains-mono
    ];

    xdg.configFile."matugen".source = matugenDir;

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "phinger-cursors-dark";
        package = pkgs.phinger-cursors;
        size = 24;
      };
    };

    qt = {
      enable = true;
      # "gtk3" is the modern native Qt GTK3 plugin — "gtk" is deprecated,
      # "gtk2" would pull in the legacy qtstyleplugins path instead.
      platformTheme.name = "gtk3";
      style.name = "adwaita-dark";
    };

    home.pointerCursor = {
      name = "phinger-cursors-dark";
      package = pkgs.phinger-cursors;
      size = 24;
      gtk.enable = true;
    };

    home.activation.restoreTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      STATE_FILE="${stateDir}/active-theme"
      if [ -f "$STATE_FILE" ]; then
        $VERBOSE_ECHO "Restoring theme from $STATE_FILE"
      fi
    '';
  };
}
