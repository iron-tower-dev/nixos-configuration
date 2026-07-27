{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.wayland;
in {
  options.custom.system.wayland = {
    enable = lib.mkEnableOption "Wayland infrastructure";
  };

  config = lib.mkIf cfg.enable {
    # XDG Desktop Portal for Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    # XWayland for X11 app compatibility
    programs.xwayland.enable = true;

    # D-Bus session bus (required for portal and widget communication)
    services.dbus.enable = true;

    # Wayland session environment variables
    # Note: WAYLAND_DISPLAY is set by the compositor at runtime
    environment.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      QT_QPA_PLATFORM = "wayland";
    };
  };
}
