#!/usr/bin/env python3
"""Render the release notes for the daily flake.lock update.

Called by .github/workflows/flake-update.yml with the lock file from before
the update and the one from after it. Prints markdown on stdout: one table
per lane with a compare link for every moved input, the transitive nodes that
moved with them, the inputs held back, and the rebuild list that
`nix build --dry-run` reported.

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


LANES = ("high", "medium", "low")
LANE_TEXT = {
    "high": "builds the system or holds its secrets",
    "medium": "a break costs a desktop session",
    "low": "a break costs one application",
}


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
    parser.add_argument("--lanes", required=True)
    # NAME=REASON, once per input that stayed at its old revision.
    parser.add_argument("--held", action="append", default=[])
    parser.add_argument("--dry-run-log")
    args = parser.parse_args()

    config = load(args.lanes)
    new = load(args.new)
    names = set(root_inputs(new).values())
    rows = changes(load(args.old), new)

    direct = [row for row in rows if row[0] in names]
    indirect = [row for row in rows if row[0] not in names]
    lanes = {
        row[0]: config["inputs"].get(row[0], config["default"]) for row in direct
    }

    if direct:
        print(f"{len(direct)} inputs moved. Merge to take all of them.\n")
    else:
        print("No input moved.\n")

    for lane in LANES:
        group = [row for row in direct if lanes[row[0]] == lane]
        if not group:
            continue
        print(f"## Lane {lane}: {LANE_TEXT[lane]}\n")
        print(table(group))
        print()

    if indirect:
        count = len(indirect)
        print(f"<details><summary>{count} transitive nodes moved with them</summary>\n")
        print(table(indirect))
        print("\n</details>\n")

    if args.held:
        print("## Held back\n")
        print("These inputs stay at their old revision.\n")
        for item in args.held:
            name, _, reason = item.partition("=")
            print(f"- `{name}`: {reason}")
        print()

    print(rebuild_section(rebuilds(args.dry_run_log)))
    print("Both host configurations evaluate at this lock. A green build check")
    print("on this pull request means they also build.\n")
    print("To drop an input from this pull request, run the Flake update")
    print("workflow with its name in `hold`. The run rewrites this branch.")


if __name__ == "__main__":
    main()
