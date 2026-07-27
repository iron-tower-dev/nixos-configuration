{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.networking;
in {
  options.custom.system.networking = {
    enable = lib.mkEnableOption "NetworkManager networking";
  };

  config = lib.mkIf cfg.enable {
    # Enable NetworkManager as the primary network management service
    # D-Bus accessibility is provided automatically when NetworkManager is enabled,
    # allowing Quickshell widgets to query connection status
    networking.networkmanager = {
      enable = true;
      # Manage all Wi-Fi and wired interfaces
      unmanaged = [ ];
      wifi.powersave = true;
    };

    # Enable systemd-resolved for DNS resolution, integrated with NetworkManager
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    };

    # Disable dhcpcd to prevent conflicts with NetworkManager
    networking.useDHCP = false;

    # Disable systemd-networkd to prevent interface management conflicts
    networking.useNetworkd = false;
    systemd.services.systemd-networkd.enable = lib.mkForce false;
  };
}
