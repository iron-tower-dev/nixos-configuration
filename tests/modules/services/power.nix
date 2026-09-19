# Run: nix eval --impure --file tests/modules/services/power.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  mkSys = tlp: harness.evalHost [
    ../../../modules/host
    (harness.nixosModuleFrom ../../../modules/services/power.nix "power")
    { custom.host.power.tlp = tlp; }
  ];
in
lib.runTests {
  testTlpEnabledWhenRequested = { expr = (mkSys true).config.services.tlp.enable; expected = true; };
  testTlpDisabledByDefault = { expr = (mkSys false).config.services.tlp.enable; expected = false; };
}
