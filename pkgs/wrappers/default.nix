{ pkgs }: {
  discord = import ./discord.nix { inherit pkgs; };
}
