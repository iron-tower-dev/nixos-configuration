{ ... }:
let
  moduleBody = { config, lib, ... }:
    let
      userName = config.custom.base.users.name;
    in
    {
      config = lib.mkIf config.custom.host.isDev {
        # OVMF (UEFI guest firmware) ships with QEMU by default in this nixpkgs —
        # no separate enable option exists anymore.
        virtualisation.libvirtd.enable = true;

        programs.virt-manager.enable = true;

        users.users.${userName}.extraGroups = [ "libvirtd" ];
      };
    };
in
{
  flake.nixosModules.virtualization = moduleBody;
}
