# Run: nix eval --impure --file tests/hosts/mast/_disko.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  cfg = import ../../../hosts/mast/_disko.nix;
in
lib.runTests {
  # Confirmed via lsblk on the physical laptop during install.
  testDevice = { expr = cfg.disko.devices.disk.main.device; expected = "/dev/nvme0n1"; };
  testEncrypted = {
    expr = cfg.disko.devices.disk.main.content.partitions.root.content.type;
    expected = "luks";
  };
}
