sysup() { sudo timeshift --create --comments "pre-upgrade $(date +%F)" && paru -Syu; }

# One-shot question to the AI engine (`ai -p`, engine in ~/.config/ai/agent).
# Pipe context in:  journalctl -b -p err | ask "which of these matter?"
ask() { ai -p "$*"; }
