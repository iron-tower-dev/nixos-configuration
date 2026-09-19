# Run: nix eval --impure --file tests/modules/gaming/steam.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  mkSys = driver: harness.evalHost [
    ../../../modules/gaming/gpu.nix
    ../../../modules/gaming/steam.nix
    { custom.gaming.gpu.driver = driver; }
  ];
  amd = (mkSys "amd").config;
  hybrid = (mkSys "nvidia-hybrid").config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  testSteamEnabled = { expr = amd.programs.steam.enable; expected = true; };
  testSteamRemotePlayFirewall = { expr = amd.programs.steam.remotePlay.openFirewall; expected = true; };
  testSteamDedicatedServerFirewall = { expr = amd.programs.steam.dedicatedServer.openFirewall; expected = true; };
  testGamemodeEnabled = { expr = amd.programs.gamemode.enable; expected = true; };

  testLutrisInstalled = { expr = hasPname "lutris" amd.environment.systemPackages; expected = true; };
  testHeroicInstalled = { expr = hasPname "heroic" amd.environment.systemPackages; expected = true; };
  testProtonUpQtInstalled = { expr = hasPname "protonup-qt" amd.environment.systemPackages; expected = true; };
  testMangohudInstalled = { expr = hasPname "mangohud" amd.environment.systemPackages; expected = true; };

  testKernelMaxMapCount = { expr = amd.boot.kernel.sysctl."vm.max_map_count"; expected = 2147483642; };
  testNofileHardLimit = {
    expr = builtins.any (l: l.domain == "*" && l.type == "hard" && l.item == "nofile" && l.value == "524288") amd.security.pam.loginLimits;
    expected = true;
  };

  testRadvEnvVarOnAmd = { expr = amd.environment.sessionVariables.AMD_VULKAN_ICD or null; expected = "RADV"; };
  testNoRadvEnvVarOnHybrid = { expr = hybrid.environment.sessionVariables.AMD_VULKAN_ICD or null; expected = null; };
}
