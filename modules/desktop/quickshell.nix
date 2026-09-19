{ lib, pkgs, inputs, ... }:
let
  common = import ../../lib/common.nix { inherit lib; };
  configDir = common.assertFileExists ../../config/quickshell
    "Config source directory 'config/quickshell/' not found. Required by modules/desktop/quickshell.nix.";
in
{
  config = {
    # No nixpkgs package exists for Quickshell — it comes straight from the
    # pinned flake input.
    home.packages = [ inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default ];

    xdg.configFile."quickshell".source = configDir;
  };
}
