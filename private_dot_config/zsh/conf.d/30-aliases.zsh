# ▄▀█ █░░ █ ▄▀█ █▀
# █▀█ █▄▄ █ █▀█ ▄█
#
# Why: short names for tools I use daily. Core commands are not shadowed
# (no cat=bat, df=duf): muscle memory keeps working on servers and in a
# plain tty, and `command ls` is never needed. ls -> eza is the exception,
# because eza is a drop-in that only changes the look.
# Fuzzy finding comes from `fzf --zsh` (90-init): Ctrl-T files, Alt-C cd,
# Ctrl-R history; that covers HyDE's ffe/ffcd/ffch functions.

alias ls='eza --icons=auto --group-directories-first'
alias ll='ls -lh --git'          # long, human sizes, git status column
alias la='ll -a'                 # + dotfiles
alias lt='ls --tree --level=2'   # tree, two levels; `lt --level=4` for deeper
alias ff='clear; fastfetch'      # showcase; config in ~/.config/fastfetch
