#!/usr/bin/env python3
"""Decide which Ansible tags a merge may apply on its own.

  git diff --name-only <before> <after> | ansible-merge-tags.py

Prints the comma-separated tags to apply when every changed path under
ansible/ belongs to a role in AUTO_APPLY (docs don't count), and prints
nothing when any other Ansible file changed, or none did: those wait for a
person to dispatch the Ansible workflow with apply. Run by
.github/workflows/ansible.yaml on push to main.
"""

import sys

# role directory -> the site.yaml tag that runs only that role. Only roles
# whose worst case can't cut a host off the network or lock out SSH belong
# here. To add one, tag it in site.yaml and list it.
AUTO_APPLY = {
    "unattended_upgrades": "unattended_upgrades",
}


def tags(paths):
    chosen = set()
    for path in (p.strip() for p in paths):
        if not path.startswith("ansible/") or path.endswith(".md"):
            continue
        parts = path.split("/")
        if len(parts) > 3 and parts[1] == "roles" and parts[2] in AUTO_APPLY:
            chosen.add(AUTO_APPLY[parts[2]])
        else:
            return set()
    return chosen


if __name__ == "__main__":
    print(",".join(sorted(tags(sys.stdin.read().split()))))
