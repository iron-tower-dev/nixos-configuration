{ ... }:
let
  moduleBody = { pkgs, self, ... }: {
    config.environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.discord
      pkgs.telegram-desktop
    ];
  };
in
{
  # Discord is Electron-based and doesn't reliably pick up Wayland via
  # QT_QPA_PLATFORM the way native Qt apps do — it needs explicit Ozone
  # flags on its own launch command. Telegram (a native Qt app) needs no
  # wrapper of its own — it inherits QT_QPA_PLATFORM from hyprland.nix.
  perSystem = { pkgs, ... }: {
    packages.discord = pkgs.symlinkJoin {
      name = "discord";
      paths = [ (pkgs.discord.override { withOpenASAR = true; }) ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/discord \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
      '';
    };
  };

  flake.nixosModules.comms = moduleBody;
}
