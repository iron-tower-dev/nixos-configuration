{ ... }:
let
  maxEntries = 750;

  moduleBody = { pkgs, ... }:
    let
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
    in
    {
      config = {
        home.packages = [
          pkgs.wl-clipboard
          pkgs.cliphist
          pkgs.grim
          pkgs.slurp
          screenshot
        ];

        systemd.user.services.cliphist-watcher = {
          Unit.Description = "Clipboard history watcher";
          Unit.After = [ "graphical-session.target" ];
          Service = {
            ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist -max-items ${toString maxEntries} store'";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
in
{
  flake.homeModules.clipboard = moduleBody;
}
