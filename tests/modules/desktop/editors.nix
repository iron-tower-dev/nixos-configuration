# Run: nix eval --impure --file tests/modules/desktop/editors.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ (harness.homeModuleFrom ../../../modules/desktop/editors.nix "editors") ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testNeovimEnabled = { expr = cfg.programs.neovim.enable; expected = true; };
  testNeovimIsDefaultEditor = { expr = cfg.programs.neovim.defaultEditor; expected = true; };
  testEmacsEnabled = { expr = cfg.programs.emacs.enable; expected = true; };

  testNvimConfigSourced = {
    expr = builtins.readFile "${cfg.xdg.configFile."nvim/init.lua".source}";
    expected = builtins.readFile ../../../config/nvim/init.lua;
  };

  testRustAnalyzerAvailable = { expr = hasPname "rust-analyzer" cfg.home.packages; expected = true; };
  testGoplsAvailable = { expr = hasPname "gopls" cfg.home.packages; expected = true; };
  testTypescriptLsAvailable = { expr = hasPname "typescript-language-server" cfg.home.packages; expected = true; };
  testElixirLsAvailable = { expr = hasPname "elixir-ls" cfg.home.packages; expected = true; };
  testPrettierAvailable = { expr = hasPname "prettier" cfg.home.packages; expected = true; };
}
