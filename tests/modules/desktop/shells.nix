# Run: nix eval --impure --file tests/modules/desktop/shells.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ (harness.homeModuleFrom ../../../modules/desktop/shells.nix "shells") ];
  cfg = hm.config;
in
lib.runTests {
  testFishEnabled = { expr = cfg.programs.fish.enable; expected = true; };
  testZshEnabled = { expr = cfg.programs.zsh.enable; expected = true; };
  testNushellEnabled = { expr = cfg.programs.nushell.enable; expected = true; };
  testStarshipEnabled = { expr = cfg.programs.starship.enable; expected = true; };
  testStarshipFishIntegration = { expr = cfg.programs.starship.enableFishIntegration; expected = true; };
  testDirenvEnabled = { expr = cfg.programs.direnv.enable; expected = true; };
  testNixDirenvEnabled = { expr = cfg.programs.direnv.nix-direnv.enable; expected = true; };

  # Config_Source integration: real files under config/fish, config/nushell.
  testFishConfigSourced = {
    expr = lib.hasSuffix "config/fish/config.fish" (toString cfg.xdg.configFile."fish/config.fish".source);
    expected = true;
  };
  testNushellConfigSourced = {
    expr = lib.hasSuffix "config/nushell/config.nu" (toString cfg.programs.nushell.configFile.source);
    expected = true;
  };
}
