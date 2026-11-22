# █░█ █▀▀ █▀█ █▀█ █ █▀▀
# █▀█ ██▄ █▀▄ █▄█ █ █▄▄
#
# Why: installed games from the other stores, through Heroic (Epic via
# Legendary, GOG, Amazon via Nile) plus games added to Heroic by hand
# ("sideloaded"). Read-only: Heroic's own JSON files, no network. Launching
# goes back through Heroic (heroic://launch/<runner>/<app>), so its Wine/Proton
# setup, cloud saves and pre/post scripts all still apply.
# File layout as read by Cartridges' Heroic importer (Heroic >= 2.9):
#   store_cache/{legendary,gog,nile}_library.json   titles, runner, art_square
#   legendaryConfig/legendary/installed.json         Epic: {app_name: {...}}
#   gog_store/installed.json                         GOG:  {"installed": [{appName}]}
#   nile_config/nile/installed.json                  Amazon: [{id}]
#   sideload_apps/library.json                       {"games": [...]}
#   store/config.json                                games.hidden: [{appName}]
#   images-cache/<sha256(art_square + params)>       cover, cached by Heroic
# Debug: python3 ~/.local/lib/gamelauncher/heroic.py

import json
from hashlib import sha256
from pathlib import Path

CONFIG_DIRS = [
    Path.home() / ".config/heroic",                                         # native (AUR)
    Path.home() / ".var/app/com.heroicgameslauncher.hgl/config/heroic",     # flatpak
]
NOT_GAMES = {"gog-redist"}      # GOG's shared redistributables entry


def _read(path):
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError):
        return None


def _installed(cfg):
    """app names Heroic has installed, per store."""
    epic = _read(cfg / "legendaryConfig/legendary/installed.json") or {}
    gog = (_read(cfg / "gog_store/installed.json") or {}).get("installed", [])
    nile = _read(cfg / "nile_config/nile/installed.json") or []
    return {
        "legendary": {k for k, v in epic.items() if not (isinstance(v, dict) and v.get("is_dlc"))},
        "gog": {g.get("appName") for g in gog if isinstance(g, dict)},
        "nile": {g.get("id") for g in nile if isinstance(g, dict)},
    }


def _cover(cfg, entry, params):
    art = entry.get("art_square") or ""
    if not art:
        return ""
    f = cfg / "images-cache" / sha256((art + params).encode()).hexdigest()
    return str(f) if f.is_file() else ""


def games():
    out = []
    for cfg in CONFIG_DIRS:
        if not cfg.is_dir():
            continue
        hidden = {g.get("appName") for g in
                  ((_read(cfg / "store/config.json") or {}).get("games", {}).get("hidden", []))}
        installed = _installed(cfg)
        # (library file, list key, store key or None for sideload, cover URL params)
        sources = [
            ("store_cache/legendary_library.json", "library", "legendary", "?h=400&resize=1&w=300"),
            ("store_cache/gog_library.json", "games", "gog", ""),
            ("store_cache/nile_library.json", "library", "nile", ""),
            ("sideload_apps/library.json", "games", None, ""),
        ]
        for rel, key, store, params in sources:
            data = _read(cfg / rel) or {}
            for e in data.get(key, []) if isinstance(data, dict) else []:
                app, runner = e.get("app_name"), e.get("runner") or store or "sideload"
                if not app or app in NOT_GAMES or app in hidden:
                    continue
                if store and app not in installed[store]:
                    continue
                if not store and e.get("is_installed") is False:
                    continue
                out.append({
                    "name": e.get("title") or app,
                    "backend": "heroic",
                    "icon": _cover(cfg, e, params),
                    "url": f"heroic://launch/{runner}/{app}",
                })
    return out


if __name__ == "__main__":
    print(json.dumps(games(), indent=2))
