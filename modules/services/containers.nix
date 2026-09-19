{ config, ... }:
let
  userName = config.custom.base.users.name;
in
{
  config = {
    virtualisation.podman = {
      enable = true;
      # Docker is installed directly, so no need for Podman's Docker-compat shim.
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.docker.enable = true;

    users.users.${userName} = {
      subUidRanges = [{ startUid = 100000; count = 65536; }];
      subGidRanges = [{ startGid = 100000; count = 65536; }];
      extraGroups = [ "docker" ];
    };
  };
}
