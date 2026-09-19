# Run: nix eval --impure --file tests/modules/desktop/theming.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ ../../../modules/desktop/theming.nix ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testMatugenFromFlakeInput = {
    expr = builtins.any
      (p: lib.hasInfix "matugen" (builtins.unsafeDiscardStringContext (toString p)))
      cfg.home.packages;
    expected = true;
  };
  testThemeSwitchScriptInstalled = { expr = hasPname "theme-switch" cfg.home.packages; expected = true; };
  testMatugenConfigSourced = { expr = builtins.pathExists cfg.xdg.configFile."matugen".source; expected = true; };

  testGtkEnabled = { expr = cfg.gtk.enable; expected = true; };
  testGtkThemeName = { expr = cfg.gtk.theme.name; expected = "adw-gtk3-dark"; };
  testGtkIconThemeName = { expr = cfg.gtk.iconTheme.name; expected = "Papirus-Dark"; };

  testQtEnabled = { expr = cfg.qt.enable; expected = true; };
  testQtUsesModernGtk3Plugin = { expr = cfg.qt.platformTheme.name; expected = "gtk3"; };

  testPointerCursorTheme = { expr = cfg.home.pointerCursor.name; expected = "phinger-cursors-dark"; };
  testPointerCursorGtkIntegration = { expr = cfg.home.pointerCursor.gtk.enable; expected = true; };

  testRestoresThemeOnActivation = {
    expr = builtins.hasAttr "restoreTheme" cfg.home.activation;
    expected = true;
  };
}
