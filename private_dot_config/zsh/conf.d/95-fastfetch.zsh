# Greeting: fastfetch on every new interactive shell, like HyDE.
# Last in conf.d so the prompt setup is done; costs a few tens of ms per shell.
[[ -o interactive ]] && command -v fastfetch >/dev/null && fastfetch
