# Modern ZSH configuration for Ubuntu 24.04/25.04

# Enable zprof for detailed profiling: ZSHRC_PROFILE=1 zsh
if [[ $ZSHRC_PROFILE -eq 1 ]]; then
  zmodload zsh/zprof
fi

# Debug timing
ZSHRC_DEBUG=${ZSHRC_DEBUG:-0}
if [[ $ZSHRC_DEBUG -eq 1 ]]; then
  ZSHRC_START=$SECONDS
  echo "[DEBUG] Starting .zshrc at $ZSHRC_START"
fi

# Load Antigen plugin manager
export ANTIGEN_LOG=/tmp/antigen.log
if [[ $ZSHRC_DEBUG -eq 1 ]]; then
  echo "[DEBUG] Loading antigen at $SECONDS (elapsed: $((SECONDS - ZSHRC_START))s)"
  ANTIGEN_LOAD_START=$SECONDS
fi

source ~/.antigen.zsh

if [[ $ZSHRC_DEBUG -eq 1 ]]; then
  echo "[DEBUG] Antigen loaded in $((SECONDS - ANTIGEN_LOAD_START))s"
  echo "[DEBUG] Initializing antigen at $SECONDS (elapsed: $((SECONDS - ZSHRC_START))s)"
  ANTIGEN_INIT_START=$SECONDS
fi

antigen init ~/.antigenrc

if [[ $ZSHRC_DEBUG -eq 1 ]]; then
  echo "[DEBUG] Antigen init took $((SECONDS - ANTIGEN_INIT_START))s"
  echo "[DEBUG] Antigen done at $SECONDS (elapsed: $((SECONDS - ZSHRC_START))s)"
fi

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
[[ $ZSHRC_DEBUG -eq 1 ]] && echo "[DEBUG] Loading modular configs at $SECONDS (elapsed: $((SECONDS - ZSHRC_START))s)"
for subdot in $HOME/.zshrc_*(N); do
  [[ $ZSHRC_DEBUG -eq 1 ]] && echo "[DEBUG]   Loading $(basename $subdot)"
  source "$subdot"
done
[[ $ZSHRC_DEBUG -eq 1 ]] && echo "[DEBUG] Modular configs done at $SECONDS (elapsed: $((SECONDS - ZSHRC_START))s)"

# Source local machine-specific settings if present
[ -e ~/.zsh.local ] && source ~/.zsh.local

# FZF integration with modern tools
[[ $ZSHRC_DEBUG -eq 1 ]] && echo "[DEBUG] Loading FZF at $SECONDS (elapsed: $((SECONDS - ZSHRC_START))s)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif command -v rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
fi

# Kubernetes completions and aliases (if installed)
[[ $ZSHRC_DEBUG -eq 1 ]] && echo "[DEBUG] Loading kubectl completion at $SECONDS (elapsed: $((SECONDS - ZSHRC_START))s)"
if command -v kubectl &> /dev/null; then
  # Cache kubectl completion for faster shell startup
  # To regenerate cache after kubectl upgrade, run: kubectl-regen-completion
  KUBECTL_COMPLETION_CACHE="${HOME}/.kube/completion.zsh"
  if [ ! -f "$KUBECTL_COMPLETION_CACHE" ] || [ ! -s "$KUBECTL_COMPLETION_CACHE" ]; then
    mkdir -p "${HOME}/.kube"
    kubectl completion zsh > "$KUBECTL_COMPLETION_CACHE"
  fi
  source "$KUBECTL_COMPLETION_CACHE"

  # Helper function to regenerate kubectl completion cache
  kubectl-regen-completion() {
    echo "Regenerating kubectl completion cache..."
    mkdir -p "${HOME}/.kube"
    kubectl completion zsh > "${HOME}/.kube/completion.zsh"
    echo "Done! Restart your shell to use the new completion."
  }

  alias k=kubectl
  alias ks='k apply -f - << EOF'
fi
[[ $ZSHRC_DEBUG -eq 1 ]] && echo "[DEBUG] kubectl completion done at $SECONDS (elapsed: $((SECONDS - ZSHRC_START))s)"

# Bash completion support
autoload -U +X bashcompinit && bashcompinit

# Vault completion (if installed)
if command -v vault &> /dev/null; then
  complete -o nospace -C $(which vault) vault
fi

[[ $ZSHRC_DEBUG -eq 1 ]] && echo "[DEBUG] .zshrc complete at $SECONDS (total elapsed: $((SECONDS - ZSHRC_START))s)"

# Show zprof output if profiling enabled
if [[ $ZSHRC_PROFILE -eq 1 ]]; then
  zprof
fi
