# Run: nix eval --impure --file tests/modules/desktop/hyprland.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ ../../../modules/desktop/hyprland.nix ];
  cfg = sys.config;
in
lib.runTests {
  testHyprlandEnabled = { expr = cfg.programs.hyprland.enable; expected = true; };
  testXwaylandEnabled = { expr = cfg.programs.hyprland.xwayland.enable; expected = true; };
  testSessionType = { expr = cfg.environment.sessionVariables.XDG_SESSION_TYPE; expected = "wayland"; };
  testCurrentDesktop = { expr = cfg.environment.sessionVariables.XDG_CURRENT_DESKTOP; expected = "Hyprland"; };
  testQtPlatform = { expr = cfg.environment.sessionVariables.QT_QPA_PLATFORM; expected = "wayland"; };
}
