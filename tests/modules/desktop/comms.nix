# Run: nix eval --impure --file tests/modules/desktop/comms.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  flakePartsModule = import ../../../modules/desktop/comms.nix { };
  pkgs = import <nixpkgs> { system = "x86_64-linux"; config.allowUnfree = true; };
  discordPkg = (flakePartsModule.perSystem { inherit pkgs; }).packages.discord;

  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [
    { _module.args.self = { packages.${pkgs.stdenv.hostPlatform.system}.discord = discordPkg; }; }
    flakePartsModule.flake.nixosModules.comms
  ];
  cfg = sys.config;
  pkgNames = builtins.map (p: p.pname or p.name or "") cfg.environment.systemPackages;
in
lib.runTests {
  testDiscordWrapperInstalled = {
    expr = builtins.elem "discord" pkgNames;
    expected = true;
  };
  testDiscordIsWrapped = {
    expr = lib.hasInfix "ozone-platform=wayland"
      (lib.findFirst (p: (p.pname or p.name or "") == "discord") null cfg.environment.systemPackages).buildCommand;
    expected = true;
  };
  testTelegramInstalledUnwrapped = {
    expr = builtins.elem "telegram-desktop" pkgNames;
    expected = true;
  };
}
