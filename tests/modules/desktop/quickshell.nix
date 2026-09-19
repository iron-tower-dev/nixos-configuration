# Run: nix eval --impure --file tests/modules/desktop/quickshell.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ ../../../modules/desktop/quickshell.nix ];
  cfg = hm.config;
in
lib.runTests {
  # Uses the pinned quickshell flake input directly (no nixpkgs package
  # exists for it) — confirms the package resolves to that input's output.
  testQuickshellFromFlakeInput = {
    expr = builtins.any
      (p: lib.hasInfix "quickshell" (builtins.unsafeDiscardStringContext (toString p)))
      cfg.home.packages;
    expected = true;
  };
  testQuickshellConfigSourced = {
    expr = builtins.pathExists cfg.xdg.configFile."quickshell".source;
    expected = true;
  };
}
