# Run: nix eval --impure --file tests/modules/desktop/browsers.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ ../../../modules/desktop/browsers.nix ];
  cfg = hm.config;
in
lib.runTests {
  testFirefoxEnabled = { expr = cfg.programs.firefox.enable; expected = true; };
  testFirefoxVaapiEnabled = {
    expr = cfg.programs.firefox.profiles.default.settings."media.ffmpeg.vaapi.enabled";
    expected = true;
  };
  testChromiumEnabled = { expr = cfg.programs.chromium.enable; expected = true; };
  testChromiumOzoneFlag = {
    expr = builtins.elem "--ozone-platform-hint=auto" cfg.programs.chromium.commandLineArgs;
    expected = true;
  };
  testMozWaylandEnabled = { expr = cfg.home.sessionVariables.MOZ_ENABLE_WAYLAND; expected = "1"; };
  testFirefoxDefaultForHttp = {
    expr = builtins.elem "firefox.desktop" cfg.xdg.mimeApps.defaultApplications."x-scheme-handler/http";
    expected = true;
  };
}
