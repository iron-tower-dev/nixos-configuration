{ config, lib, pkgs, ... }:
let
  cfg = config.custom.base.users;
in
{
  options.custom.base.users = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "ds";
      description = "Primary user account name.";
    };
    description = lib.mkOption {
      type = lib.types.str;
      default = "Derrick Southworth";
    };
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wheel" "networkmanager" ];
    };
  };

  config = {
    users.users.${cfg.name} = {
      isNormalUser = true;
      description = cfg.description;
      extraGroups = cfg.extraGroups;
      shell = pkgs.fish;
    };

    programs.fish.enable = true;
  };
}
