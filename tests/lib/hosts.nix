# Run: nix eval --impure --file tests/lib/hosts.nix
# Pass = empty list. Non-empty = failing cases, each naming the test and showing result vs expected.
{ lib ? (import <nixpkgs> { }).lib }:
let
  hosts = import ../../lib/hosts.nix;
in
lib.runTests {
  testGantryIsDev = {
    expr = hosts.gantry.isDev;
    expected = true;
  };
  testGantryIsGaming = {
    expr = hosts.gantry.isGaming;
    expected = true;
  };
  testGantryIsServer = {
    expr = hosts.gantry.isServer;
    expected = false;
  };
  testGantryGpuDriver = {
    expr = hosts.gantry.gpu.driver;
    expected = "amd";
  };
  testGantryDiskNotEncrypted = {
    expr = hosts.gantry.disk.encrypted;
    expected = false;
  };
  testGantryPowerTlpDisabled = {
    expr = hosts.gantry.power.tlp;
    expected = false;
  };

  testMastIsDev = {
    expr = hosts.mast.isDev;
    expected = true;
  };
  testMastIsGaming = {
    expr = hosts.mast.isGaming;
    expected = true;
  };
  testMastIsServer = {
    expr = hosts.mast.isServer;
    expected = false;
  };
  testMastGpuDriver = {
    expr = hosts.mast.gpu.driver;
    expected = "nvidia-hybrid";
  };
  testMastDiskEncrypted = {
    expr = hosts.mast.disk.encrypted;
    expected = true;
  };
  testMastPowerTlpEnabled = {
    expr = hosts.mast.power.tlp;
    expected = true;
  };
}
