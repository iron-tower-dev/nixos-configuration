{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.nix-settings;
in {
  options.custom.system.nix-settings = {
    enable = lib.mkEnableOption "Nix daemon settings, garbage collection, and SSD maintenance";
  };

  config = lib.mkIf cfg.enable {
    # Allow unfree packages (e.g., discord, steam)
    nixpkgs.config.allowUnfree = true;

    # Enable flakes and nix-command experimental features
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Configure weekly automatic garbage collection removing paths older than 7 days
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Enable weekly fstrim timer for SSD maintenance
    services.fstrim.enable = true;
  };
}
