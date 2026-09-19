{ pkgs, ... }:
let
  configDir = ../../config;
in
{
  config = {
    home.packages = with pkgs; [
      thunar
      thunar-archive-plugin
      thunar-volman
      tumbler
      yazi
    ];

    xdg.configFile."yazi".source = configDir + "/yazi";

    xdg.mimeApps.defaultApplications."inode/directory" = "thunar.desktop";

    systemd.user.services.thunar-daemon = {
      Unit.Description = "Thunar file manager daemon";
      Service.ExecStart = "${pkgs.thunar}/bin/thunar --daemon";
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
