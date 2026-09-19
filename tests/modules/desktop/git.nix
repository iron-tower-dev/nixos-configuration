# Run: nix eval --impure --file tests/modules/desktop/git.nix --apply "f: f {}"
{ lib ? (import <nixpkgs> { }).lib }:
let
  harness = import ../../support/eval-home.nix;
  hm = harness.evalHome [ (harness.homeModuleFrom ../../../modules/desktop/git.nix "git") ];
  cfg = hm.config;
in
lib.runTests {
  testGitEnabled = { expr = cfg.programs.git.enable; expected = true; };
  testGitUserName = { expr = cfg.programs.git.settings.user.name; expected = "Derrick Southworth"; };
  testGitUserEmail = { expr = cfg.programs.git.settings.user.email; expected = "derricksouthworth@gmail.com"; };
  testGitDefaultBranch = { expr = cfg.programs.git.settings.init.defaultBranch; expected = "main"; };
  testGitPullRebase = { expr = cfg.programs.git.settings.pull.rebase; expected = true; };
  testGitEditorIsNvim = { expr = cfg.programs.git.settings.core.editor; expected = "nvim"; };

  testGithubSshHost = { expr = cfg.programs.ssh.settings."github.com".data.HostName; expected = "github.com"; };
  testGithubSshKey = { expr = cfg.programs.ssh.settings."github.com".data.IdentityFile; expected = "~/.ssh/id_ed25519"; };
  testSshAddKeysToAgent = { expr = cfg.programs.ssh.settings."*".data.AddKeysToAgent; expected = "yes"; };
  testSshAgentServiceEnabled = { expr = cfg.services.ssh-agent.enable; expected = true; };
}
