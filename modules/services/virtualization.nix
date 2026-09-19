{ config, ... }:
let
  userName = config.custom.base.users.name;
in
{
  config = {
    # OVMF (UEFI guest firmware) ships with QEMU by default in this nixpkgs —
    # no separate enable option exists anymore.
    virtualisation.libvirtd.enable = true;

    programs.virt-manager.enable = true;

    users.users.${userName}.extraGroups = [ "libvirtd" ];
  };
}
