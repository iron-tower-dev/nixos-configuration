{ lib ? (import <nixpkgs> { }).lib, ... }:
let
  common = import ../../lib/common.nix { inherit lib; };
  configDir = common.assertFileExists ../../config/hypr
    "Config source directory 'config/hypr/' not found. Required by modules/desktop/hyprland-home.nix.";

  moduleBody = { pkgs, ... }: {
    config = {
      wayland.windowManager.hyprland = {
        enable = true;
        # Use nixpkgs' cached binary rather than building the flake input from
        # source — matches modules/desktop/hyprland.nix's system-level choice.
      };

      home.packages = [
        pkgs.awww # renamed from swww
        pkgs.playerctl
        pkgs.brightnessctl
        pkgs.hypridle
        pkgs.hyprpolkitagent
      ];

      xdg.configFile."hypr/hyprland.lua".source = configDir + "/hyprland.lua";
      xdg.configFile."hypr/hypridle.conf".source = configDir + "/hypridle.conf";
      # Wallpapers live at ~/.config/wallpapers/, user-managed directly —
      # not symlinked from the Nix store.
    };
  };
in
{
  flake.homeModules."hyprland-home" = moduleBody;
}
