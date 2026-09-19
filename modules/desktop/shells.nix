{ lib, ... }:
let
  configDir = ../../config;
in
{
  config = {
    programs.fish.enable = true;
    programs.zsh.enable = true;

    programs.nushell = {
      enable = true;
      configFile.source = lib.mkIf (builtins.pathExists (configDir + "/nushell/config.nu"))
        (configDir + "/nushell/config.nu");
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
    };

    xdg.configFile."fish/config.fish" = lib.mkIf (builtins.pathExists (configDir + "/fish/config.fish")) (lib.mkForce {
      source = configDir + "/fish/config.fish";
    });

    home.file.".zshrc" = lib.mkIf (builtins.pathExists (configDir + "/zsh/.zshrc")) {
      source = configDir + "/zsh/.zshrc";
    };
  };
}
