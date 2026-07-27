{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.xdg;
in {
  options.custom.user.xdg = {
    enable = lib.mkEnableOption "XDG base directories and MIME defaults";
  };

  config = lib.mkIf cfg.enable {
    # Enable XDG base directory management (Req 25.1)
    xdg.enable = true;

    # Set XDG base directories to standard paths (Req 25.1)
    xdg.configHome = "${config.home.homeDirectory}/.config";
    xdg.dataHome = "${config.home.homeDirectory}/.local/share";
    xdg.cacheHome = "${config.home.homeDirectory}/.cache";
    xdg.stateHome = "${config.home.homeDirectory}/.local/state";

    # Export XDG variables in user sessions (Req 25.1)
    home.sessionVariables = {
      XDG_CONFIG_HOME = config.xdg.configHome;
      XDG_DATA_HOME = config.xdg.dataHome;
      XDG_CACHE_HOME = config.xdg.cacheHome;
      XDG_STATE_HOME = config.xdg.stateHome;
    };

    # MIME type defaults (Req 19.4, 20.3)
    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = {
      # Thunar for directory handling (Req 19.4)
      "inode/directory" = "thunar.desktop";
      # Firefox for URL handling (Req 20.3)
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };
}
