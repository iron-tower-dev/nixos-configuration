# Run: nix eval --impure --file tests/modules/services/secrets.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-host.nix;
  sys = harness.evalHost [
    harness.inputs.sops-nix.nixosModules.sops
    (harness.nixosModuleFrom ../../../modules/services/secrets.nix "secrets")
  ];
  cfg = sys.config;
in
lib.runTests {
  # Derives the decryption key from the SSH host key rather than a separate
  # persisted secret — /etc/ssh is already on the impermanence persist list.
  testAgeKeyDerivesFromSshHostKey = {
    expr = cfg.sops.age.sshKeyPaths;
    expected = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # Decrypted secrets must never land on persistent storage.
  testSecretsDecryptToTmpfs = { expr = cfg.sops.useTmpfs; expected = true; };
}
