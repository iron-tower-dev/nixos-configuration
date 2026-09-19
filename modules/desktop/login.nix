{ ... }:
let
  moduleBody = { ... }: {
    config = {
      services.displayManager.ly.enable = true;
      services.displayManager.defaultSession = "hyprland";
    };
  };
in
{
  flake.nixosModules.login = moduleBody;
}
