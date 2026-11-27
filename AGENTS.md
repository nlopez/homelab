# Agent guide

Several agents and people work in this repo at the same time. Every change lands through a pull request, and every stack that applies on `main` posts a plan on the PR first. Agents need no production credentials locally: CI plans with read-only credentials and applies after merge.

`kubernetes/`, `gateway/`, and `aws/` each have their own `AGENTS.md`. Read it before you change files there. Claude Code agents: the `ship` skill (`.claude/skills/ship/`) walks through landing a change, and `.claude/settings.json` pre-approves the read-only commands it uses.

## Setup

- Enter the dev shell (`direnv allow` or `nix develop`), defined in `flake.nix`. It provides every tool the pre-commit hooks need and installs the hooks.
- Hooks run on every commit and must pass. Never skip them (`--no-verify`) or skip signing.
- Claude Code cloud sessions can't build the dev shell. `.claude/hooks/session-start.sh` installs the same tools from Nix and PyPI at session start instead, and installs the hooks. `ansible-lint` there needs `galaxy.ansible.com` allowed in the session's environment.
- The `pre-commit` check runs the same hooks in CI on the files a PR changes. Without the dev shell, install `pre-commit`, `tofu`, `ansible-lint`, and `go` some other way and run the hooks anyway; CI is the backstop, not the first check.

## One task, one PR

- Keep each task small and touching few files. Small changes conflict less and plan faster.
- Do not reformat or reorganize files you are not otherwise changing.
- Before you start, check open PRs for the same stack: `gh pr list --search '<dir>'`. If another PR changes the same resources, coordinate in that PR instead of opening a competing one.
Cloud sessions without `gh`: see [.claude/CLOUD.md](.claude/CLOUD.md).

If you abandon a task, close the PR (`gh pr close --delete-branch`). Never leave an open PR behind without saying why in the PR.

## Landing a change

The `ship` skill walks through committing, opening a PR, waiting for checks, verifying the plan, merging, and confirming the apply. Use it for every change to this repo. See `.claude/skills/ship/SKILL.md`.

## Plan before you push (optional)

`scripts/plan <stack>` plans a stack locally exactly as its PR plan does in CI: the same directory, plan arguments, and variables, read from the stack's workflow, with its read-only `secrets.plan.env` and no state lock. It can't change anything. `scripts/plan --list` shows the stacks and `--dry-run` the commands. It needs read access to the state bucket (an AWS profile) and to the `ci-pr` vault (your 1Password session, or `OP_SERVICE_ACCOUNT_TOKEN` for the ci-pr service account); a session without them can't use it, and CI's plan on the PR stays the one that counts.

Never push to `main` directly, and never run `tofu apply` or `ansible-playbook` against production from your machine.

## When something goes wrong

- `main` moved: a PR doesn't need `main`'s latest commit. The apply on `main` plans again from `main`, so it applies what both merges changed. Rebase (`git fetch origin && git rebase origin/main`, then `git push --force-with-lease`) only when GitHub reports a merge conflict.
- Rebase conflict: resolve it, re-run the hooks, and continue. If another agent's change is involved, keep both intents.
- A plan shows changes you did not make: look for an open `Drift in <stack>` issue. Every OpenTofu stack plans nightly on `main`, and Ansible runs in check mode nightly, and each keeps that issue open while the live state differs from `main`. Do not fold a fix for the drift into an unrelated PR; leave it for a human, or fix it in its own PR that links the issue.
- A hook fails: fix the cause and commit again. Do not bypass it.
- You changed a script in `.github/scripts/` or `scripts/`: run `.github/scripts/tests/run.sh` before pushing, and add a case for the behaviour you changed.
- A plan job fails before it plans (credentials, network): say so in the PR and leave it for a human. Do not merge without a plan.
- A failed apply on `main`: open a follow-up PR; do not retry by hand.
- If you re-run a failed check, re-run the `CI gate (protected)` workflow too.
- A plan that destroys or replaces anything needs a human's approval, even when intended. Say in the PR what is destroyed and why. The `ci-ok` check fails until a code owner adds the `destroy-approved` label by hand. Never add that label yourself. The approval covers only the commit the owner saw: after any later push, `ci-ok` fails until the owner removes the label and adds it again. Never remove the label yourself either.

## Checks and applies

Every PR gets `ci-ok` (passes only when all others pass), `pre-commit` (commit hooks), and `Script tests` (for scripts in `.github/scripts/`). Every OpenTofu stack plans on PR and applies on `main` via `.github/workflows/_tofu-stack.yaml`. The `ci-ok` check is posted by the ci-gate GitHub App from `main`'s copy of `.github/workflows/ci-gate-protected.yaml`, so a PR can't change or fake it.

Exceptions:
- `arr/`: secret-holding resources excluded from PR plan.
- `ansible/`: `ansible-lint` on PR; apply confined to allowlisted roles (`.github/scripts/ansible-merge-tags.py`), by tag; anything else waits for manual `Ansible` dispatch. Nightly check-mode drift run.
- `truenas/`: replication keychain excluded from PR plan.
- `gateway/`: WireGuard resources excluded from PR plan (see `gateway/AGENTS.md`).
- `github/`: plans on PR but never applies from CI; a human applies locally after merge. Webhook excluded from plan.
- `kubernetes/`: yamlfmt, schema, kubeconform hooks; manifest diff comment on PR. Argo CD syncs on `main`; `Kubernetes sync check` waits for changed Applications to be Synced and Healthy.

To add a stack, copy `dns.yaml`, give it plan and apply roles in `aws/state-bucket/iam.tf`, and put its read-only plan credentials in `<stack>/secrets.plan.env` ([SECRETS.md](SECRETS.md) says which vault each kind of credential goes in).
