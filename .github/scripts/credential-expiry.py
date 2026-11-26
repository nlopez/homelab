#!/usr/bin/env python3
"""List the credentials in .github/credentials.yaml that expire soon.

  credential-expiry.py [<credentials.yaml>]

Prints a Markdown list of the ones within WARN_DAYS (default 30) of their
expiry or past it, and exits 1 if there are any, 0 if none. TODAY
(YYYY-MM-DD) overrides the date, for tests. Run weekly by
.github/workflows/credential-expiry.yaml.
"""

import datetime
import os
import sys
from pathlib import Path

import yaml

REQUIRED = ("name", "vault", "item", "expires", "used_by", "rotate")


def main(argv):
    path = Path(argv[1] if len(argv) > 1 else Path(__file__).resolve().parents[1] / "credentials.yaml")
    entries = yaml.safe_load(path.read_text()) or []
    today = datetime.date.fromisoformat(os.environ.get("TODAY") or datetime.date.today().isoformat())
    warn = int(os.environ.get("WARN_DAYS", "30"))

    problems, soon = [], []
    for i, entry in enumerate(entries):
        missing = [k for k in REQUIRED if not entry.get(k)]
        if missing:
            problems.append(f"entry {i + 1} ({entry.get('name', '?')}) is missing {', '.join(missing)}")
            continue
        expires = entry["expires"]
        if not isinstance(expires, datetime.date):
            problems.append(f"{entry['name']}: expires must be a date (YYYY-MM-DD), not {expires!r}")
            continue
        left = (expires - today).days
        if left <= warn:
            when = f"expired {-left} days ago" if left < 0 else f"expires in {left} days"
            soon.append(
                f"- **{entry['name']}** {when} ({expires}). `{entry['vault']}` item "
                f"`{entry['item']}`, used by `{entry['used_by']}`. Rotate: {entry['rotate']}"
            )
    if problems:
        print("\n".join(f"- {p}" for p in problems), file=sys.stderr)
        return 2
    if soon:
        print("\n".join(soon))
        return 1
    print(f"No credential expires within {warn} days.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
