# Run: nix eval --impure --file tests/pkgs/scripts/theme-switch.nix --apply "f: f {}"
# Pure eval only: asserts against the script's .text attribute (accessible
# pre-build for writeShellScriptBin derivations), never realizes the
# derivation.
{ lib ? (import <nixpkgs> { }).lib }:
let
  flake = builtins.getFlake (toString ../../..);
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
  drv = import ../../../pkgs/scripts/theme-switch.nix { inherit pkgs; };
in
lib.runTests {
  testIsNamedThemeSwitch = { expr = drv.pname or drv.name; expected = "theme-switch"; };
  testSupportsCatppuccinPreset = { expr = lib.hasInfix "catppuccin-mocha" drv.text; expected = true; };
  testSupportsNordPreset = { expr = lib.hasInfix "nord" drv.text; expected = true; };
  testInvokesMatugenForWallpapers = { expr = lib.hasInfix "matugen image" drv.text; expected = true; };
  testWritesAtomically = { expr = lib.hasInfix "mv \"$COLOR_TMP\" \"$COLOR_FILE\"" drv.text; expected = true; };
}
