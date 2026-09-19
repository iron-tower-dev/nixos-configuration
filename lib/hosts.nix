{
  gantry = {
    isDev = true;
    isGaming = true;
    isServer = false;
    gpu.driver = "amd";
    disk.encrypted = false;
    power.tlp = false;
  };

  mast = {
    isDev = true;
    isGaming = true;
    isServer = false;
    gpu.driver = "nvidia-hybrid";
    disk.encrypted = true;
    power.tlp = true;
  };
}
