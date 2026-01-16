# Modern ZSH configuration for Ubuntu 24.04/25.04

# Load Antigen plugin manager
export ANTIGEN_LOG=/tmp/antigen.log
source ~/.antigen.zsh
antigen init ~/.antigenrc

# ZSH settings
export ZSH_THEME="random"
export DISABLE_MAGIC_FUNCTIONS="true"
ENABLE_CORRECTION="true"

# export EDITOR="vim"
export EDITOR="nvim"
export VISUAL="nvim"

# vi style incremental search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '\e.' insert-last-word

# Extended history configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat '!' specially during expansion
setopt EXTENDED_HISTORY          # Write history in ":start:elapsed;command" format
setopt INC_APPEND_HISTORY        # Write to history file immediately
setopt SHARE_HISTORY             # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS      # Delete old entry if new is duplicate
setopt HIST_FIND_NO_DUPS         # Don't display previously found line
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording
setopt HIST_VERIFY               # Don't execute immediately upon expansion
setopt HIST_BEEP                 # Beep when accessing nonexistent history

# Terminal settings for modern terminals (Ghostty, tmux, etc.)
export TERM=xterm-256color

# Load modular configurations
for subdot in $HOME/.zshrc_*(N); do
  source "$subdot"
done

# Source local machine-specific settings if present
[ -e ~/.zsh.local ] && source ~/.zsh.local

# FZF integration with modern tools
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif command -v rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
fi

# Kubernetes completions and aliases (if installed)
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
  alias k=kubectl
  alias ks='k apply -f - << EOF'
fi

# Bash completion support
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /home/mdeferran/bin/vault vault

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
alias k=kubectl
alias ks='k apply -f - << EOF'
