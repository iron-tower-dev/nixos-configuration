{ config, ... }: {
  config = {
    xdg.enable = true;

    xdg.configHome = "${config.home.homeDirectory}/.config";
    xdg.dataHome = "${config.home.homeDirectory}/.local/share";
    xdg.cacheHome = "${config.home.homeDirectory}/.cache";
    xdg.stateHome = "${config.home.homeDirectory}/.local/state";

    home.sessionVariables = {
      XDG_CONFIG_HOME = config.xdg.configHome;
      XDG_DATA_HOME = config.xdg.dataHome;
      XDG_CACHE_HOME = config.xdg.cacheHome;
      XDG_STATE_HOME = config.xdg.stateHome;
    };

    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = {
      "inode/directory" = "thunar.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };
}
