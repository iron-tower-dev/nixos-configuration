# mast — ASUS ROG Zephyrus G14 GA401IV laptop, the near-term real
# deployment target. Full wipe (no dual-boot), LUKS-encrypted.
{ config, lib, inputs, self, ... }:
let
  hostsLib = import ../../lib/hosts.nix;
  userName = config.custom.base.users.name;
in
{
  imports = [
    ./disko.nix

    self.nixosModules.host
    self.nixosModules.boot
    self.nixosModules.users
    self.nixosModules.networking
    self.nixosModules.audio
    self.nixosModules.bluetooth
    self.nixosModules.locale
    self.nixosModules."nix-settings"
    self.nixosModules.gpu
    self.nixosModules.steam
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/login.nix
    ../../modules/desktop/comms.nix
    self.nixosModules.virtualization
    self.nixosModules.containers
    self.nixosModules.impermanence
    self.nixosModules.secrets
    self.nixosModules.power

    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "mast";
  nixpkgs.hostPlatform = "x86_64-linux";
  # discord (comms.nix) and the NVIDIA driver stack are both unfree.
  nixpkgs.config.allowUnfree = true;

  custom.host = hostsLib.mast;
  custom.gaming.gpu.driver = hostsLib.mast.gpu.driver;
  custom.gaming.gpu.prime = {
    # PLACEHOLDER PCI bus IDs — replace with real `lspci | grep -E 'VGA|3D'`
    # output from the physical laptop before deploying.
    amdgpuBusId = "PCI:5:0:0";
    nvidiaBusId = "PCI:1:0:0";
  };

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
      self.homeModules.languages
      self.homeModules.devenv
    ];
  };

  system.stateVersion = "25.05";
}
