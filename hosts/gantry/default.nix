# gantry — desktop (this machine's eventual NixOS install; stays Arch for
# now, this config is built and ready, disk untouched until deploy).
{ config, lib, inputs, ... }:
let
  hostsLib = import ../../lib/hosts.nix;
  userName = config.custom.base.users.name;
in
{
  imports = [
    ./disko.nix

    ../../modules/host
    ../../modules/base/boot.nix
    ../../modules/base/users.nix
    ../../modules/base/networking.nix
    ../../modules/base/audio.nix
    ../../modules/base/bluetooth.nix
    ../../modules/base/locale.nix
    ../../modules/base/nix-settings.nix
    ../../modules/gaming/gpu.nix
    ../../modules/gaming/steam.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/login.nix
    ../../modules/desktop/comms.nix
    ../../modules/services/virtualization.nix
    ../../modules/services/containers.nix
    ../../modules/services/impermanence.nix
    ../../modules/services/secrets.nix

    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "gantry";
  nixpkgs.hostPlatform = "x86_64-linux";
  # discord (comms.nix) is unfree; nvidia (unused here, but shared gpu.nix
  # code path) would be too.
  nixpkgs.config.allowUnfree = true;

  custom.host = hostsLib.gantry;
  custom.gaming.gpu.driver = hostsLib.gantry.gpu.driver;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.${userName} = {
    home.stateVersion = "25.05";
    imports = [
      ../../modules/desktop/git.nix
      ../../modules/desktop/hyprland-home.nix
      ../../modules/desktop/quickshell.nix
      ../../modules/desktop/rofi.nix
      ../../modules/desktop/theming.nix
      ../../modules/desktop/shells.nix
      ../../modules/desktop/terminal.nix
      ../../modules/desktop/editors.nix
      ../../modules/desktop/files.nix
      ../../modules/desktop/browsers.nix
      ../../modules/desktop/clipboard.nix
      ../../modules/desktop/xdg.nix
      ../../modules/desktop/utilities.nix
      ../../modules/dev/languages.nix
      ../../modules/dev/devenv.nix
    ];
  };

  system.stateVersion = "25.05";
}
