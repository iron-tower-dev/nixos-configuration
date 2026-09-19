{ pkgs, ... }:
let
  wrappers = import ../../pkgs/wrappers { inherit pkgs; };
in
{
  config = {
    environment.systemPackages = [
      wrappers.discord
      pkgs.telegram-desktop
    ];
  };
}
