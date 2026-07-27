{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.containers;
in {
  options.custom.system.containers = {
    enable = lib.mkEnableOption "container runtimes (Podman and Docker)";
  };

  config = lib.mkIf cfg.enable {
    # Podman with rootless container support
    virtualisation.podman = {
      enable = true;
      # Don't enable dockerCompat since we install Docker directly
      dockerCompat = false;
      # Enable default network for rootless containers
      defaultNetwork.settings.dns_enabled = true;
    };

    # Docker as alternative container runtime
    virtualisation.docker = {
      enable = true;
    };

    # User namespace configuration for rootless Podman
    users.users.ds = {
      subUidRanges = [
        { startUid = 100000; count = 65536; }
      ];
      subGidRanges = [
        { startGid = 100000; count = 65536; }
      ];
      extraGroups = [ "docker" ];
    };
  };
}
