# dots: commit dotfiles only when home and the chezmoi repo agree, so no edit
# is left un-captured for a later `chezmoi apply` to overwrite.
#   dots          check + show what would be committed (changes nothing)
#   dots "msg"    same check, then commit and push

# Folders where every file should be tracked (status alone misses new files there).
typeset -ga DOTS_WATCH=(~/.config/nvim ~/.config/uwsm ~/.config/zsh)

dots() {
  local st df um
  st=$(chezmoi status)
  df=$(chezmoi --no-pager diff)
  um=$(chezmoi unmanaged "${DOTS_WATCH[@]}")

  if [[ -n $st || -n $df || -n $um ]]; then
    print "dots: home and repo disagree; nothing committed."
    [[ -n $st ]] && print "\nchanged (M -> chezmoi re-add, D -> chezmoi forget ~/<path>):\n$st"
    [[ -n $um ]] && print "\nuntracked (-> chezmoi add <path>):\n$um"
    [[ -n $df && -z $st ]] && print "\nchezmoi diff is not empty; inspect with: chezmoi diff"
    return 1
  fi

  if [[ -z $(chezmoi git -- status --porcelain) ]]; then
    print "dots: in sync, nothing to commit."
    return 0
  fi

  chezmoi git -- status --short
  if [[ -z $1 ]]; then
    print "\ndots: clean. Review the list above, then: dots \"message\""
    return 0
  fi

  chezmoi git -- add -A &&
    chezmoi git -- commit -m "$1" &&
    chezmoi git -- push &&
    chezmoi git -- status -sb | head -1
}
