{ ... }:
let
  moduleBody = { ... }: {
    config = {
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      services.blueman.enable = true;
    };
  };
in
{
  flake.nixosModules.bluetooth = moduleBody;
}
