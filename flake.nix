{
  description = "Modular NixOS configuration for meridian";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    quickshell.url = "github:quickshell-mirror/quickshell";

    matugen.url = "github:InioX/matugen";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, quickshell, matugen, ... }@inputs: {
    nixosConfigurations.meridian = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/meridian/default.nix
        ./modules/system
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ds = import ./modules/user;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
