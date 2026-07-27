{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.rofi;
  helpers = import ../../lib/helpers.nix { inherit lib; };
  configDir = helpers.assertFileExists ../../config/rofi
    "Config source directory 'config/rofi/' not found. Required by custom.user.rofi.";
in {
  options.custom.user.rofi = {
    enable = lib.mkEnableOption "Rofi application launcher";
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = config.custom.user.hyprland.enable;
      message = "custom.user.rofi requires custom.user.hyprland to be enabled.";
    }];

    home.packages = [ pkgs.rofi ];
    xdg.configFile."rofi".source = configDir;
  };
}
