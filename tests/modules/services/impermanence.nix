# Run: nix eval --impure --file tests/modules/services/impermanence.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [
    harness.inputs.impermanence.nixosModules.impermanence
    ../../../modules/services/impermanence.nix
  ];
  cfg = sys.config;

  sysExtended = harness.evalHost [
    harness.inputs.impermanence.nixosModules.impermanence
    ../../../modules/services/impermanence.nix
    { custom.services.impermanence.directories = [ "/home/ds/Documents" ]; }
  ];

  hasDir = path: dirs: builtins.any (d: d.directory == path) dirs;
in
lib.runTests {
  testRootIsTmpfs = { expr = cfg.fileSystems."/".fsType; expected = "tmpfs"; };

  testPersistHidesMounts = { expr = cfg.environment.persistence."/persist".hideMounts; expected = true; };

  testSshHostKeysPersisted = {
    expr = hasDir "/etc/ssh" cfg.environment.persistence."/persist".directories;
    expected = true;
  };
  testNetworkManagerConnectionsPersisted = {
    expr = hasDir "/etc/NetworkManager/system-connections" cfg.environment.persistence."/persist".directories;
    expected = true;
  };
  testBluetoothPairingPersisted = {
    expr = hasDir "/var/lib/bluetooth" cfg.environment.persistence."/persist".directories;
    expected = true;
  };

  # Host-specific modules can add more persisted paths without clobbering the base list.
  testHostCanExtendPersistList = {
    expr = hasDir "/home/ds/Documents" sysExtended.config.environment.persistence."/persist".directories;
    expected = true;
  };
  testExtendingStillKeepsBaseList = {
    expr = hasDir "/etc/ssh" sysExtended.config.environment.persistence."/persist".directories;
    expected = true;
  };

  # /etc/ssh etc. bind-mount from /persist before regular fstab processing —
  # without this, NixOS's own activation assertion fails the build.
  testPersistNeededForBoot = {
    expr = cfg.fileSystems."/persist".neededForBoot;
    expected = true;
  };

  # Without this, uid/gid allocations for users/groups lacking an explicit
  # id (e.g. the primary user) get reassigned every boot, scrambling file
  # ownership on anything already in /persist.
  testNixosStateDirPersisted = {
    expr = hasDir "/var/lib/nixos" cfg.environment.persistence."/persist".directories;
    expected = true;
  };
}
