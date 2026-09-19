# Run: nix eval --impure --file tests/modules/desktop/terminal.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ ../../../modules/desktop/terminal.nix ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testAlacrittyEnabled = { expr = cfg.programs.alacritty.enable; expected = true; };
  testJqAvailable = { expr = hasPname "jq" cfg.home.packages; expected = true; };
  testColorGenScriptAvailable = { expr = hasPname "gen-alacritty-colors" cfg.home.packages; expected = true; };
  testConfigSourced = {
    expr = builtins.readFile cfg.xdg.configFile."alacritty/alacritty.toml".source;
    expected = builtins.readFile ../../../config/alacritty/alacritty.toml;
  };
  testGeneratesInitialColorsOnActivation = {
    expr = builtins.hasAttr "generateAlacrittyColors" cfg.home.activation;
    expected = true;
  };
}
