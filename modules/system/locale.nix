{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.locale;
in {
  options.custom.system.locale = {
    enable = lib.mkEnableOption "locale, timezone, and keyboard layout";

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      description = "System timezone (e.g. America/New_York).";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "Default system locale.";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      description = "Keyboard layout for X11/Wayland and the virtual console.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Timezone
    time.timeZone = cfg.timezone;

    # Locale
    i18n.defaultLocale = cfg.locale;

    # Keyboard layout for X/Wayland sessions
    services.xserver.xkb.layout = cfg.keyboardLayout;

    # Keyboard layout for the virtual console
    console.keyMap = cfg.keyboardLayout;
  };
}
