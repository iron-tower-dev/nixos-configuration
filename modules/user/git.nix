{ config, lib, pkgs, ... }:
let
  cfg = config.custom.user.git;
in {
  options.custom.user.git = {
    enable = lib.mkEnableOption "git and SSH configuration";

    userName = lib.mkOption {
      type = lib.types.str;
      default = "Derrick Southworth";
      description = "Git user name for commits";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "derricksouthworth@gmail.com";
      description = "Git user email for commits";
    };
  };

  config = lib.mkIf cfg.enable {
    # Git configuration (Req 21.1, 21.2)
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "nvim";
      };
    };

    # SSH configuration with GitHub host entry (Req 21.3, 21.4)
    programs.ssh = {
      enable = true;
      matchBlocks."github.com" = {
        identityFile = "~/.ssh/id_ed25519";
        user = "git";
      };
    };

    # SSH agent to auto-add GitHub key on session start (Req 21.5)
    services.ssh-agent.enable = true;
  };
}
