{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.comms;
in {
  options.custom.user.comms = {
    enable = lib.mkEnableOption "communication apps (Discord, Telegram)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Discord with OpenASAR for performance and Wayland support (Req 23.1, 23.3)
      # GTK theme integration is automatic when GTK is configured via theming module
      (discord.override { withOpenASAR = true; })

      # Telegram Desktop — Qt-based, uses system Qt theme automatically (Req 23.2, 23.4)
      # Qt theme integration is automatic when Qt is configured via theming module
      telegram-desktop
    ];

    # Wayland support for Discord (Electron app) (Req 23.1)
    xdg.desktopEntries.discord = {
      name = "Discord";
      exec = "discord --enable-features=UseOzonePlatform --ozone-platform=wayland";
      icon = "discord";
      comment = "All-in-one voice and text chat";
      categories = [ "Network" "InstantMessaging" ];
      terminal = false;
    };
  };
}
