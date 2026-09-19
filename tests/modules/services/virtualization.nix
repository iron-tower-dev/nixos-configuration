# Run: nix eval --impure --file tests/modules/services/virtualization.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  mkSys = isDev: harness.evalHost [
    ../../../modules/host
    (harness.nixosModuleFrom ../../../modules/base/users.nix "users")
    (harness.nixosModuleFrom ../../../modules/services/virtualization.nix "virtualization")
    { custom.host.isDev = isDev; }
  ];
  dev = (mkSys true).config;
  notDev = (mkSys false).config;
in
lib.runTests {
  testLibvirtdEnabled = { expr = dev.virtualisation.libvirtd.enable; expected = true; };
  testVirtManagerEnabled = { expr = dev.programs.virt-manager.enable; expected = true; };
  testUserInLibvirtdGroup = {
    expr = builtins.elem "libvirtd" dev.users.users.ds.extraGroups;
    expected = true;
  };

  testLibvirtdDisabledWhenNotDev = { expr = notDev.virtualisation.libvirtd.enable; expected = false; };
}
