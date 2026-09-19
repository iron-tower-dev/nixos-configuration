# Shared test harness: evaluates a set of NixOS modules through the real
# module system (lib.nixosSystem, from this repo's pinned nixpkgs) so
# tests/<module>.nix can assert against real merged option values, not just
# the module's own option declarations.
#
# Pure evaluation only — tests must never force config.system.build.toplevel,
# which would realize store derivations.
#
# Callers must invoke with --impure (builtins.getFlake requires it).
let
  flake = builtins.getFlake (toString ../..);
  lib = flake.inputs.nixpkgs.lib;
in
{
  evalHost = modules: lib.nixosSystem {
    system = "x86_64-linux";
    modules = [{ system.stateVersion = "25.05"; }] ++ modules;
  };
}
