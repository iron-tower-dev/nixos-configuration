# Run: nix eval --impure --file tests/modules/services/containers.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  mkSys = isDev: harness.evalHost [
    ../../../modules/host
    ../../../modules/base/users.nix
    ../../../modules/services/containers.nix
    { custom.host.isDev = isDev; }
  ];
  dev = (mkSys true).config;
  notDev = (mkSys false).config;
in
lib.runTests {
  testPodmanEnabled = { expr = dev.virtualisation.podman.enable; expected = true; };
  testPodmanDnsEnabled = { expr = dev.virtualisation.podman.defaultNetwork.settings.dns_enabled; expected = true; };
  testDockerEnabled = { expr = dev.virtualisation.docker.enable; expected = true; };
  testUserInDockerGroup = { expr = builtins.elem "docker" dev.users.users.ds.extraGroups; expected = true; };
  testUserHasSubUidRange = {
    expr = dev.users.users.ds.subUidRanges;
    expected = [{ startUid = 100000; count = 65536; }];
  };
  testUserHasSubGidRange = {
    expr = dev.users.users.ds.subGidRanges;
    expected = [{ startGid = 100000; count = 65536; }];
  };

  testDockerDisabledWhenNotDev = { expr = notDev.virtualisation.docker.enable; expected = false; };
}
