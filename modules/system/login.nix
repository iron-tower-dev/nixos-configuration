{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.login;
in {
  options.custom.system.login = {
    enable = lib.mkEnableOption "Ly display manager with Hyprland session";
  };

  config = lib.mkIf cfg.enable {
    # Assertions: no other display manager should be enabled concurrently
    assertions = [
      {
        assertion = !config.services.xserver.displayManager.gdm.enable;
        message = "custom.system.login: GDM must be disabled when Ly is enabled";
      }
      {
        assertion = !config.services.xserver.displayManager.sddm.enable;
        message = "custom.system.login: SDDM must be disabled when Ly is enabled";
      }
      {
        assertion = !config.services.xserver.displayManager.lightdm.enable;
        message = "custom.system.login: LightDM must be disabled when Ly is enabled";
      }
    ];

    # Enable Ly as the display manager (nixos-unstable)
    services.displayManager.ly.enable = true;

    # Enable Hyprland so its session file is available to Ly
    programs.hyprland.enable = true;

    # Set Hyprland as the default session
    services.displayManager.defaultSession = "hyprland";
  };
}
