# Run: nix eval --impure --file tests/modules/desktop/hyprland-home.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  flakePartsModule = import ../../../modules/desktop/hyprland-home.nix { };
  pkgs = import <nixpkgs> { system = "x86_64-linux"; };
  standalonePkg = (flakePartsModule.perSystem { inherit pkgs; }).packages.hyprland;

  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ (harness.homeModuleFrom ../../../modules/desktop/hyprland-home.nix "hyprland-home") ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testHyprlandWindowManagerEnabled = { expr = cfg.wayland.windowManager.hyprland.enable; expected = true; };
  testSwwwInstalled = { expr = hasPname "awww" cfg.home.packages; expected = true; };
  testHypridleInstalled = { expr = hasPname "hypridle" cfg.home.packages; expected = true; };
  testHyprlandConfigSourced = {
    expr = builtins.readFile "${cfg.xdg.configFile."hypr/hyprland.lua".source}";
    expected = builtins.readFile ../../../config/hypr/hyprland.lua;
  };

  # `nix run .#hyprland` — nested-session testing package.
  testStandaloneWrapsRealHyprlandBinary = {
    expr = builtins.any (p: lib.hasInfix "-hyprland-" (builtins.unsafeDiscardStringContext (toString p))) standalonePkg.paths;
    expected = true;
  };
  testStandalonePassesConfigFlag = {
    expr = lib.hasInfix "--config" standalonePkg.buildCommand
      && lib.hasInfix "hyprland.lua" standalonePkg.buildCommand;
    expected = true;
  };
  testStandaloneMainProgramIsHyprland = {
    expr = standalonePkg.meta.mainProgram;
    expected = "Hyprland";
  };
}
