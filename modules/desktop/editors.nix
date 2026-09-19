{ pkgs, ... }:
let
  configDir = ../../config;
in
{
  config = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
    };

    xdg.configFile."nvim/init.lua".source = configDir + "/nvim/init.lua";
    xdg.configFile."nvim/lua".source = configDir + "/nvim/lua";
    xdg.configFile."emacs".source = configDir + "/emacs";

    home.packages = with pkgs; [
      rust-analyzer
      gopls
      omnisharp-roslyn
      typescript-language-server
      elixir-ls
      gleam

      csharpier
      prettier

      tree-sitter
      gcc
    ];
  };
}
