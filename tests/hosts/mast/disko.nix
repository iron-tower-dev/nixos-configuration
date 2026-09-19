# Run: nix eval --impure --file tests/hosts/mast/_disko.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  cfg = import ../../../hosts/mast/_disko.nix;
in
lib.runTests {
  # PLACEHOLDER — single-NVMe assumption, not yet confirmed via lsblk on the
  # physical laptop. Verify before actually running disko against real hardware.
  testDevice = { expr = cfg.disko.devices.disk.main.device; expected = "/dev/nvme0n1"; };
  testEncrypted = {
    expr = cfg.disko.devices.disk.main.content.partitions.root.content.type;
    expected = "luks";
  };
}
