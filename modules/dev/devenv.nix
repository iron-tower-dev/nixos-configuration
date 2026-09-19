{ pkgs, ... }: {
  config = {
    home.packages = [ pkgs.devenv ];

    programs.direnv.config = {
      global = {
        load_dotenv = true;
        hide_env_diff = true;
      };
      whitelist.prefix = [ "~/projects" "~/src" "~/dev" ];
    };
  };
}
