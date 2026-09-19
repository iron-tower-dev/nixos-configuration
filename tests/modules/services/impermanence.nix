# Run: nix eval --impure --file tests/modules/services/impermanence.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [
    harness.inputs.impermanence.nixosModules.impermanence
    (harness.nixosModuleFrom ../../../modules/base/users.nix "users")
    (harness.nixosModuleFrom ../../../modules/services/impermanence.nix "impermanence")
  ];
  cfg = sys.config;
  hasUserDir = path: dirs: builtins.any (d: d.directory == path) dirs;

  sysExtended = harness.evalHost [
    harness.inputs.impermanence.nixosModules.impermanence
    (harness.nixosModuleFrom ../../../modules/services/impermanence.nix "impermanence")
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

  # Without these, the user's actual data (not dotfiles-managed config,
  # which home-manager regenerates every activation) vanishes every boot.
  # .ssh in particular is what git.nix's ~/.ssh/id_ed25519 identity depends on.
  testUserSshKeysPersisted = {
    expr = hasUserDir ".ssh" cfg.environment.persistence."/persist".users.ds.directories;
    expected = true;
  };
  testSteamLibraryPersisted = {
    expr = hasUserDir ".local/share/Steam" cfg.environment.persistence."/persist".users.ds.directories;
    expected = true;
  };
  testFirefoxProfilePersisted = {
    expr = hasUserDir ".mozilla" cfg.environment.persistence."/persist".users.ds.directories;
    expected = true;
  };
  # Otherwise theming.nix's restoreTheme activation hook can never find a
  # state file to restore from -- it would always be a no-op.
  testXdgStateHomePersisted = {
    expr = hasUserDir ".local/state" cfg.environment.persistence."/persist".users.ds.directories;
    expected = true;
  };
  # clipboard.nix's screenshot script writes real image files here, not cache.
  testScreenshotsPersisted = {
    expr = hasUserDir "Pictures" cfg.environment.persistence."/persist".users.ds.directories;
    expected = true;
  };
  # hyprland-home.nix: wallpapers are placed here by hand, not managed by
  # Nix/home-manager -- the old repo's own comment already called this out
  # as "not symlinked from the store", which is exactly what impermanence
  # would otherwise wipe every boot.
  testWallpapersPersisted = {
    expr = hasUserDir ".config/wallpapers" cfg.environment.persistence."/persist".users.ds.directories;
    expected = true;
  };
}
