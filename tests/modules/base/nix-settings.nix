# Run: nix eval --impure --file tests/modules/base/nix-settings.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ (harness.nixosModuleFrom ../../../modules/base/nix-settings.nix "nix-settings") ];
  cfg = sys.config;
in
lib.runTests {
  # Needed for the deployed system's own `nix`/`nixos-rebuild --flake` to work.
  testFlakesEnabled = {
    expr = builtins.elem "flakes" cfg.nix.settings.experimental-features;
    expected = true;
  };
  testNixCommandEnabled = {
    expr = builtins.elem "nix-command" cfg.nix.settings.experimental-features;
    expected = true;
  };
  testWeeklyGcEnabled = { expr = cfg.nix.gc.automatic; expected = true; };
  testGcDeletesOlderThan7Days = { expr = cfg.nix.gc.options; expected = "--delete-older-than 7d"; };
  testFstrimEnabled = { expr = cfg.services.fstrim.enable; expected = true; };
}
