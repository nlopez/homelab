#!/usr/bin/env python3
"""Wait for the Argo CD Applications a push to main changed to sync and turn healthy.

Run by .github/workflows/kubernetes-sync-check.yaml after a push that touches
kubernetes/, from a runner on the tailnet with a read-only Argo CD token.

  argocd-sync-check.py targets            changed paths on stdin -> app names
  argocd-sync-check.py wait <before> <sha>

An Application counts as done for <sha> when Argo has compared it against <sha>
or a later commit, it is Synced and Healthy, and no sync is running. It fails
when a sync of <sha> or later fails, or when the timeout passes first.

Environment for wait: ARGOCD_SERVER (host), ARGOCD_TOKEN, and optionally
SYNC_TIMEOUT (seconds, default 900), SYNC_INTERVAL (default 15), and
ARGOCD_APPS_JSON (a file to read instead of the API, for tests).
"""

import json
import os
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

ROOT = Path(os.environ.get("REPO_ROOT", Path(__file__).resolve().parents[2]))
ALL = "*"


def targets(paths):
    """Map changed paths to the Applications they feed (kubernetes/bootstrap/apps*.yaml)."""
    apps = set()
    for path in paths:
        parts = path.strip().split("/")
        if len(parts) < 3 or parts[0] != "kubernetes" or path.endswith(".md"):
            continue
        kind, name = parts[1], parts[2]
        if kind == "apps" and len(parts) > 3:
            if len(parts) > 5 and parts[3] == "overlays":
                apps.add(f"{name}-{parts[4]}")
                continue
            # A base change reaches the app and every overlay built on it.
            apps.add(name)
            overlays = ROOT / "kubernetes" / "apps" / name / "overlays"
            if overlays.is_dir():
                apps.update(f"{name}-{o.name}" for o in overlays.iterdir() if o.is_dir())
        elif kind == "apps-helm" and len(parts) > 3 and name != "_template":
            apps.add(name)
        elif kind == "bootstrap":
            return {ALL}
    return apps


def fetch_apps():
    fixture = os.environ.get("ARGOCD_APPS_JSON")
    if fixture:
        return json.loads(Path(fixture).read_text())["items"]
    request = urllib.request.Request(
        f"https://{os.environ['ARGOCD_SERVER']}/api/v1/applications",
        headers={"Authorization": f"Bearer {os.environ['ARGOCD_TOKEN']}"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response).get("items") or []


def at_or_after(sha, revisions):
    """Whether any of revisions is sha or a commit that contains it."""
    for rev in revisions:
        if rev == sha:
            return True
        if len(rev) == 40 and subprocess.run(
            ["git", "-C", str(ROOT), "merge-base", "--is-ancestor", sha, rev],
            capture_output=True,
        ).returncode == 0:
            return True
    return False


def state(app, sha):
    """(done, failed, description) of one Application for sha."""
    status = app.get("status") or {}
    sync = status.get("sync") or {}
    revisions = [sync.get("revision") or ""] + list(sync.get("revisions") or [])
    sync_status = sync.get("status", "Unknown")
    health = (status.get("health") or {}).get("status", "Unknown")
    operation = status.get("operationState") or {}
    phase = operation.get("phase", "")
    op_revisions = [(operation.get("syncResult") or {}).get("revision") or ""] + list(
        (operation.get("syncResult") or {}).get("revisions") or [])
    desc = f"{sync_status}, {health}" + (f", last sync {phase}" if phase else "")
    if not at_or_after(sha, revisions):
        return False, False, f"not compared with {sha[:8]} yet ({desc})"
    if phase in ("Failed", "Error") and at_or_after(sha, op_revisions):
        return False, True, f"sync failed: {operation.get('message', '')}".strip()
    done = sync_status == "Synced" and health == "Healthy" and phase != "Running"
    return done, False, desc


def wait(before, sha):
    if not before or set(before) == {"0"}:
        before = f"{sha}^"
    changed = subprocess.run(
        ["git", "-C", str(ROOT), "diff", "--name-only", before, sha, "--", "kubernetes/"],
        check=True, capture_output=True, text=True,
    ).stdout.split()
    wanted = targets(changed)
    # Reach the API even when nothing changed, so a broken token or route
    # shows up on the next push rather than on the next one that matters.
    count = len(fetch_apps())
    if not wanted:
        print(f"No Argo CD Application changed in this push ({count} Applications readable).")
        return 0

    timeout = int(os.environ.get("SYNC_TIMEOUT", "900"))
    interval = int(os.environ.get("SYNC_INTERVAL", "15"))
    deadline = time.monotonic() + timeout
    while True:
        apps = {a["metadata"]["name"]: a for a in fetch_apps()}
        names = sorted(apps) if ALL in wanted else sorted(wanted)
        report, pending, failed = [], [], []
        for name in names:
            if name not in apps:
                report.append(f"{name}: no such Application (removed, or not created yet)")
                continue
            done, bad, desc = state(apps[name], sha)
            report.append(f"{name}: {desc}")
            (failed if bad else pending if not done else []).append(name)
        if failed or not pending or time.monotonic() >= deadline:
            break
        time.sleep(interval)

    print("\n".join(report))
    if failed:
        print(f"Sync failed for {', '.join(failed)}.", file=sys.stderr)
        return 1
    if pending:
        print(f"Timed out after {timeout}s waiting for {', '.join(pending)}.", file=sys.stderr)
        return 1
    print(f"Every changed Application is Synced and Healthy at {sha[:8]} or later.")
    return 0


def main(argv):
    if argv[1:2] == ["targets"]:
        print("\n".join(sorted(targets(sys.stdin.read().split()))))
        return 0
    if argv[1:2] == ["wait"] and len(argv) == 4:
        return wait(argv[2], argv[3])
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
