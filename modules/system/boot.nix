# modules/system/boot.nix
# Requirement 4: Boot and Filesystem
# Configures systemd-boot, EFI support, btrfs filesystem support,
# and recovery-capable boot via nofail on non-critical subvolumes.
{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.boot;
in {
  options.custom.system.boot = {
    enable = lib.mkEnableOption "systemd-boot and btrfs filesystem";
  };

  config = lib.mkIf cfg.enable {
    # Systemd-boot bootloader with EFI support (Req 4.1)
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Btrfs filesystem support (Req 4.2, 4.3)
    boot.supportedFilesystems = [ "btrfs" ];

    # Add nofail to non-critical subvolumes for recovery-capable boot (Req 4.5)
    # The actual mount declarations (device, fsType, subvol, compress) are in hardware.nix.
    # We only append "nofail" so the system can boot into a recovery state if these fail.
    fileSystems."/home".options = [ "nofail" ];
    fileSystems."/nix".options = [ "nofail" ];
    fileSystems."/.snapshots".options = [ "nofail" ];
  };
}
