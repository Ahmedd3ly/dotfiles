HISTFILE="$HOME/.local/state/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups share_history
setopt interactive_comments
autoload -Uz compinit && compinit
