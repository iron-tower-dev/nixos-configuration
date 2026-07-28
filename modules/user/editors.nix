# modules/user/editors.nix
# Requirement 13: Editors — Neovim and Emacs
{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.editors;
  configDir = ../../config;
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
      package = pkgs.emacs-pgtk;
    };

    # Config-source passthrough (Req 13.1, 13.2, 13.5)
    # Symlink nvim files individually so ~/.config/nvim/ stays writable (for lock files)
    xdg.configFile."nvim/init.lua".source = configDir + "/nvim/init.lua";
    xdg.configFile."nvim/lua".source = configDir + "/nvim/lua";
    xdg.configFile."emacs".source = configDir + "/emacs";

    # Language servers on PATH (Req 13.3)
    # Formatters on PATH (Req 13.4)
    home.packages = with pkgs; [
      # Language servers
      rust-analyzer
      gopls
      omnisharp-roslyn
      typescript-language-server
      elixir-ls
      gleam # includes gleam LSP

      # Formatters (standalone ones not bundled with language toolchains)
      csharpier
      prettier

      # Tree-sitter CLI (needed by nvim-treesitter to compile grammars)
      tree-sitter
      gcc  # C compiler for tree-sitter grammar compilation
    ];
  };
}
