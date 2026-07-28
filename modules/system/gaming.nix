{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.gaming;
in {
  options.custom.system.gaming = {
    enable = lib.mkEnableOption "gaming tools and performance optimizations";
  };

  config = lib.mkIf cfg.enable {
    # Steam with Proton support and 32-bit libraries
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # Gamemode for automatic performance optimizations during gaming
    programs.gamemode.enable = true;

    # Gaming packages
    environment.systemPackages = with pkgs; [
      # Non-Steam game launchers
      lutris
      heroic

      # ProtonGE: install via ProtonUp-Qt or place in ~/.steam/root/compatibilitytools.d/
      protonup-qt
    ];

    # Kernel tuning for gaming performance
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };

    # File descriptor limit (nofile) of at least 524288
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "524288";
      }
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "524288";
      }
    ];

    # ACO shader compilation — RADV uses ACO by default, set RADV as the Vulkan ICD (AMD only)
    environment.sessionVariables = lib.mkIf (config.custom.system.gpu.driver == "amd") {
      AMD_VULKAN_ICD = "RADV";
    };
  };
}
