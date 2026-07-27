{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.gpu;
in {
  options.custom.system.gpu = {
    enable = lib.mkEnableOption "AMD GPU with Vulkan and VA-API";
  };

  config = lib.mkIf cfg.enable {
    # Load amdgpu kernel driver early for KMS
    boot.initrd.kernelModules = [ "amdgpu" ];

    # Enable OpenGL/Vulkan via Mesa and 32-bit support for Steam/Proton
    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        # VA-API hardware video acceleration
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # Wayland environment variables for hardware-accelerated rendering
    environment.sessionVariables = {
      WLR_RENDERER = "vulkan";
      __GLX_VENDOR_LIBRARY_NAME = "mesa";
    };
  };
}
