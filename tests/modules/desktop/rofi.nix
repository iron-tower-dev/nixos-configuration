# Run: nix eval --impure --file tests/modules/desktop/rofi.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ ../../../modules/desktop/rofi.nix ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testRofiInstalled = { expr = hasPname "rofi" cfg.home.packages; expected = true; };
  testRofiConfigSourced = { expr = builtins.pathExists cfg.xdg.configFile."rofi".source; expected = true; };
}
