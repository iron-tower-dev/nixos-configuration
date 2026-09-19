# Run: nix eval --impure --file tests/modules/desktop/xdg.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ (harness.homeModuleFrom ../../../modules/desktop/xdg.nix "xdg") ];
  cfg = hm.config;
in
lib.runTests {
  testXdgEnabled = { expr = cfg.xdg.enable; expected = true; };
  testConfigHomeExported = { expr = cfg.home.sessionVariables.XDG_CONFIG_HOME; expected = cfg.xdg.configHome; };
  testDataHomeExported = { expr = cfg.home.sessionVariables.XDG_DATA_HOME; expected = cfg.xdg.dataHome; };
  testMimeAppsEnabled = { expr = cfg.xdg.mimeApps.enable; expected = true; };
  testDirectoryDefaultIsThunar = {
    expr = builtins.elem "thunar.desktop" cfg.xdg.mimeApps.defaultApplications."inode/directory";
    expected = true;
  };
}
