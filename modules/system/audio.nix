{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.audio;
in {
  options.custom.system.audio = {
    enable = lib.mkEnableOption "PipeWire audio";

    quantum = lib.mkOption {
      type = lib.types.int;
      default = 1024;
      description = "PipeWire audio quantum (buffer size in samples). Lower values reduce latency.";
    };

    sampleRate = lib.mkOption {
      type = lib.types.int;
      default = 48000;
      description = "PipeWire default sample rate in Hz.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable PipeWire as the audio server
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;

      # Configure quantum and sample rate for low-latency operation
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = cfg.sampleRate;
          "default.clock.quantum" = cfg.quantum;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = cfg.quantum;
        };
      };
    };

    # Disable standalone PulseAudio to prevent conflicts
    services.pulseaudio.enable = false;
  };
}
