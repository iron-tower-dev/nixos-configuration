{ ... }:
let
  moduleBody = { config, lib, pkgs, ... }:
    let
      gpuCfg = config.custom.gaming.gpu;
    in
    {
      config = lib.mkIf config.custom.host.isGaming {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };

        programs.gamemode.enable = true;

        environment.systemPackages = with pkgs; [
          lutris
          heroic
          protonup-qt
          mangohud
        ];

        boot.kernel.sysctl."vm.max_map_count" = 2147483642;

        security.pam.loginLimits = [
          { domain = "*"; type = "hard"; item = "nofile"; value = "524288"; }
          { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
        ];

        environment.sessionVariables = lib.mkIf (gpuCfg.driver == "amd") {
          AMD_VULKAN_ICD = "RADV";
        };
      };
    };
in
{
  flake.nixosModules.steam = moduleBody;
}
