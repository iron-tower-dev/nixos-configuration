# ─── Greeting ────────────────────────────────────────────
set -g fish_greeting  # disable

# ─── Environment Variables ───────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx MOZ_ENABLE_WAYLAND 1
set -gx NIXOS_OZONE_WL 1
# XDG (only if not already set)
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME;   or set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME;  or set -gx XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME;  or set -gx XDG_CACHE_HOME $HOME/.cache

# ─── PATH ────────────────────────────────────────────────
test -d $HOME/.local/bin; and fish_add_path $HOME/.local/bin

# ─── SSH Agent ───────────────────────────────────────────
set -l ssh_sock "/run/user/(id -u)/ssh-agent.socket"  # systemd socket
test -S $ssh_sock; and set -gx SSH_AUTH_SOCK $ssh_sock

# ─── Vi Mode ────────────────────────────────────────────
fish_vi_key_bindings
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore

# ─── Abbreviations (git) ────────────────────────────────
abbr -a gs  git status
abbr -a ga  git add
abbr -a gc  git commit
abbr -a gp  git push
abbr -a gl  git log --oneline --graph
abbr -a gd  git diff
abbr -a gco git checkout

# ─── Abbreviations (nix) ────────────────────────────────
abbr -a nrs 'sudo nixos-rebuild switch --flake .'
abbr -a nrt 'sudo nixos-rebuild test --flake .'
abbr -a hms 'home-manager switch --flake .'

# ─── Abbreviations (files/nav) ──────────────────────────
abbr -a ll ls -la
abbr -a la ls -a
abbr -a md mkdir -p
abbr -a ..   cd ..
abbr -a ...  cd ../..
abbr -a .... cd ../../..

# ─── Tool Integrations ──────────────────────────────────
command -q direnv; and direnv hook fish | source
