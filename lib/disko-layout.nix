# Shared disko partition layout for both hosts. `/` itself is deliberately
# NOT declared here — it's tmpfs, handled by modules/services/impermanence.nix
# — only durable storage (boot, nix store, persisted state) is partitioned.
{ device, luks ? false }:
let
  btrfsRoot = {
    type = "btrfs";
    extraArgs = [ "-f" ];
    subvolumes = {
      "/nix" = {
        mountpoint = "/nix";
        mountOptions = [ "compress=zstd" "noatime" ];
      };
      "/persist" = {
        mountpoint = "/persist";
        mountOptions = [ "compress=zstd" "noatime" ];
      };
    };
  };

  rootContent =
    if luks then {
      type = "luks";
      name = "crypted";
      settings.allowDiscards = true;
      content = btrfsRoot;
    } else
      btrfsRoot;
in
{
  disko.devices.disk.main = {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = rootContent;
        };
      };
    };
  };
}
