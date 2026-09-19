{ pkgs, ... }: {
  config.home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    htop
    btop
  ];
}
