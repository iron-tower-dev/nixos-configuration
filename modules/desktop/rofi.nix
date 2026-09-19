{ lib ? (import <nixpkgs> { }).lib, ... }:
let
  common = import ../../lib/common.nix { inherit lib; };
  configDir = common.assertFileExists ../../config/rofi
    "Config source directory 'config/rofi/' not found. Required by modules/desktop/rofi.nix.";

  moduleBody = { pkgs, ... }: {
    config = {
      home.packages = [ pkgs.rofi ];
      xdg.configFile."rofi".source = configDir;
    };
  };
in
{
  flake.homeModules.rofi = moduleBody;
}
