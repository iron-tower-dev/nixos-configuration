{ ... }: {
  config = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "Derrick Southworth";
        user.email = "derricksouthworth@gmail.com";
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "nvim";
      };
    };

    programs.ssh = {
      enable = true;
      settings."*".AddKeysToAgent = "yes";
      settings."github.com" = {
        HostName = "github.com";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };

    services.ssh-agent.enable = true;
  };
}
