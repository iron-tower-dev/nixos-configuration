{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.virtualization;
in {
  options.custom.system.virtualization = {
    enable = lib.mkEnableOption "libvirtd virtualization with QEMU/KVM";
  };

  config = lib.mkIf cfg.enable {
    # Enable libvirtd with QEMU/KVM support (Req 22.1)
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        # OVMF images are now available by default with QEMU (Req 22.5)
        swtpm.enable = true;
      };
    };

    # Enable virt-manager GUI for VM management (Req 22.2)
    programs.virt-manager.enable = true;

    # Add user to libvirtd group for access (Req 22.3)
    users.users.ds.extraGroups = lib.mkAfter [ "libvirtd" ];

    # Default NAT network auto-starts when libvirtd is enabled (Req 22.4)
    # The NixOS libvirtd module automatically configures the default
    # virbr0 NAT network when virtualisation.libvirtd.enable = true
  };
}
