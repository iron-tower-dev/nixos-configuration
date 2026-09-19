# Run: nix eval --impure --file tests/modules/desktop/clipboard.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ ../../../modules/desktop/clipboard.nix ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testWlClipboardInstalled = { expr = hasPname "wl-clipboard" cfg.home.packages; expected = true; };
  testCliphistInstalled = { expr = hasPname "cliphist" cfg.home.packages; expected = true; };
  testScreenshotScriptInstalled = { expr = hasPname "screenshot" cfg.home.packages; expected = true; };
  testCliphistWatcherService = {
    expr = builtins.hasAttr "cliphist-watcher" cfg.systemd.user.services;
    expected = true;
  };
  testCliphistWatcherUsesConfiguredMaxEntries = {
    expr = builtins.any (lib.hasInfix "-max-items 750") (lib.toList cfg.systemd.user.services.cliphist-watcher.Service.ExecStart);
    expected = true;
  };
}
