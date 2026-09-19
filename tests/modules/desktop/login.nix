# Run: nix eval --impure --file tests/modules/desktop/login.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ (harness.nixosModuleFrom ../../../modules/desktop/login.nix "login") ];
  cfg = sys.config;
in
lib.runTests {
  testLyEnabled = { expr = cfg.services.displayManager.ly.enable; expected = true; };
  testDefaultSessionIsHyprland = { expr = cfg.services.displayManager.defaultSession; expected = "hyprland"; };
  testNoGdmConflict = { expr = cfg.services.displayManager.gdm.enable; expected = false; };
  testNoSddmConflict = { expr = cfg.services.displayManager.sddm.enable; expected = false; };
}
