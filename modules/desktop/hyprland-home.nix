{ lib ? (import <nixpkgs> { }).lib, ... }:
let
  common = import ../../lib/common.nix { inherit lib; };
  configDir = common.assertFileExists ../../config/hypr
    "Config source directory 'config/hypr/' not found. Required by modules/desktop/hyprland-home.nix.";

  moduleBody = { pkgs, ... }: {
    config = {
      wayland.windowManager.hyprland = {
        enable = true;
        # Use nixpkgs' cached binary rather than building the flake input from
        # source — matches modules/desktop/hyprland.nix's system-level choice.
      };

      home.packages = [
        pkgs.awww # renamed from swww
        pkgs.playerctl
        pkgs.brightnessctl
        pkgs.hypridle
        pkgs.hyprpolkitagent
      ];

      xdg.configFile."hypr/hyprland.lua".source = configDir + "/hyprland.lua";
      xdg.configFile."hypr/hypridle.conf".source = configDir + "/hypridle.conf";
      # Wallpapers live at ~/.config/wallpapers/, user-managed directly —
      # not symlinked from the Nix store.
    };
  };
in
{
  # `nix run .#hyprland` launches a nested Hyprland session with the real
  # config, for testing config changes without touching the actual login
  # session. Reference for adding other compositors the same way: wrap the
  # real binary, point --config (or that compositor's equivalent flag) at
  # the same config/ source directory home-manager symlinks from above.
  perSystem = { pkgs, ... }: {
    packages.hyprland = pkgs.symlinkJoin {
      name = "hyprland";
      paths = [ pkgs.hyprland ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/Hyprland \
          --add-flags "--config ${configDir}/hyprland.lua"
      '';
      meta.mainProgram = "Hyprland";
    };
  };

  flake.homeModules."hyprland-home" = moduleBody;
}
