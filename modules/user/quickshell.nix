{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.custom.user.quickshell;
  helpers = import ../../lib/helpers.nix { inherit lib; };
  configDir = helpers.assertFileExists ../../config/quickshell
    "Config source directory 'config/quickshell/' not found. Required by custom.user.quickshell.";
in {
  options.custom.user.quickshell = {
    enable = lib.mkEnableOption "Quickshell widgets";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.custom.user.hyprland.enable;
        message = "custom.user.quickshell requires custom.user.hyprland to be enabled";
      }
    ];

    home.packages = [ inputs.quickshell.packages.${pkgs.system}.default ];

    xdg.configFile."quickshell".source = configDir;
  };
}
