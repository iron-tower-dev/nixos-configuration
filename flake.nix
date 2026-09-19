{
  description = "Dendritic multi-host NixOS configuration (gantry, mast)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    quickshell.url = "github:quickshell-mirror/quickshell";

    matugen.url = "github:InioX/matugen";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  # MIGRATION NOTE: import-tree is scoped to only the subtrees that have
  # actually been converted to the flake-parts module shape so far. Widen
  # this list as each subtree converts; do NOT point it at the whole
  # ./modules or ./hosts directory until every file under it has been
  # converted — a single still-old-shape file swept in by import-tree
  # breaks the entire flake-parts evaluation (a plain NixOS module fed into
  # flake-parts' own option schema errors immediately, since e.g.
  # `hardware.graphics.enable` isn't a flake-parts option).
  #
  # nixosConfigurations.{gantry,mast} stay manually assembled here (not
  # relying on `import-tree ./hosts` self-registration) until hosts/gantry
  # and hosts/mast themselves are converted last, per the migration plan.
  outputs = inputs@{ self, nixpkgs, flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        (import-tree ./modules/base)
        (import-tree ./modules/gaming)
      ];

      flake.nixosConfigurations.gantry = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        modules = [ ./hosts/gantry ];
      };

      flake.nixosConfigurations.mast = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        modules = [ ./hosts/mast ];
      };
    };
}
