# Run: nix eval --impure --file tests/hosts/gantry/_disko.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  cfg = import ../../../hosts/gantry/_disko.nix;
in
lib.runTests {
  # Real device — confirmed via lsblk on iron-tower (this exact desktop hardware).
  testDevice = { expr = cfg.disko.devices.disk.main.device; expected = "/dev/nvme0n1"; };
  testNotEncrypted = {
    expr = cfg.disko.devices.disk.main.content.partitions.root.content.type == "luks";
    expected = false;
  };
}
