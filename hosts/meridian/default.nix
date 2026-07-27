# hosts/meridian/default.nix
{ config, pkgs, ... }: {
  imports = [ ./hardware.nix ];

  networking.hostName = "meridian";

  # System-level user declaration
  users.users.ds = {
    isNormalUser = true;
    description = "Derrick Southworth";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  # Required when setting a user shell to fish
  programs.fish.enable = true;

  # System modules
  custom.system = {
    boot.enable = true;
    gpu.enable = true;
    audio.enable = true;
    networking.enable = true;
    bluetooth.enable = true;
    gaming.enable = true;
    virtualization.enable = true;
    containers.enable = true;
    snapshots.enable = true;
    login.enable = true;
    wayland.enable = true;
    nix-settings.enable = true;
    locale.enable = true;
  };

  system.stateVersion = "25.05";

  # User modules
  home-manager.users.ds = {
    home.stateVersion = "25.05";

    custom.user = {
      shell.enable = true;
      terminal.enable = true;
      editors.enable = true;
      hyprland.enable = true;
      quickshell.enable = true;
      theming.enable = true;
      rofi.enable = true;
      clipboard.enable = true;
      browsers.enable = true;
      files.enable = true;
      git.enable = true;
      dev-tools.enable = true;
      languages.enable = true;
      comms.enable = true;
      xdg.enable = true;
      utilities.enable = true;
    };
  };
}
