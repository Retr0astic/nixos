#!/usr/bin/env python3
"""Render the release notes for one flake.lock update.

Called by .github/workflows/flake-update.yml with the lock file from before
`nix flake update <input>` and the one from after it. Prints markdown on
stdout: one row per moved node, a compare link where the source is a forge
that has one, and the rebuild list that `nix build --dry-run` reported.

Standard library only. The runner has no other dependency installed.
"""

import argparse
import json
import os
import re
from datetime import datetime, timezone

STORE_PATH = re.compile(r"/nix/store/[a-z0-9]{32}-(?P<name>[^\s]+)")
# A package carries a version. The rest of a system closure is generation
# glue: activate, etc, home-manager-path, dummy-fc-dir1, and their like. The
# glue rebuilds on every generation and says nothing about the update.
VERSIONED = re.compile(r"-\d")
BUILD_CAP = 25


def load(path):
    with open(path, encoding="utf-8") as handle:
        return json.load(handle)


def root_inputs(lock):
    root = lock["nodes"][lock["root"]]
    names = {}
    for name, target in root.get("inputs", {}).items():
        # A `follows` entry is a list of path components, never a node key.
        if isinstance(target, str):
            names[target] = name
    return names


def short(rev):
    return rev[:9] if rev else "-"


def stamp(node):
    seconds = node.get("locked", {}).get("lastModified")
    if not seconds:
        return "-"
    return datetime.fromtimestamp(seconds, timezone.utc).strftime("%Y-%m-%d")


def source(node):
    """Return (label, compare_base) for one locked node."""
    locked = node.get("locked", {})
    kind = locked.get("type")
    owner = locked.get("owner")
    repo = locked.get("repo")
    if kind == "github" and owner and repo:
        return f"{owner}/{repo}", f"https://github.com/{owner}/{repo}"
    if kind == "gitlab" and owner and repo:
        return f"{owner}/{repo}", f"https://gitlab.com/{owner}/{repo}"
    url = locked.get("url", "")
    if kind == "git" and "github.com" in url:
        trimmed = url.split("github.com/", 1)[1].removesuffix(".git")
        return trimmed, f"https://github.com/{trimmed}"
    return locked.get("url") or kind or "-", None


def changes(old, new):
    """Every node whose revision or hash moved, newest first."""
    names = root_inputs(new)
    rows = []
    for key, node in new["nodes"].items():
        if key == new["root"]:
            continue
        before = old["nodes"].get(key)
        if before is None:
            rows.append((names.get(key, key), None, node))
            continue
        old_locked = before.get("locked", {})
        new_locked = node.get("locked", {})
        moved = old_locked.get("rev") != new_locked.get("rev")
        moved = moved or old_locked.get("narHash") != new_locked.get("narHash")
        if moved:
            rows.append((names.get(key, key), before, node))
    rows.sort(key=lambda row: (row[0] not in names, row[0]))
    return rows


def table(rows):
    lines = [
        "| Input | From | To | Locked | Source |",
        "| --- | --- | --- | --- | --- |",
    ]
    for name, before, node in rows:
        label, base = source(node)
        old_rev = before.get("locked", {}).get("rev") if before else None
        new_rev = node.get("locked", {}).get("rev")
        link = label
        if base and old_rev and new_rev:
            link = f"[{label}]({base}/compare/{old_rev}...{new_rev})"
        elif base:
            link = f"[{label}]({base})"
        lines.append(
            f"| `{name}` | `{short(old_rev)}` | `{short(new_rev)}` "
            f"| {stamp(node)} | {link} |"
        )
    return "\n".join(lines)


def rebuilds(path):
    """Package names from a `nix build --dry-run` log, build list first."""
    if not path or not os.path.exists(path):
        return None
    built, fetched = [], []
    for line in open(path, encoding="utf-8"):
        match = STORE_PATH.search(line)
        if not match:
            continue
        name = match.group("name")
        if name.endswith(".drv"):
            built.append(name.removesuffix(".drv"))
        else:
            fetched.append(name)
    return sorted(set(built)), sorted(set(fetched))


def rebuild_section(counts):
    if counts is None:
        return ""
    built, fetched = counts
    if not built and not fetched:
        return "\n## Rebuild\n\nNothing to build, nothing to fetch.\n"

    packages = [name for name in built if VERSIONED.search(name)]
    glue = len(built) - len(packages)
    head = (
        f"\n## Rebuild\n\n{len(packages)} packages to build, "
        f"{len(fetched)} paths to fetch. "
        f"{glue} generation files rebuild with any change.\n"
    )
    if not packages:
        return head
    shown = packages[:BUILD_CAP]
    body = "\n".join(f"- {name}" for name in shown)
    if len(packages) > BUILD_CAP:
        body += f"\n- and {len(packages) - BUILD_CAP} more"
    return f"{head}\nBuilt locally, so not in the cache yet:\n\n{body}\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--old", required=True)
    parser.add_argument("--new", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--lane", default="medium")
    parser.add_argument("--grouped", default="false")
    parser.add_argument("--dry-run-log")
    args = parser.parse_args()

    rows = changes(load(args.old), load(args.new))
    if not rows:
        print(f"`{args.input}` did not move.")
        return

    direct = [row for row in rows if row[0] == args.input]
    indirect = len(rows) - len(direct)

    if args.grouped == "true":
        print(f"Lane **{args.lane}**. `{args.input}` does not evaluate on its own")
        print("at this revision, so every input moved together. A revert here")
        print("costs the whole set.\n")
    else:
        print(f"Lane **{args.lane}**. One input per pull request, so a revert here")
        print("costs this bump and no other.\n")
    print(table(rows))
    if indirect:
        print(f"\n{indirect} other nodes moved with it.")
    print(rebuild_section(rebuilds(args.dry_run_log)))
    print("Both host configurations evaluate at this lock. A green build check")
    print("on this pull request means they also build.")


if __name__ == "__main__":
    main()
