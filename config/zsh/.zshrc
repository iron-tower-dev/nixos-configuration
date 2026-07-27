# ─── Completion ──────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# ─── History ─────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# ─── Options ─────────────────────────────────────────────
setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS

# ─── Key Bindings ────────────────────────────────────────
bindkey -e  # emacs mode

# ─── Environment Variables ───────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export MOZ_ENABLE_WAYLAND=1
export NIXOS_OZONE_WL=1
[[ -z "$XDG_CONFIG_HOME" ]] && export XDG_CONFIG_HOME="$HOME/.config"
[[ -z "$XDG_DATA_HOME" ]]   && export XDG_DATA_HOME="$HOME/.local/share"
[[ -z "$XDG_STATE_HOME" ]]  && export XDG_STATE_HOME="$HOME/.local/state"
[[ -z "$XDG_CACHE_HOME" ]]  && export XDG_CACHE_HOME="$HOME/.cache"

# ─── PATH ────────────────────────────────────────────────
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# ─── SSH Agent ───────────────────────────────────────────
_ssh_sock="/run/user/$(id -u)/ssh-agent.socket"
[[ -S "$_ssh_sock" ]] && export SSH_AUTH_SOCK="$_ssh_sock"

# ─── Aliases (git) ──────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'
alias gco='git checkout'

# ─── Aliases (nix) ──────────────────────────────────────
alias nrs='sudo nixos-rebuild switch --flake .'
alias nrt='sudo nixos-rebuild test --flake .'
alias hms='home-manager switch --flake .'

# ─── Aliases (files) ────────────────────────────────────
alias ll='ls -la'
alias la='ls -a'
alias md='mkdir -p'

# ─── Tool Integrations ──────────────────────────────────
command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"
command -v starship &>/dev/null && eval "$(starship init zsh)"
