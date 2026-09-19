# Run: nix eval --impure --file tests/modules/dev/languages.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ ../../../modules/dev/languages.nix ];
  cfg = hm.config;
  hasPname = name: pkgs: builtins.any (p: (p.pname or p.name or "") == name) pkgs;
in
lib.runTests {
  # Existing carryover
  testRustupInstalled = { expr = hasPname "rustup" cfg.home.packages; expected = true; };
  testGoInstalled = { expr = hasPname "go" cfg.home.packages; expected = true; };
  testDotnetSdkInstalled = { expr = hasPname "dotnet-sdk" cfg.home.packages; expected = true; };
  testNodeInstalled = { expr = hasPname "nodejs" cfg.home.packages; expected = true; };
  testFnmInstalled = { expr = hasPname "fnm" cfg.home.packages; expected = true; };
  testElixirInstalled = { expr = hasPname "elixir" cfg.home.packages; expected = true; };
  testGleamInstalled = { expr = hasPname "gleam" cfg.home.packages; expected = true; };
  testRiderInstalled = { expr = hasPname "rider" cfg.home.packages; expected = true; };
  testFnmFishIntegration = {
    expr = lib.hasInfix "fnm env" cfg.programs.fish.interactiveShellInit;
    expected = true;
  };
  testFnmZshIntegration = {
    expr = lib.hasInfix "fnm env" cfg.programs.zsh.initContent;
    expected = true;
  };

  # New additions (Phase 1 grilling round 1, Q6)
  testDenoInstalled = { expr = hasPname "deno" cfg.home.packages; expected = true; };
  testBunInstalled = { expr = hasPname "bun" cfg.home.packages; expected = true; };
  testUvInstalled = { expr = hasPname "uv" cfg.home.packages; expected = true; };
  testJdkInstalled = { expr = hasPname "openjdk" cfg.home.packages; expected = true; };
  testMavenInstalled = { expr = hasPname "maven" cfg.home.packages; expected = true; };
  testGradleInstalled = { expr = hasPname "gradle" cfg.home.packages; expected = true; };
  testKotlinInstalled = { expr = hasPname "kotlin" cfg.home.packages; expected = true; };
  testKubectlInstalled = { expr = hasPname "kubectl" cfg.home.packages; expected = true; };
  testK9sInstalled = { expr = hasPname "k9s" cfg.home.packages; expected = true; };
  testKindInstalled = { expr = hasPname "kind" cfg.home.packages; expected = true; };
}
