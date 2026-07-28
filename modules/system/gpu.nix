{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.gpu;
in {
  options.custom.system.gpu = {
    enable = lib.mkEnableOption "GPU driver configuration";
    driver = lib.mkOption {
      type = lib.types.enum [ "amd" "nvidia" ];
      default = "amd";
      description = "Which GPU driver to configure (amd or nvidia)";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # ── Common (both drivers) ──────────────────────────────
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    }

    # ── AMD ────────────────────────────────────────────────
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

    # ── NVIDIA ─────────────────────────────────────────────
    (lib.mkIf (cfg.driver == "nvidia") {
      # Load nvidia kernel modules
      boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

      # Use the proprietary NVIDIA driver
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        open = false;  # use proprietary driver (open kernel module is experimental)
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      # Wayland/Hyprland environment variables for NVIDIA
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    })
  ]);
}
