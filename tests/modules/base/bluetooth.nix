# Run: nix eval --impure --file tests/modules/base/bluetooth.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ ../../../modules/base/bluetooth.nix ];
  cfg = sys.config;
in
lib.runTests {
  testBluetoothEnabled = { expr = cfg.hardware.bluetooth.enable; expected = true; };
  testPowerOnBoot = { expr = cfg.hardware.bluetooth.powerOnBoot; expected = true; };
  testBluemanEnabled = { expr = cfg.services.blueman.enable; expected = true; };
}
