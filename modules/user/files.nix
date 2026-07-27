{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.files;
  configDir = ../../config;
in {
  options.custom.user.files = {
    enable = lib.mkEnableOption "file managers (Thunar, yazi)";
  };

  config = lib.mkIf cfg.enable {
    # Install Thunar with plugins and yazi
    home.packages = with pkgs; [
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.tumbler
      yazi
    ];

    # Load yazi config from Config_Source
    xdg.configFile."yazi".source = configDir + "/yazi";

    # Register Thunar as default for directory MIME type
    xdg.mimeApps.defaultApplications."inode/directory" = "thunar.desktop";

    # Thunar daemon mode for file operation progress and volume management
    systemd.user.services.thunar-daemon = {
      Unit.Description = "Thunar file manager daemon";
      Service.ExecStart = "${pkgs.xfce.thunar}/bin/thunar --daemon";
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
