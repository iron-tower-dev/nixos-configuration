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

  # Every file under ./modules and ./hosts is a self-registering flake-parts
  # module (flake.nixosModules.<tag> / flake.homeModules.<tag> /
  # flake.nixosConfigurations.<host>), auto-discovered by import-tree — no
  # per-file registration needed here. Host disko configs (hosts/*/_disko.nix)
  # are underscore-prefixed specifically so import-tree's default filter
  # skips them: they're plain attrsets consumed directly by each host's own
  # module body, not flake-parts modules themselves.
  outputs = inputs@{ self, nixpkgs, flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        # flake-parts pre-declares `flake.nixosModules`/`flake.darwinModules`
        # as mergeable (lazyAttrsOf deferredModule), but not
        # `flake.homeModules` — home-manager isn't its concern. Without this,
        # every file's `flake.homeModules.<tag> = ...;` collides as "defined
        # multiple times" on a non-mergeable freeform attrset instead of
        # merging cleanly.
        {
          options.flake.homeModules = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.lazyAttrsOf nixpkgs.lib.types.deferredModule;
            default = { };
          };
        }

        # flake-parts' default perSystem `pkgs` doesn't have allowUnfree set
        # (it's a plain `legacyPackages.<system>`), unlike our hosts' own
        # pkgs — comms.nix's discord package build fails perSystem
        # evaluation otherwise.
        {
          perSystem = { system, ... }: {
            _module.args.pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          };
        }

        (import-tree ./modules)
        (import-tree ./hosts)
      ];
    };
}
