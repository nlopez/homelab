#!/usr/bin/env bash
# Summarizes an `ansible-playbook --check --diff` log for the Drift in Ansible
# issue: the tasks that would change, with their hosts, and the play recap.
# Leaves out the --diff output, which can hold rendered secrets. Run by
# .github/workflows/ansible.yaml.
#
#   ansible-drift-summary.sh <log>
set -euo pipefail

log="${1:?usage: ansible-drift-summary.sh <log>}"

echo "Changed tasks:"
echo
echo '```'
awk '/^TASK \[/ { task = $0 } /^changed: / { print task; print "  " $0 }' "${log}" | head -c 30000
echo '```'
echo
echo "Recap:"
echo
echo '```'
grep -E '^[A-Za-z0-9.-]+ +: ok=' "${log}" || true
echo '```'
