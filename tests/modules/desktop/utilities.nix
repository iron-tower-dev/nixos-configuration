# Run: nix eval --impure --file tests/modules/desktop/utilities.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ (harness.homeModuleFrom ../../../modules/desktop/utilities.nix "utilities") ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testRipgrepInstalled = { expr = hasPname "ripgrep" cfg.home.packages; expected = true; };
  testFdInstalled = { expr = hasPname "fd" cfg.home.packages; expected = true; };
  testBatInstalled = { expr = hasPname "bat" cfg.home.packages; expected = true; };
  testEzaInstalled = { expr = hasPname "eza" cfg.home.packages; expected = true; };
  testFzfInstalled = { expr = hasPname "fzf" cfg.home.packages; expected = true; };
  testJqInstalled = { expr = hasPname "jq" cfg.home.packages; expected = true; };
  testHtopInstalled = { expr = hasPname "htop" cfg.home.packages; expected = true; };
  testBtopInstalled = { expr = hasPname "btop" cfg.home.packages; expected = true; };
}
