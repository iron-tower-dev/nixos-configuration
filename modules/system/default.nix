{ ... }: {
  imports = [
    ./boot.nix
    ./gpu.nix
    ./audio.nix
    ./networking.nix
    ./bluetooth.nix
    ./gaming.nix
    ./virtualization.nix
    ./containers.nix
    ./snapshots.nix
    ./login.nix
    ./wayland.nix
    ./nix-settings.nix
    ./locale.nix
  ];
}
