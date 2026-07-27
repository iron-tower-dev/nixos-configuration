{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.clipboard;

  # Screenshot script supporting region and full-screen capture (Req 17.5, 17.6)
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    filename="$dir/screenshot_$(date +%Y%m%d_%H%M%S).png"
    if [ "$1" = "region" ]; then
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$filename"
    else
      ${pkgs.grim}/bin/grim "$filename"
    fi
  '';
in {
  options.custom.user.clipboard = {
    enable = lib.mkEnableOption "clipboard management and screenshot tools";

    maxEntries = lib.mkOption {
      type = lib.types.int;
      default = 750;
      description = "Maximum number of clipboard history entries stored by cliphist";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install clipboard and screenshot packages (Req 17.1, 17.2, 17.3)
    home.packages = [
      pkgs.wl-clipboard
      pkgs.cliphist
      pkgs.grim
      pkgs.slurp
      screenshot
    ];

    # Clipboard history watcher as a user service (Req 17.4)
    systemd.user.services.cliphist-watcher = {
      Unit.Description = "Clipboard history watcher";
      Unit.After = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist -max-items ${toString cfg.maxEntries} store'";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
