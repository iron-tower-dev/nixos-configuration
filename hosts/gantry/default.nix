# gantry — desktop (this machine's eventual NixOS install; stays Arch for
# now, this config is built and ready, disk untouched until deploy).
{ inputs, self, ... }:
let
  hostsLib = import ../../lib/hosts.nix;

  moduleBody = { config, lib, inputs, self, ... }:
    let
      userName = config.custom.base.users.name;
    in
    {
      imports = [
        ./_disko.nix

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
        self.nixosModules.hyprland
        self.nixosModules.login
        self.nixosModules.comms
        self.nixosModules.virtualization
        self.nixosModules.containers
        self.nixosModules.impermanence
        self.nixosModules.secrets

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
      home-manager.extraSpecialArgs = { inherit inputs self; };
      home-manager.users.${userName} = {
        home.stateVersion = "25.05";
        imports = [
          self.homeModules.git
          self.homeModules."hyprland-home"
          self.homeModules.quickshell
          self.homeModules.rofi
          self.homeModules.theming
          self.homeModules.shells
          self.homeModules.terminal
          self.homeModules.editors
          self.homeModules.files
          self.homeModules.browsers
          self.homeModules.clipboard
          self.homeModules.xdg
          self.homeModules.utilities
          self.homeModules.languages
          self.homeModules.devenv
        ];
      };

      system.stateVersion = "25.05";
    };
in
{
  flake.nixosConfigurations.gantry = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [ self.nixosModules.gantry ];
  };

  flake.nixosModules.gantry = moduleBody;
}
