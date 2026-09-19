# Run: nix eval --impure --file tests/modules/base/boot.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ ../../../modules/base/boot.nix ];
  cfg = sys.config;
in
lib.runTests {
  testSystemdBootEnabled = { expr = cfg.boot.loader.systemd-boot.enable; expected = true; };
  testEfiVariablesTouchable = { expr = cfg.boot.loader.efi.canTouchEfiVariables; expected = true; };
}
