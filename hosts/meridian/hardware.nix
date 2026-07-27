# Hardware configuration for meridian
# This file should be replaced with output from nixos-generate-config --show-hardware-config
# Replace UUIDs and kernel modules with values from your actual hardware.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Kernel modules — replace with output from hardware scan
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Btrfs root partition with subvolumes
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=@root" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "compress=zstd" "noatime" ];
  };

  # EFI system partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-EFI-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  # CPU and platform — adjust for your hardware
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
