{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.custom.user.hyprland;
  helpers = import ../../lib/helpers.nix { inherit lib; };
  configDir = helpers.assertFileExists ../../config/hypr
    "Config source directory 'config/hypr/' not found. Required by custom.user.hyprland.";
  wallpapersDir = helpers.assertFileExists ../../config/wallpapers
    "Config source directory 'config/wallpapers/' not found. Required by custom.user.hyprland.";
in {
  options.custom.user.hyprland = {
    enable = lib.mkEnableOption "Hyprland compositor";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      # Use nixpkgs package (cached binary) instead of flake (source build)
      # package = inputs.hyprland.packages.x86_64-linux.hyprland;
    };

    home.packages = [
      pkgs.swww
      pkgs.playerctl
      pkgs.brightnessctl
      pkgs.hypridle
      # Requires the hyprland flake input
      pkgs.hyprpolkitagent
    ];

    xdg.configFile."hypr".source = configDir;
    xdg.configFile."wallpapers".source = wallpapersDir;
  };
}
