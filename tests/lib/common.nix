# Run: nix eval --impure --file tests/lib/common.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  common = import ../../lib/common.nix { inherit lib; };
in
lib.runTests {
  testHasRoleTrueWhenSet = {
    expr = common.hasRole { isGaming = true; } "isGaming";
    expected = true;
  };
  testHasRoleFalseWhenSetFalse = {
    expr = common.hasRole { isGaming = false; } "isGaming";
    expected = false;
  };
  testHasRoleFalseWhenAbsent = {
    expr = common.hasRole { isGaming = true; } "isServer";
    expected = false;
  };

  testAssertFileExistsReturnsPathWhenPresent = {
    expr = (builtins.tryEval (common.assertFileExists ../../lib/hosts.nix "missing")).success;
    expected = true;
  };
  testAssertFileExistsThrowsWhenAbsent = {
    expr = (builtins.tryEval (common.assertFileExists ../../lib/does-not-exist.nix "missing")).success;
    expected = false;
  };
}
