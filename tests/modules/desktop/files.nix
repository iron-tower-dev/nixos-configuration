# Run: nix eval --impure --file tests/modules/desktop/files.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ (harness.homeModuleFrom ../../../modules/desktop/files.nix "files") ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testThunarInstalled = { expr = hasPname "thunar" cfg.home.packages; expected = true; };
  testYaziInstalled = { expr = hasPname "yazi" cfg.home.packages; expected = true; };
  testThunarDefaultForDirectories = {
    expr = builtins.elem "thunar.desktop" cfg.xdg.mimeApps.defaultApplications."inode/directory";
    expected = true;
  };
  testThunarDaemonService = {
    expr = builtins.hasAttr "thunar-daemon" cfg.systemd.user.services;
    expected = true;
  };
}
