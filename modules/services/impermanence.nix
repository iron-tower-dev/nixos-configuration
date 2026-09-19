{ ... }:
let
  moduleBody = { config, lib, ... }:
    let
      cfg = config.custom.services.impermanence;
      userName = config.custom.base.users.name;
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

        # Same additive pattern, but for paths under the user's own home
        # directory (relative to $HOME) rather than system-wide state.
        userDirectories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra $HOME-relative directories bind-mounted from /persist, beyond the always-persisted base set (SSH keys, Steam library, Firefox profile).";
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

        # /etc/ssh and friends bind-mount from here before regular fstab
        # processing, so /persist itself must be available at that point.
        fileSystems."/persist".neededForBoot = true;

        environment.persistence."/persist" = {
          hideMounts = true;
          directories = [
            "/etc/ssh" # host keys — also what sops-nix's per-host age key derives from
            "/etc/NetworkManager/system-connections"
            "/var/lib/bluetooth"
            "/var/lib/nixos" # uid/gid allocations — without this, ids get reassigned every boot
          ] ++ cfg.directories;
          files = cfg.files;

          users.${userName}.directories = [
            ".ssh" # user SSH keys — git.nix's ~/.ssh/id_ed25519 identity depends on this
            ".local/share/Steam" # Steam library and game saves
            ".mozilla" # Firefox profile — bookmarks, saved logins, browsing data
            ".local/state" # XDG state home — e.g. theming.nix's active-theme file
            "Pictures" # clipboard.nix's screenshot script writes real files here
            ".config/wallpapers" # user-managed wallpaper images, not Nix-store-sourced
          ] ++ cfg.userDirectories;
        };
      };
    };
in
{
  flake.nixosModules.impermanence = moduleBody;
}
