{ ... }:
let
  moduleBody = { ... }: {
    config = {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      environment.sessionVariables = {
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "Hyprland";
        QT_QPA_PLATFORM = "wayland";
      };
    };
  };
in
{
  flake.nixosModules.hyprland = moduleBody;
}
