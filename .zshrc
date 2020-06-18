# Load Antigen

export ANTIGEN_LOG=/tmp/antigen.log

source ~/.antigen.zsh
antigen init ~/.antigenrc

export ZSH_THEME="random"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

export EDITOR="vim"

# vi style incremental search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward 

# Keep extended history on disk
export HISTSIZE=1000000
export SAVEHIST=10000

# Insert last work bind to Alt.
bindkey '\e.' insert-last-word

# Needed for TMUX/VIM/SAKURA
export TERM=xterm-256color

# Load (sub)dotfiles
for subdot in $(find $HOME -maxdepth 1 -name ".zshrc_*"); do
  source "$subdot"
done;
unset subdot;

# Source local extra (private) settings specific to machine if it exists
[ -e ~/.zsh.local ] && source ~/.zsh.local

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git  -g ""'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /home/mdeferran/bin/vault vault
