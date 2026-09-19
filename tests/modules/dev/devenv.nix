# Run: nix eval --impure --file tests/modules/dev/devenv.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [
    (harness.homeModuleFrom ../../../modules/desktop/shells.nix "shells") # already enables direnv/nix-direnv
    (harness.homeModuleFrom ../../../modules/dev/devenv.nix "devenv")
  ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testDevenvInstalled = { expr = hasPname "devenv" cfg.home.packages; expected = true; };
  testDirenvStillEnabled = { expr = cfg.programs.direnv.enable; expected = true; };
  testAutoLoadEnvrc = { expr = cfg.programs.direnv.config.global.load_dotenv; expected = true; };
  testWhitelistsProjectDirs = {
    expr = builtins.elem "~/projects" cfg.programs.direnv.config.whitelist.prefix;
    expected = true;
  };
}
