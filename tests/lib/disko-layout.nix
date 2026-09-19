# Run: nix eval --impure --file tests/lib/disko-layout.nix --apply "f: f {}"
#
# Unit-level only: asserts the shape of the attrset our function produces.
# Whether disko's own module actually accepts this shape is an
# integration-level concern (nix flake check / dry-activate), checked once
# disko is wired in as a flake input during host composition.
{ lib ? (import <nixpkgs> { }).lib }:
let
  mkDiskoLayout = import ../../lib/disko-layout.nix;

  plain = mkDiskoLayout { device = "/dev/nvme0n1"; };
  encrypted = mkDiskoLayout { device = "/dev/nvme0n1"; luks = true; };

  rootPart = cfg: cfg.disko.devices.disk.main.content.partitions.root;
  espPart = cfg: cfg.disko.devices.disk.main.content.partitions.ESP;
in
lib.runTests {
  testDeviceIsSetOnDisk = { expr = plain.disko.devices.disk.main.device; expected = "/dev/nvme0n1"; };
  testPartitionTableIsGpt = { expr = plain.disko.devices.disk.main.content.type; expected = "gpt"; };

  testEspFormatIsVfat = { expr = (espPart plain).content.format; expected = "vfat"; };
  testEspMountpointIsBoot = { expr = (espPart plain).content.mountpoint; expected = "/boot"; };

  testPlainRootIsBtrfsDirectly = { expr = (rootPart plain).content.type; expected = "btrfs"; };
  testPlainRootHasNixSubvolume = {
    expr = (rootPart plain).content.subvolumes."/nix".mountpoint;
    expected = "/nix";
  };
  testPlainRootHasPersistSubvolume = {
    expr = (rootPart plain).content.subvolumes."/persist".mountpoint;
    expected = "/persist";
  };
  testPlainRootUsesZstdCompression = {
    expr = builtins.elem "compress=zstd" (rootPart plain).content.subvolumes."/nix".mountOptions;
    expected = true;
  };

  testEncryptedRootIsWrappedInLuks = { expr = (rootPart encrypted).content.type; expected = "luks"; };
  testEncryptedRootStillHasBtrfsInside = {
    expr = (rootPart encrypted).content.content.type;
    expected = "btrfs";
  };
  testEncryptedRootStillHasPersistSubvolume = {
    expr = (rootPart encrypted).content.content.subvolumes."/persist".mountpoint;
    expected = "/persist";
  };
  testPlainRootIsNotLuks = { expr = (rootPart plain).content.type == "luks"; expected = false; };
}
