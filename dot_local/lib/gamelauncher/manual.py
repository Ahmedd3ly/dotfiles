# █▀▄▀█ ▄▀█ █▄░█ █░█ ▄▀█ █░░
# █░▀░█ █▀█ █░▀█ █▄█ █▀█ █▄▄
#
# Why: portable / manually installed games (SuperTuxKart and friends): each
# top-level folder under /games is a candidate. Launch target, first match:
#   1. ".gamelauncher.json" in the folder: {"run": "<shell command>"} for
#      anything non-trivial (Wine prefixes, env vars), or {"exec": "path"}.
#      (A legacy launch.json {"run_command": ...} is still read.)
#   2. a wrapper script at the top: run_game.sh, start.sh, launch.sh, run.sh, play.sh
#   3. an executable up to 2 levels deep: in a bin/ folder first, then the one
#      whose name best matches the folder; installers/uninstallers excluded.
# The same file can set "name" and "icon", or {"skip": true} to hide a folder
# (a game Heroic or Steam already lists).
# Not games: dot folders, lost+found, Steam libraries (steamapps inside),
# Heroic's install and prefix roots.
# Debug: python3 ~/.local/lib/gamelauncher/manual.py [root]

import json
import os
import re
from pathlib import Path

ROOT = Path("/games")
MANIFEST = ".gamelauncher.json"
LEGACY_MANIFEST = "launch.json"
NOT_GAME_DIRS = {"SteamLibrary", "Heroic", "Prefixes", "lost+found"}
SCRIPTS = ["run_game.sh", "start.sh", "launch.sh", "run.sh", "play.sh"]
NOT_EXEC_EXT = {".so", ".sh", ".py", ".pl", ".dll", ".dylib", ".a", ".o"}
NOT_EXEC_NAME = re.compile(
    r"(?i)setup|^install|^unins|redist|directx|^dotnet|crashreport|^activation")
ICON_EXT = {".png", ".svg", ".jpg", ".jpeg", ".xpm", ".ico"}
DEPTH = 2


def _read(path):
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError):
        return {}


def _files(base):
    """Files up to DEPTH folders below base."""
    for dirpath, dirnames, filenames in os.walk(base):
        if len(Path(dirpath).relative_to(base).parts) >= DEPTH:
            dirnames[:] = []
        for f in filenames:
            yield Path(dirpath) / f


def _likeness(a, b):
    a, b = (re.sub(r"[^a-z0-9]", "", s.lower()) for s in (a, b))
    if not a or not b:
        return 0
    if a == b:
        return 100
    if a in b or b in a:
        return 50
    return len(os.path.commonprefix([a, b]))


def _executable(folder):
    for s in SCRIPTS:
        if (folder / s).is_file():
            return folder / s
    found = [f for f in _files(folder)
             if f.suffix.lower() not in NOT_EXEC_EXT and not NOT_EXEC_NAME.search(f.stem)
             and f.is_file() and os.access(f, os.X_OK)]
    found.sort(key=lambda f: ("bin" in f.relative_to(folder).parts[:-1],
                              _likeness(f.stem, folder.name)), reverse=True)
    return found[0] if found else None


def _icon(folder):
    # Largest size in the name wins (foo_256.png over foo_32.png).
    found = [f for f in _files(folder) if f.suffix.lower() in ICON_EXT]
    size = lambda f: int(m.group(1)) if (m := re.search(r"(\d{2,4})$", f.stem)) else 0
    return max(found, key=size) if found else None


def games(root=ROOT):
    out = []
    if not root.is_dir():
        return out
    for folder in sorted(root.iterdir()):
        if (not folder.is_dir() or folder.name.startswith(".") or folder.name in NOT_GAME_DIRS
                or (folder / "steamapps").is_dir()):
            continue
        meta = _read(folder / MANIFEST)
        if meta.get("skip") is True:
            continue
        rel = lambda v: Path(v) if Path(v).is_absolute() else folder / v
        entry = {"name": meta.get("name") or folder.name, "backend": "manual", "cwd": str(folder)}
        run = meta.get("run") or _read(folder / LEGACY_MANIFEST).get("run_command")
        if run:
            entry["shell"] = run
        else:
            exe = rel(meta["exec"]) if "exec" in meta else _executable(folder)
            if not exe or not exe.is_file():
                continue
            # A script copied between disks often loses its executable bit.
            entry["argv"] = [str(exe)] if os.access(exe, os.X_OK) else ["sh", str(exe)]
        icon = rel(meta["icon"]) if "icon" in meta else _icon(folder)
        entry["icon"] = str(icon) if icon and icon.is_file() else ""
        out.append(entry)
    return out


if __name__ == "__main__":
    import sys
    print(json.dumps(games(Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT), indent=2))
