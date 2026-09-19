{ config, lib, ... }:
let
  cfg = config.custom.services.impermanence;
in
{
  options.custom.services.impermanence = {
    # Additional host- or module-specific paths, on top of the always-persist
    # base list below. A plain-list `default` here would not merge with a
    # host's own list definition (NixOS drops the low-priority default once
    # any other module supplies a definition) — so the base list is instead
    # unconditionally part of `config`, and this option is purely additive.
    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra directories bind-mounted from /persist, beyond the always-persisted base set.";
    };

    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Individual files bind-mounted from /persist.";
    };
  };

  config = {
    # Root resets to empty on every boot — this is the impermanence mechanism
    # itself. /nix and /persist are real, durable btrfs subvolumes declared
    # separately per host in lib/disko-layout.nix.
    fileSystems."/" = {
      fsType = "tmpfs";
      options = [ "size=8G" "mode=755" ];
    };

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/ssh" # host keys — also what sops-nix's per-host age key derives from
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
      ] ++ cfg.directories;
      files = cfg.files;
    };
  };
}
