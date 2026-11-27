#!/usr/bin/env python3
"""Check that app hostnames don't collide.

Every app has exactly one hostname (EXPOSURE.md). Two checks keep agents that
work in parallel from taking the same one:

1. A hostname in a route's `hostnames:` list belongs to one app directory
   under kubernetes/apps. The same app may route it on
   both gateways.
2. No codename still listed as unused in CODENAMES.md is used as a
   desertbluffs.com hostname anywhere in the repo. Taking a codename means
   deleting it from that list in the same change.
3. EXPOSURE.md's table lists every routed hostname and nothing else, and its
   Internet column matches the gateways each hostname is routed on: "No" means
   no route on the internet gateway, "Yes" means one, and "Only" means one and
   no route on the private gateway.
"""
import pathlib
import re
import subprocess
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP_DIRS = [ROOT / "kubernetes" / "apps"]


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


ROUTE_KINDS = {"HTTPRoute", "GRPCRoute", "TLSRoute", "TCPRoute", "UDPRoute"}
GATEWAYS = {"private", "internet"}


def route_gateways():
    """Map each routed hostname to the set of gateways that route it."""
    gateways = {}
    for base in APP_DIRS:
        for path in sorted(base.rglob("*.y*ml")):
            try:
                docs = list(yaml.safe_load_all(path.read_text()))
            except yaml.YAMLError:
                continue
            for doc in docs:
                if not isinstance(doc, dict) or doc.get("kind") not in ROUTE_KINDS:
                    continue
                spec = doc.get("spec") or {}
                parents = {
                    ref.get("name")
                    for ref in spec.get("parentRefs") or []
                    if ref.get("name") in GATEWAYS
                }
                for host in spec.get("hostnames") or []:
                    gateways.setdefault(host, set()).update(parents)
    return gateways


def exposure_table():
    """Map each hostname in EXPOSURE.md's table to its Internet column."""
    rows = {}
    for line in (ROOT / "EXPOSURE.md").read_text().splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 4 or cells[0] in ("Service", "---") or not line.startswith("|"):
            continue
        internet = cells[3]
        for token in re.findall(r"`([^`]+)`", cells[2]):
            if ":" in token or re.fullmatch(r"[0-9.]+", token):
                continue  # A port or an address, not a hostname.
            host = token if "." in token else f"{token}.desertbluffs.com"
            rows[host] = internet
    return rows


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

    routed = {h: g for h, g in route_gateways().items() if not h.startswith("*.")}
    listed = exposure_table()
    for host in sorted(routed.keys() - listed.keys()):
        errors.append(f"EXPOSURE.md: {host} is routed but not in the table; add a row")
    for host in sorted(listed.keys() - routed.keys()):
        errors.append(f"EXPOSURE.md: {host} is in the table but no route serves it")
    for host in sorted(routed.keys() & listed.keys()):
        internet, gws = listed[host], routed[host]
        if internet == "No" and "internet" in gws:
            errors.append(f"EXPOSURE.md: {host} says Internet: No, but the internet gateway routes it")
        elif internet in ("Yes", "Only") and "internet" not in gws:
            errors.append(f"EXPOSURE.md: {host} says Internet: {internet}, but only the private gateway routes it")
        if internet == "Only" and "private" in gws:
            errors.append(f"EXPOSURE.md: {host} says Internet: Only, but the private gateway routes it too")

    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
