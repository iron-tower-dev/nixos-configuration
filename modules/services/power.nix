{ ... }:
let
  moduleBody = { config, lib, ... }: {
    config = lib.mkIf (config.custom.host.power.tlp or false) {
      services.tlp.enable = true;
    };
  };
in
{
  flake.nixosModules.power = moduleBody;
}
