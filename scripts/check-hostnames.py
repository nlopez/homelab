#!/usr/bin/env python3
"""Check that app hostnames don't collide.

Every app has exactly one hostname (EXPOSURE.md). Two checks keep agents that
work in parallel from taking the same one:

1. A hostname in a route's `hostnames:` list belongs to one app directory
   under kubernetes/apps or kubernetes/apps-helm. The same app may route it on
   both gateways.
2. No codename still listed as unused in CODENAMES.md is used as a
   desertbluffs.com hostname anywhere in the repo. Taking a codename means
   deleting it from that list in the same change.
"""
import pathlib
import re
import subprocess
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP_DIRS = [ROOT / "kubernetes" / "apps", ROOT / "kubernetes" / "apps-helm"]


def hostnames(node):
    """Yield every string in any `hostnames` list in a parsed YAML node."""
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "hostnames" and isinstance(value, list):
                yield from (v for v in value if isinstance(v, str))
            else:
                yield from hostnames(value)
    elif isinstance(node, list):
        for item in node:
            yield from hostnames(item)


def route_owners():
    owners = {}
    for base in APP_DIRS:
        for path in sorted(base.rglob("*.y*ml")):
            app = path.relative_to(base).parts[0]
            try:
                docs = list(yaml.safe_load_all(path.read_text()))
            except yaml.YAMLError:
                continue  # Helm templates and other non-YAML; check-yaml covers the rest.
            for doc in docs:
                for host in hostnames(doc):
                    owners.setdefault(host, {}).setdefault(app, path.relative_to(ROOT))
    return owners


def main():
    errors = []

    for host, apps in sorted(route_owners().items()):
        if len(apps) > 1:
            where = ", ".join(f"{app} ({path})" for app, path in sorted(apps.items()))
            errors.append(f"{host} is routed by more than one app: {where}")

    unused = {
        line[2:].strip()
        for line in (ROOT / "CODENAMES.md").read_text().splitlines()
        if line.startswith("- ")
    }
    tracked = subprocess.run(
        ["git", "ls-files", "-z"], cwd=ROOT, check=True, capture_output=True, text=True
    ).stdout.split("\0")
    pattern = re.compile(r"\b([a-z0-9]+)\.desertbluffs\.com\b")
    for name in filter(None, tracked):
        path = ROOT / name
        if name == "CODENAMES.md" or not path.is_file():
            continue
        try:
            text = path.read_text()
        except (UnicodeDecodeError, OSError):
            continue
        for match in pattern.finditer(text):
            if match.group(1) in unused:
                errors.append(
                    f"{name}: {match.group(0)} uses a codename CODENAMES.md still lists as unused; "
                    "delete it from that list"
                )

    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
