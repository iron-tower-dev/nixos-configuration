# Run: nix eval --impure --file tests/modules/base/locale.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ ../../../modules/base/locale.nix ];
  cfg = sys.config;
in
lib.runTests {
  testDefaultTimezoneIsUtc = { expr = cfg.time.timeZone; expected = "UTC"; };
  testDefaultLocale = { expr = cfg.i18n.defaultLocale; expected = "en_US.UTF-8"; };
  testDefaultKeyboardLayoutXkb = { expr = cfg.services.xserver.xkb.layout; expected = "us"; };
  testDefaultKeyboardLayoutConsole = { expr = cfg.console.keyMap; expected = "us"; };
}
