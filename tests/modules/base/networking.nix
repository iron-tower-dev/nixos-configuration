# Run: nix eval --impure --file tests/modules/base/networking.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ (harness.nixosModuleFrom ../../../modules/base/networking.nix "networking") ];
  cfg = sys.config;
in
lib.runTests {
  testNetworkManagerEnabled = {
    expr = cfg.networking.networkmanager.enable;
    expected = true;
  };
  testDhcpcdDisabled = {
    expr = cfg.networking.dhcpcd.enable;
    expected = false;
  };
  testNetworkdDisabled = {
    expr = cfg.networking.useNetworkd;
    expected = false;
  };
  testResolvedEnabled = {
    expr = cfg.services.resolved.enable;
    expected = true;
  };
}
