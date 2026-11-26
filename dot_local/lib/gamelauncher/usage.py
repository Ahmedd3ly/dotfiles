# █░█ █▀ ▄▀█ █▀▀ █▀▀
# █▄█ ▄█ █▀█ █▄█ ██▄
#
# Why: rank the picker by how often you play, like rofi's drun history.
# Each launch bumps a counter keyed "backend:name" (stable across runs, and
# the same title in two stores keeps two counters). Sort: most launches
# first, ties by most recent, then alphabetical; never-played games keep
# the alphabetical order underneath.
# State: $XDG_STATE_HOME/gamelauncher/usage.json (history, not config).
# Reset: delete that file.

import json
import os
import time
from pathlib import Path

STATE = (
    Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state")
    / "gamelauncher/usage.json"
)


def _key(g):
    return f"{g['backend']}:{g['name']}"


def _load():
    try:
        data = json.loads(STATE.read_text())
        return data if isinstance(data, dict) else {}
    except (OSError, ValueError):
        return {}


def rank(games):
    """Sort games in place by usage, then name."""
    data = _load()

    def score(g):
        u = data.get(_key(g)) or {}
        return (-u.get("count", 0), -u.get("last", 0), g["name"].casefold())

    games.sort(key=score)


def record(g):
    """Count one launch. Written atomically so a crash can't truncate history."""
    data = _load()
    u = data.setdefault(_key(g), {})
    u["count"] = u.get("count", 0) + 1
    u["last"] = int(time.time())
    STATE.parent.mkdir(parents=True, exist_ok=True)
    tmp = STATE.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, indent=1, sort_keys=True))
    tmp.replace(STATE)
