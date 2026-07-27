{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.bluetooth;
in {
  options.custom.system.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support (bluez)";
  };

  config = lib.mkIf cfg.enable {
    # Assert audio module is enabled — BT audio requires PipeWire
    assertions = [
      {
        assertion = config.custom.system.audio.enable;
        message = "custom.system.bluetooth requires custom.system.audio to be enabled (Bluetooth audio needs PipeWire)";
      }
    ];

    # Req 8.1: Enable bluez with D-Bus accessibility
    hardware.bluetooth = {
      enable = true;
      # Req 8.2: Auto-power-on at boot
      powerOnBoot = true;
      settings = {
        General = {
          # Enable BT audio source/sink/media/socket profiles
          Enable = "Source,Sink,Media,Socket";
          # Req 8.3: Persistent pairing and auto-reconnect
          Experimental = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # Req 8.5: Bluetooth management tool (blueman GUI + bluetoothctl via bluez)
    services.blueman.enable = true;

    # Req 8.4: PipeWire Bluetooth audio module
    # WirePlumber handles Bluetooth audio routing by default when bluez is
    # available. Ensure the wireplumber bluez monitor is enabled.
    environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",
      }
    '';
  };
}
