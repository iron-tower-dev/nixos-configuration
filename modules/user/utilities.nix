{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.utilities;
in {
  options.custom.user.utilities = {
    enable = lib.mkEnableOption "CLI utilities (ripgrep, fd, bat, eza, fzf, jq, htop, btop)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
      fd
      bat
      eza
      fzf
      jq
      htop
      btop
    ];
  };
}
