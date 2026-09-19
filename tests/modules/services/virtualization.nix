# Run: nix eval --impure --file tests/modules/services/virtualization.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [
    ../../../modules/base/users.nix
    ../../../modules/services/virtualization.nix
  ];
  cfg = sys.config;
in
lib.runTests {
  testLibvirtdEnabled = { expr = cfg.virtualisation.libvirtd.enable; expected = true; };
  testVirtManagerEnabled = { expr = cfg.programs.virt-manager.enable; expected = true; };
  testUserInLibvirtdGroup = {
    expr = builtins.elem "libvirtd" cfg.users.users.ds.extraGroups;
    expected = true;
  };
}
