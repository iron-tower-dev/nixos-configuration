{ lib }: {
  # Looks up a role flag on a host record from lib/hosts.nix, defaulting to
  # false for roles a host doesn't declare (rather than erroring).
  hasRole = hostCfg: role: hostCfg.${role} or false;

  # Asserts a file exists at build time (for Config_Source validation).
  assertFileExists = path: message:
    assert builtins.pathExists path || throw message; path;
}
