{ ... }:
let
  moduleBody = { ... }: {
    config = {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };
  };
in
{
  flake.nixosModules.boot = moduleBody;
}
