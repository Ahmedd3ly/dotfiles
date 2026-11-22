# █▀ ▀█▀ █▀▀ ▄▀█ █▀▄▀█
# ▄█ ░█░ ██▄ █▀█ █░▀░█
#
# Why: installed Steam games for gamelauncher. Reads every library listed in
# libraryfolders.vdf (so /games/SteamLibrary is found), one appmanifest per
# game, and the portrait cover Steam already cached locally. Standard library
# only (HyDE's version needed requests in its own venv).
# Debug: python3 ~/.local/lib/gamelauncher/steam.py

import re
from pathlib import Path

HOME = Path.home()
STEAM_ROOTS = [
    HOME / ".local/share/Steam",                                        # native (Arch)
    HOME / ".var/app/com.valvesoftware.Steam/.local/share/Steam",       # flatpak
]
# Tools that have appmanifests but aren't games.
NOT_GAMES = re.compile(r"(?i)\b(proton|steam linux runtime|steamworks|redistributable)")
# Best cover for a portrait grid first; Steam keeps these per app in
# appcache/librarycache/<appid>/ (older flat layout) or a hashed subfolder.
COVER_NAMES = ["library_600x900.jpg", "library_capsule.jpg", "library_hero.jpg", "header.jpg"]


def _libraries():
    """steamapps folders of every library Steam knows about."""
    seen, out = set(), []
    for root in STEAM_ROOTS:
        vdf = root / "steamapps" / "libraryfolders.vdf"
        paths = [root]
        if vdf.is_file():
            paths += [Path(p) for p in re.findall(r'"path"\s*"([^"]+)"', vdf.read_text(errors="ignore"))]
        for p in paths:
            apps = (p / "steamapps").resolve()
            if apps.is_dir() and apps not in seen:
                seen.add(apps)
                out.append(apps)
    return out


def _cover(appid):
    for root in STEAM_ROOTS:
        d = root / "appcache" / "librarycache" / str(appid)
        if not d.is_dir():
            continue
        dirs = [d] + sorted(x for x in d.iterdir() if x.is_dir())
        for name in COVER_NAMES:               # best name first, across layouts
            for folder in dirs:
                if (folder / name).is_file():
                    return str(folder / name)
    return ""


def games():
    out = []
    for apps in _libraries():
        for acf in apps.glob("appmanifest_*.acf"):
            txt = acf.read_text(errors="ignore")
            appid = re.search(r'"appid"\s*"(\d+)"', txt)
            name = re.search(r'"name"\s*"([^"]+)"', txt)
            if not appid or not name or NOT_GAMES.search(name.group(1)):
                continue
            out.append({
                "name": name.group(1),
                "backend": "steam",
                "icon": _cover(appid.group(1)),
                "url": f"steam://rungameid/{appid.group(1)}",
            })
    return out


if __name__ == "__main__":
    import json
    print(json.dumps(games(), indent=2))
