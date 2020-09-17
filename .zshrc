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
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

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
