# modules/user/languages.nix
# Requirement 15: Programming — Languages and SDKs
{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.languages;
in {
  options.custom.user.languages = {
    enable = lib.mkEnableOption "programming languages and SDKs";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Rust toolchain via rustup (Req 15.1)
      # Provides rustc, cargo, clippy, rustfmt
      rustup

      # Go toolchain (Req 15.2)
      go
      gopls

      # .NET SDK with language server (Req 15.3)
      dotnet-sdk_8
      omnisharp-roslyn

      # Node.js LTS with npm and fnm version manager (Req 15.4)
      nodejs_22
      fnm

      # Elixir with Erlang/OTP and language server (Req 15.5)
      elixir
      erlang
      elixir-ls

      # Gleam with language server (Req 15.6)
      gleam

      # JetBrains Rider — backup C#/.NET IDE (Req 15.7)
      jetbrains.rider
    ];

    # fnm shell integration (Req 15.4)
    # Add fnm environment setup hooks for each shell.
    # Users loading config-source shell files should add the eval hook there;
    # these provide baseline integration if no config-source override exists.
    programs.fish.interactiveShellInit = lib.mkAfter ''
      fnm env --use-on-cd --shell fish | source
    '';

    programs.zsh.initExtra = lib.mkAfter ''
      eval "$(fnm env --use-on-cd --shell zsh)"
    '';

    programs.nushell.extraConfig = lib.mkAfter ''
      fnm env --use-on-cd --shell nu | save -f ~/.cache/fnm-env.nu
      source ~/.cache/fnm-env.nu
    '';
  };
}
