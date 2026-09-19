# Run: nix eval --impure --file tests/modules/desktop/hyprland-home.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ ../../../modules/desktop/hyprland-home.nix ];
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
}
