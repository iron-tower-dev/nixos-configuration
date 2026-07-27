{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.dev-tools;
in {
  options.custom.user.dev-tools = {
    enable = lib.mkEnableOption "development environment tools (devenv, direnv, nix-direnv)";
  };

  config = lib.mkIf cfg.enable {
    # Install devenv for Nix-based development environments (Req 16.1)
    home.packages = [
      pkgs.devenv
    ];

    # direnv and nix-direnv for automatic environment activation (Req 16.2, 16.5, 16.7)
    # Note: Shell integrations (fish, zsh, nushell) are handled in shell.nix (Req 16.6)
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      # Configure automatic .envrc loading and unloading behavior
      config = {
        global = {
          # Automatically load .envrc when entering a directory (Req 16.5)
          load_dotenv = true;
          # Silently unload when leaving a directory (Req 16.7)
          hide_env_diff = true;
        };
        whitelist = {
          # Allow all project directories under home to auto-load
          prefix = [ "~/projects" "~/src" "~/dev" ];
        };
      };
    };
  };
}
