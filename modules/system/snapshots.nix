{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.snapshots;
in {
  options.custom.system.snapshots = {
    enable = lib.mkEnableOption "btrfs snapshot management via snapper";

    retention.hourly = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Number of hourly snapshots to retain.";
    };

    retention.daily = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "Number of daily snapshots to retain.";
    };

    retention.weekly = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Number of weekly snapshots to retain.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Configure snapper for automatic btrfs snapshot management
    services.snapper = {
      snapshotInterval = "hourly";
      cleanupInterval = "1d";

      configs.root = {
        SUBVOLUME = "/";
        ALLOW_USERS = [ "ds" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = toString cfg.retention.hourly;
        TIMELINE_LIMIT_DAILY = toString cfg.retention.daily;
        TIMELINE_LIMIT_WEEKLY = toString cfg.retention.weekly;
      };
    };
  };
}
