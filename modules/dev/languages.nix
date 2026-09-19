{ pkgs, lib, ... }: {
  config = {
    home.packages = with pkgs; [
      # Rust toolchain via rustup (provides rustc, cargo, clippy, rustfmt)
      rustup

      # Go
      go
      gopls

      # .NET
      dotnet-sdk_8
      omnisharp-roslyn

      # Node.js LTS + fnm version manager
      nodejs_22
      fnm

      # Deno and Bun — coexist alongside fnm-managed Node
      deno
      bun

      # Python via uv (no system-wide pip)
      uv

      # Elixir (beamPackages.* — top-level elixir/erlang are deprecated)
      beamPackages.elixir
      beamPackages.erlang
      elixir-ls

      # Gleam
      gleam

      # Java + Kotlin share the JVM build tooling
      jdk21
      maven
      gradle
      kotlin

      # Kubernetes learning tooling — local clusters only, no real infra
      kubectl
      k9s
      kind

      # JetBrains Rider — backup C#/.NET IDE
      jetbrains.rider
    ];

    programs.fish.interactiveShellInit = lib.mkAfter ''
      fnm env --use-on-cd --shell fish | source
    '';

    programs.zsh.initContent = lib.mkAfter ''
      eval "$(fnm env --use-on-cd --shell zsh)"
    '';

    programs.nushell.extraConfig = lib.mkAfter ''
      fnm env --use-on-cd --shell nu | save -f ~/.cache/fnm-env.nu
      source ~/.cache/fnm-env.nu
    '';
  };
}
