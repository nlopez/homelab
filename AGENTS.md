# Agent guide

Several agents and people work in this repo at the same time. Every change lands through a pull request, and every stack that applies on `main` posts a plan on the PR first. Agents need no production credentials locally: CI plans with read-only credentials and applies after merge.

`kubernetes/`, `gateway/`, and `aws/` each have their own `AGENTS.md`. Read it before you change files there. Claude Code agents: the `ship` skill (`.claude/skills/ship/`) walks through landing a change, and `.claude/settings.json` pre-approves the read-only commands it uses.

## Setup

- Enter the dev shell (`direnv allow` or `nix develop`), defined in `flake.nix`. It provides every tool the pre-commit hooks need and installs the hooks.
- Hooks run on every commit and must pass. Never skip them (`--no-verify`) or skip signing.
- Claude Code cloud sessions can't build the dev shell. `.claude/hooks/session-start.sh` installs the same tools from Nix and PyPI at session start instead, and installs the hooks. `ansible-lint` there needs `galaxy.ansible.com` allowed in the session's environment.
- The `pre-commit` check runs the same hooks in CI on the files a PR changes. Without the dev shell, install `pre-commit`, `tofu`, `ansible-lint`, and `go` some other way and run the hooks anyway; CI is the backstop, not the first check.

## One task, one branch, one worktree, one PR

- Never edit files in the main clone. Create a worktree first: `wt switch --create <branch>`.
- Keep the worktree directory and its branch matched. Never `git switch` or `git checkout` to another branch inside a worktree.
- Keep each task small and touching few files. Small changes conflict less and plan faster.
- Do not reformat or reorganize files you are not otherwise changing.
- Before you start, check open PRs for the same stack: `gh pr list --search '<dir>'`. If another PR changes the same resources, coordinate in that PR instead of opening a competing one. The `Stack overlap` check also comments on both PRs while two open PRs change the same stack.

### Without `wt` or `gh`

Claude Code cloud sessions, and other agents, may have neither tool. The same steps in plain git and the
GitHub API (or the GitHub tools your agent has):

| Step | With the tools | Without them |
| --- | --- | --- |
| Start a task | `wt switch --create <branch>` | `git fetch origin main && git worktree add -b <branch> ../<branch> origin/main`, then work in `../<branch>` |
| Find PRs on a stack | `gh pr list --search '<dir>'` | List open PRs and their changed files (`GET /repos/{owner}/{repo}/pulls`, then `/pulls/{n}/files`) |
| Open a PR | `gh pr create --fill` | Create a pull request against `main` with the description step 2 asks for |
| Wait for checks | `scripts/pr-wait <pr>` (or `gh pr checks --watch`) | Poll the head commit's check runs (`GET /repos/{owner}/{repo}/commits/{sha}/check-runs`) until `ci-ok` completes; it takes 2–6 minutes when stacks plan |
| Read the plans | `gh pr view --comments` | Read the PR's comment that starts with `<!-- ci-summary -->`; each row links to its plan job, whose summary holds the full plan |
| Merge | `gh pr merge --squash --delete-branch` | Squash-merge with the head commit's SHA as the expected head; the repository deletes the branch |
| Check the apply | `gh run list --branch main --limit 5` | List workflow runs for the merge commit (`GET /repos/{owner}/{repo}/actions/runs?head_sha=<sha>`) |
| Clean up | `wt remove -D` | `git worktree remove ../<branch> && git branch -D <branch>` |

## Plan before you push (optional)

`scripts/plan <stack>` plans a stack locally exactly as its PR plan does in CI: the same directory,
plan arguments, and variables, read from the stack's workflow, with its read-only `secrets.plan.env`
and no state lock. It can't change anything. `scripts/plan --list` shows the stacks and
`--dry-run` the commands. It needs read access to the state bucket (an AWS profile) and to the
`ci-pr` vault (your 1Password session, or `OP_SERVICE_ACCOUNT_TOKEN` for the ci-pr service account);
a session without them can't use it, and CI's plan on the PR stays the one that counts.

## Open a PR and wait for the plan

1. Commit in your worktree. The pre-commit hooks run on each commit.
2. Push the branch and open a PR: `git push -u origin HEAD`, then `gh pr create --fill`. Say in the description what the plan should show, for example "adds one A record, changes nothing else".
3. Wait for the checks: `scripts/pr-wait <pr>` waits for `ci-ok` and prints its summary (or `gh pr checks --watch`). The `ci-ok` check runs on every PR, waits for all the others, and fails if any of them failed. The ci-gate GitHub App posts it, from `main`'s copy of `.github/workflows/ci-gate-protected.yaml`, so a PR can't change or fake it. If you re-run a failed check, re-run the `CI gate (protected)` workflow too.
4. Read the `ci-ok` summary comment on the PR (`gh pr view --comments`), the one comment CI posts. It has one row per stack planned on the current commit: its plan result, and whether it destroys anything, plus failing checks and the Kubernetes manifest diff result. For any row that isn't `No changes`, follow its link: the full plan is in that plan job's summary.
5. Compare each plan with what the description says it should show.
   - It matches and `ci-ok` passed: merge with `gh pr merge --squash --delete-branch`. To merge as soon as `ci-ok` passes, add `--auto` right after opening the PR instead of waiting.
   - It shows anything you did not intend (an extra replace, a destroy, drift from someone else's change): do not merge. Fix the change, or describe the unexpected diff in a PR comment and leave it for a human.
   - A plan that destroys or replaces anything needs a human's approval, even when intended. The plan comment lists what goes, and `ci-ok` fails until a code owner adds the `destroy-approved` label by hand. Never add that label yourself. Say in the PR what is destroyed and why, and leave it for a human. A later push whose plan still destroys something removes the label, so the approval always covers the current plan.
6. After the merge, the stack's workflow applies on `main`, and for `kubernetes/` the `Kubernetes sync check` waits until Argo CD has synced the changed Applications and they are Healthy. Confirm it passed: `gh run list --branch main --limit 5`. If the apply fails, open a follow-up PR; do not retry by hand.
7. Remove the worktree once `gh pr view --json state -q .state` prints `MERGED`: `wt remove -D`. The squash merge gives `main` a new commit ID, so the local branch looks unmerged and needs `-D`.

If you abandon a task, close the PR (`gh pr close --delete-branch`) and run `wt remove -D`. Never leave a worktree or an open PR behind without saying why in the PR.

Never push to `main` directly, and never run `tofu apply` or `ansible-playbook` against production from your machine.

## When something goes wrong

- `main` moved: `main` only accepts a PR that contains its latest commit, so rebase (`git fetch origin && git rebase origin/main`), push with `git push --force-with-lease`, and wait for a fresh `ci-ok`. If the move touched the same stack, re-read the new plan: a plan made before someone else's merge to the same stack is stale.
- Rebase conflict: resolve it in your worktree, re-run the hooks, and continue. If another agent's change is involved, keep both intents.
- A plan shows changes you did not make: look for an open `Drift in <stack>` issue. Every OpenTofu stack plans nightly on `main`, and Ansible runs in check mode nightly, and each keeps that issue open while the live state differs from `main`. Do not fold a fix for the drift into an unrelated PR; leave it for a human, or fix it in its own PR that links the issue.
- A hook fails: fix the cause and commit again. Do not bypass it.
- You changed a script in `.github/scripts/` or `scripts/`: run `.github/scripts/tests/run.sh` before pushing, and add a case for the behaviour you changed.
- A plan job fails before it plans (credentials, network): say so in the PR and leave it for a human. Do not merge without a plan.

## Where checks run

| Directory | On the PR | On push to `main` |
| --- | --- | --- |
| every PR | `ci-ok`, which passes only when every other check passed | nothing |
| every PR | `pre-commit`: the commit hooks, on the files the PR changes | nothing |
| every PR | `Script tests`: `.github/scripts/tests/run.sh` and shellcheck, for the scripts CI runs | nothing |
| `arr/` | `tofu plan` comment (secret-holding resources excluded) | `tofu apply` |
| `ansible/` | `ansible-lint` | nothing; a nightly check-mode drift run, and apply is a manual `Ansible` dispatch |
| `authentik/` | `tofu plan` comment | `tofu apply` |
| `truenas/` | `tofu plan` comment (replication keychain excluded) | `tofu apply` |
| `aws/` (SES and SMTP stacks) | `tofu plan` comment per stack | `tofu apply` |
| `aws/state-bucket` | `tofu plan` comment | `tofu apply` |
| `datadog/` | `tofu plan` comment | `tofu apply` |
| `dns/` | `tofu plan` comment | `tofu apply` |
| `gateway/` | `tofu plan` comment | `tofu apply` |
| `github/` | `tofu plan` comment (read-only token, webhook excluded) | nothing; a human applies it locally |
| `kubernetes/` | yamlfmt, schema, kubeconform hooks; rendered manifest diff comment | Argo CD syncs; `Kubernetes sync check` waits for the changed Applications to be Synced and Healthy |
| `tailnet/` | ACL tests, `tofu plan` comment | `tofu apply` |
| `tailnet/admin` | `tofu plan` comment | `tofu apply` |

Every OpenTofu stack's workflow is a short caller of `.github/workflows/_tofu-stack.yaml`, which plans on PRs and applies on `main`. To add a stack, copy `dns.yaml`, give it plan and apply roles in `aws/state-bucket/iam.tf`, and put its read-only plan credentials in `<stack>/secrets.plan.env` ([SECRETS.md](SECRETS.md) says which vault each kind of credential goes in).

`github/` plans on pull requests but never applies from CI, since it manages this repository's own protections. A human applies it after the merge; say in the PR that it needs a local apply.
