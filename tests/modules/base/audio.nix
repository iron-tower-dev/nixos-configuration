# Run: nix eval --impure --file tests/modules/base/audio.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [ (harness.nixosModuleFrom ../../../modules/base/audio.nix "audio") ];
  cfg = sys.config;
in
lib.runTests {
  testPipewireEnabled = { expr = cfg.services.pipewire.enable; expected = true; };
  testAlsaEnabled = { expr = cfg.services.pipewire.alsa.enable; expected = true; };
  testPulseCompatEnabled = { expr = cfg.services.pipewire.pulse.enable; expected = true; };
  testStandalonePulseaudioDisabled = { expr = cfg.services.pulseaudio.enable; expected = false; };
  testWireplumberEnabled = { expr = cfg.services.pipewire.wireplumber.enable; expected = true; };
  testLowLatencyQuantum = {
    expr = cfg.services.pipewire.extraConfig.pipewire."92-low-latency".context.properties."default.clock.quantum";
    expected = 1024;
  };
  testLowLatencySampleRate = {
    expr = cfg.services.pipewire.extraConfig.pipewire."92-low-latency".context.properties."default.clock.rate";
    expected = 48000;
  };
}
