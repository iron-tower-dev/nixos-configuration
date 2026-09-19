{ lib, pkgs, inputs, ... }:
let
  common = import ../../lib/common.nix { inherit lib; };
  matugenDir = common.assertFileExists ../../config/matugen
    "Config source directory 'config/matugen/' not found. Required by modules/desktop/theming.nix.";

  theme-switch = import ../../pkgs/scripts/theme-switch.nix { inherit pkgs; };

  # Only used by the restoreTheme activation hook below — the actual state
  # path logic lives with theme-switch itself in pkgs/scripts/theme-switch.nix.
  stateDir = "\${XDG_STATE_HOME:-$HOME/.local/state}/theming";
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
