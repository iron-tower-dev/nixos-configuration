# Run: nix eval --impure --file tests/modules/services/containers.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [
    ../../../modules/base/users.nix
    ../../../modules/services/containers.nix
  ];
  cfg = sys.config;
in
lib.runTests {
  testPodmanEnabled = { expr = cfg.virtualisation.podman.enable; expected = true; };
  testPodmanDnsEnabled = { expr = cfg.virtualisation.podman.defaultNetwork.settings.dns_enabled; expected = true; };
  testDockerEnabled = { expr = cfg.virtualisation.docker.enable; expected = true; };
  testUserInDockerGroup = { expr = builtins.elem "docker" cfg.users.users.ds.extraGroups; expected = true; };
  testUserHasSubUidRange = {
    expr = cfg.users.users.ds.subUidRanges;
    expected = [{ startUid = 100000; count = 65536; }];
  };
  testUserHasSubGidRange = {
    expr = cfg.users.users.ds.subGidRanges;
    expected = [{ startGid = 100000; count = 65536; }];
  };
}
