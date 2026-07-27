# modules/user/editors.nix
# Requirement 13: Editors — Neovim and Emacs
{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.editors;
  configDir = ../../../config;
in {
  options.custom.user.editors = {
    enable = lib.mkEnableOption "editors (Neovim, Emacs) with LSPs and formatters";
  };

  config = lib.mkIf cfg.enable {
    # Neovim (Req 13.1)
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    # Emacs 29+ with native Wayland support (Req 13.2)
    programs.emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };

    # Config-source passthrough (Req 13.1, 13.2, 13.5)
    xdg.configFile."nvim".source = configDir + "/nvim";
    xdg.configFile."emacs".source = configDir + "/emacs";

    # Language servers on PATH (Req 13.3)
    # Formatters on PATH (Req 13.4)
    home.packages = with pkgs; [
      # Language servers
      rust-analyzer
      gopls
      omnisharp-roslyn
      nodePackages.typescript-language-server
      elixir-ls
      gleam # includes gleam LSP

      # Formatters (standalone ones not bundled with language toolchains)
      csharpier
      nodePackages.prettier
    ];
  };
}
