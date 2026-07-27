{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.browsers;
in {
  options.custom.user.browsers = {
    enable = lib.mkEnableOption "browser configuration (Firefox, Chromium)";
  };

  config = lib.mkIf cfg.enable {
    # Firefox as primary browser with Wayland support (Req 20.1)
    programs.firefox = {
      enable = true;
      profiles.default = {
        settings = {
          # Enable VA-API hardware video acceleration (Req 20.4)
          "media.ffmpeg.vaapi.enabled" = true;
        };
      };
    };

    # Chromium as secondary browser with Wayland + VA-API flags (Req 20.2, 20.4)
    programs.chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--enable-features=UseOzonePlatform,VaapiVideoDecoder"
      ];
    };

    # MOZ_ENABLE_WAYLAND for Firefox Wayland-native rendering (Req 20.1)
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };

    # Set Firefox as default browser for XDG URL handling (Req 20.3)
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };
}
