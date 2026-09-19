{ ... }:
let
  moduleBody = { lib, ... }: {
    options.custom.host = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        The active host's role record from lib/hosts.nix (isDev, isGaming,
        isServer, gpu.driver, disk.encrypted, power.tlp), set once per host
        in that host's default.nix. Other modules gate subtrees on this
        (e.g. lib.mkIf config.custom.host.isGaming) rather than hardcoding
        per-host behavior.
      '';
    };
  };
in
{
  flake.nixosModules.host = moduleBody;
}
