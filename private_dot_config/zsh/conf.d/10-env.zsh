export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# XDG: keep less's search history out of $HOME's root (~/.local/state exists).
export LESSHISTFILE="$HOME/.local/state/lesshst"
# NPM: keeps npm from creating ~/.npm
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
# .NET: keep ~/.dotnet and ~/.nuget out of $HOME; no telemetry
export DOTNET_CLI_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/dotnet"
export NUGET_PACKAGES="${XDG_CACHE_HOME:-$HOME/.cache}/NuGetPackages"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
path+=("$DOTNET_CLI_HOME/.dotnet/tools")
