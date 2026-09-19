{ ... }:
let
  moduleBody = { ... }: {
    config = {
      programs.firefox = {
        enable = true;
        profiles.default = {
          settings = {
            "media.ffmpeg.vaapi.enabled" = true;
          };
        };
      };

      programs.chromium = {
        enable = true;
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--enable-features=UseOzonePlatform,VaapiVideoDecoder"
        ];
      };

      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
      };

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };
  };
in
{
  flake.homeModules.browsers = moduleBody;
}
