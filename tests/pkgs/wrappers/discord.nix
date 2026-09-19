# Run: nix eval --impure --file tests/pkgs/wrappers/discord.nix --apply "f: f {}"
# Pure eval only: asserts against the derivation's buildCommand text, never builds it.
{ lib ? (import <nixpkgs> { }).lib }:
let
  flake = builtins.getFlake (toString ../../..);
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
  drv = import ../../../pkgs/wrappers/discord.nix { inherit pkgs; };
in
lib.runTests {
  testWrapsRealDiscordPackage = {
    expr = builtins.any (p: lib.hasInfix "-discord-" (builtins.toString p)) drv.paths;
    expected = true;
  };
  testAddsOzonePlatformFlag = {
    expr = lib.hasInfix "--ozone-platform=wayland" drv.buildCommand;
    expected = true;
  };
  testAddsUseOzonePlatformFeature = {
    expr = lib.hasInfix "--enable-features=UseOzonePlatform" drv.buildCommand;
    expected = true;
  };
}
