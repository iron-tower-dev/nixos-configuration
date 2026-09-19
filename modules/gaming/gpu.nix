{ ... }:
let
  moduleBody = { config, lib, pkgs, ... }:
    let
      cfg = config.custom.gaming.gpu;
    in
    {
      options.custom.gaming.gpu = {
        driver = lib.mkOption {
          type = lib.types.enum [ "amd" "nvidia" "nvidia-hybrid" ];
          default = "amd";
          description = ''
            Which GPU driver mode to configure:
            - "amd": all-AMD desktop (gantry) — amdgpu kernel driver, RADV/Mesa.
            - "nvidia": desktop with a proprietary-driver NVIDIA GPU as the only GPU.
            - "nvidia-hybrid": laptop Optimus pairing (mast) — AMD iGPU +
              NVIDIA dGPU via hardware.nvidia.prime.offload.
          '';
        };

        prime.amdgpuBusId = lib.mkOption {
          type = lib.types.str;
          # Generic fallback only — any real nvidia-hybrid host should set its
          # own confirmed value (see hosts/mast/default.nix's override).
          default = "PCI:5:0:0";
          description = "AMD iGPU PCI bus ID for hardware.nvidia.prime (nvidia-hybrid only).";
        };

        prime.nvidiaBusId = lib.mkOption {
          type = lib.types.str;
          # Generic fallback only — any real nvidia-hybrid host should set its
          # own confirmed value (see hosts/mast/default.nix's override).
          default = "PCI:1:0:0";
          description = "NVIDIA dGPU PCI bus ID for hardware.nvidia.prime (nvidia-hybrid only).";
        };
      };

      config = lib.mkMerge [
        # Common to any GPU-accelerated host.
        {
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };
        }

        (lib.mkIf (cfg.driver == "amd") {
          boot.initrd.kernelModules = [ "amdgpu" ];

          hardware.graphics.extraPackages = with pkgs; [
            libva-vdpau-driver
            libvdpau-va-gl
          ];

          environment.sessionVariables = {
            WLR_RENDERER = "vulkan";
            __GLX_VENDOR_LIBRARY_NAME = "mesa";
          };
        })

        (lib.mkIf (cfg.driver == "nvidia") {
          boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

          services.xserver.videoDrivers = [ "nvidia" ];

          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = false;
            open = false;
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };

          environment.sessionVariables = {
            LIBVA_DRIVER_NAME = "nvidia";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            GBM_BACKEND = "nvidia-drm";
            WLR_NO_HARDWARE_CURSORS = "1";
            QSG_RHI_BACKEND = "opengl";
          };
        })

        (lib.mkIf (cfg.driver == "nvidia-hybrid") {
          boot.initrd.kernelModules = [ "amdgpu" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

          services.xserver.videoDrivers = [ "nvidia" ];

          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = true; # laptop — allow runtime power management
            open = false;
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;

            prime = {
              offload.enable = true;
              offload.enableOffloadCmd = true;
              amdgpuBusId = cfg.prime.amdgpuBusId;
              nvidiaBusId = cfg.prime.nvidiaBusId;
            };
          };

          environment.sessionVariables = {
            LIBVA_DRIVER_NAME = "nvidia";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            GBM_BACKEND = "nvidia-drm";
            WLR_NO_HARDWARE_CURSORS = "1";
            QSG_RHI_BACKEND = "opengl";
            __NV_PRIME_RENDER_OFFLOAD = "1";
          };
        })
      ];
    };
in
{
  flake.nixosModules.gpu = moduleBody;
}
