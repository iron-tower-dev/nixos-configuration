{ ... }: {
  config = {
    networking.networkmanager.enable = true;
    networking.dhcpcd.enable = false;
    networking.useNetworkd = false;
    services.resolved.enable = true;
  };
}
