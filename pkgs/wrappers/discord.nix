# Discord is Electron-based and doesn't reliably pick up Wayland via
# QT_QPA_PLATFORM the way native Qt apps do — it needs explicit Ozone flags
# on its own launch command.
{ pkgs }:
pkgs.symlinkJoin {
  name = "discord";
  paths = [ pkgs.discord ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/discord \
      --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
  '';
}
