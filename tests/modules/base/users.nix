# Run: nix eval --impure --file tests/modules/base/users.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ ../../../modules/base/users.nix ];
  cfg = sys.config;
in
lib.runTests {
  testUserIsNormalUser = {
    expr = cfg.users.users.ds.isNormalUser;
    expected = true;
  };
  testUserDescription = {
    expr = cfg.users.users.ds.description;
    expected = "Derrick Southworth";
  };
  testUserHasWheelGroup = {
    expr = builtins.elem "wheel" cfg.users.users.ds.extraGroups;
    expected = true;
  };
  testUserHasNetworkManagerGroup = {
    expr = builtins.elem "networkmanager" cfg.users.users.ds.extraGroups;
    expected = true;
  };
  testUserShellIsFish = {
    expr = lib.hasInfix "fish" (cfg.users.users.ds.shell.pname or cfg.users.users.ds.shell.name or "");
    expected = true;
  };
  testFishProgramEnabled = {
    expr = cfg.programs.fish.enable;
    expected = true;
  };
}
