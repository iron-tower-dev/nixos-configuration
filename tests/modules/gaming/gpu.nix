# Run: nix eval --impure --file tests/modules/gaming/gpu.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  mkSys = driver: harness.evalHost [
    ../../../modules/gaming/gpu.nix
    { custom.gaming.gpu.driver = driver; }
  ];
  amd = (mkSys "amd").config;
  nvidia = (mkSys "nvidia").config;
  hybrid = (mkSys "nvidia-hybrid").config;
in
lib.runTests {
  # AMD (gantry)
  testAmdGraphicsEnabled = { expr = amd.hardware.graphics.enable; expected = true; };
  testAmdKernelModule = { expr = builtins.elem "amdgpu" amd.boot.initrd.kernelModules; expected = true; };
  testAmdSessionVendor = { expr = amd.environment.sessionVariables.__GLX_VENDOR_LIBRARY_NAME; expected = "mesa"; };
  testAmdNoNvidiaPrimeOffload = { expr = nvidia.hardware.nvidia.prime.offload.enable or false; expected = false; };

  # Plain NVIDIA (desktop, non-hybrid — carried forward, unused by either real host today)
  testNvidiaModesettingEnabled = { expr = nvidia.hardware.nvidia.modesetting.enable; expected = true; };
  testNvidiaGbmBackend = { expr = nvidia.environment.sessionVariables.GBM_BACKEND; expected = "nvidia-drm"; };
  testNvidiaNotHybrid = { expr = nvidia.hardware.nvidia.prime.offload.enable or false; expected = false; };

  # NVIDIA-hybrid / PRIME offload (mast)
  testHybridPrimeOffloadEnabled = { expr = hybrid.hardware.nvidia.prime.offload.enable; expected = true; };
  testHybridLoadsAmdKernelModule = { expr = builtins.elem "amdgpu" hybrid.boot.initrd.kernelModules; expected = true; };
  testHybridLoadsNvidiaKernelModule = { expr = builtins.elem "nvidia" hybrid.boot.initrd.kernelModules; expected = true; };
  testHybridGraphicsEnabled = { expr = hybrid.hardware.graphics.enable; expected = true; };
  testHybridPrimeRenderOffloadEnvVar = { expr = hybrid.environment.sessionVariables.__NV_PRIME_RENDER_OFFLOAD; expected = "1"; };
}
