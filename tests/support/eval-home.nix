# Shared test harness for home-manager-scoped modules (git identity, shells,
# theming, editors, etc.) — evaluates via home-manager's own standalone
# homeManagerConfiguration, pure eval only, never realizing a store path.
# Callers must invoke with --impure (builtins.getFlake requires it).
let
  flake = builtins.getFlake (toString ../..);
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
in
{
  evalHome = modules: flake.inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      {
        home.stateVersion = "25.05";
        home.username = "ds";
        home.homeDirectory = "/home/ds";
      }
    ] ++ modules;
  };
}
