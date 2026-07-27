# ─── Configuration ───────────────────────────────────────
$env.config = {
    show_banner: false
    table: {
        mode: rounded
    }
    history: {
        max_size: 10000
        file_format: "sqlite"
    }
    completions: {
        case_sensitive: false
        partial: true
    }
    rm: {
        always_trash: true
    }
    edit_mode: emacs
}

# ─── Environment Variables ───────────────────────────────
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.MOZ_ENABLE_WAYLAND = "1"
$env.NIXOS_OZONE_WL = "1"
$env.XDG_CONFIG_HOME = ($env | get -i XDG_CONFIG_HOME | default $"($env.HOME)/.config")
$env.XDG_DATA_HOME = ($env | get -i XDG_DATA_HOME | default $"($env.HOME)/.local/share")
$env.XDG_STATE_HOME = ($env | get -i XDG_STATE_HOME | default $"($env.HOME)/.local/state")
$env.XDG_CACHE_HOME = ($env | get -i XDG_CACHE_HOME | default $"($env.HOME)/.cache")

# ─── PATH ────────────────────────────────────────────────
let local_bin = $"($env.HOME)/.local/bin"
if ($local_bin | path exists) {
    $env.PATH = ($env.PATH | prepend $local_bin)
}

# ─── Aliases (git) ──────────────────────────────────────
alias gs = git status
alias ga = git add
alias gc = git commit
alias gp = git push
alias gl = git log --oneline --graph
alias gd = git diff
alias gco = git checkout

# ─── Aliases (nix) ──────────────────────────────────────
alias nrs = sudo nixos-rebuild switch --flake .
alias nrt = sudo nixos-rebuild test --flake .
alias hms = home-manager switch --flake .

# ─── Aliases (files) ────────────────────────────────────
alias ll = ls -la
alias la = ls -a
alias md = mkdir -p

# ─── Tool Integrations ──────────────────────────────────
# Starship prompt
if (which starship | is-not-empty) {
    mkdir ($nu.default-config-dir | path join "starship")
    starship init nu | save -f ($nu.default-config-dir | path join "starship" "init.nu")
    source ($nu.default-config-dir | path join "starship" "init.nu")
}

# Direnv
if (which direnv | is-not-empty) {
    $env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {||
        let direnv = (direnv export json | from json | default {})
        if ($direnv | is-not-empty) {
            $direnv | load-env
        }
    })
}
