# █▄▀ █▀▀ █▄█ █▀
# █░█ ██▄ ░█░ ▄█
#
# Why: emacs-style line editing, and the keys that zsh leaves unbound.
# zsh picks vi mode by itself when $EDITOR/$VISUAL contains "vi" (nvim).
# In vi mode the Delete key's sequence (ESC [ 3 ~) is read as Esc (normal
# mode) followed by "~" (toggle case), which is why Delete capitalised the
# line instead of deleting.
bindkey -e

# Sequences come from terminfo where it knows them (kitty sets TERM=xterm-kitty).
bindkey "${terminfo[kdch1]:-^[[3~}" delete-char          # Delete
bindkey "${terminfo[khome]:-^[[H}"  beginning-of-line    # Home
bindkey "${terminfo[kend]:-^[[F}"   end-of-line          # End
bindkey '^[[1;5C' forward-word                           # Ctrl+Right
bindkey '^[[1;5D' backward-word                          # Ctrl+Left
bindkey '^[[3;5~' kill-word                              # Ctrl+Delete
bindkey '^H'      backward-kill-word                     # Ctrl+Backspace
