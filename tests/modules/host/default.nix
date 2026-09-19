# Run: nix eval --impure --file tests/modules/host/default.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [
    (harness.nixosModuleFrom ../../../modules/host "host")
    { custom.host = { isGaming = true; isDev = true; isServer = false; }; }
  ];
  cfg = sys.config;
in
lib.runTests {
  testHostRoleIsReadable = { expr = cfg.custom.host.isGaming; expected = true; };
  testDefaultIsEmptyAttrs = {
    expr = (harness.evalHost [ (harness.nixosModuleFrom ../../../modules/host "host") ]).config.custom.host;
    expected = { };
  };
}
