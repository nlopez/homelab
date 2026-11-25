# Agent guide

Several agents and people work in this repo at the same time. Every change lands through a pull request, and every stack that applies on `main` posts a plan on the PR first. Agents need no production credentials locally: CI plans with read-only credentials and applies after merge.

## Setup

- Enter the dev shell (`direnv allow` or `devenv shell`). It provides every tool the pre-commit hooks need and installs the hooks.
- Hooks run on every commit and must pass. Never skip them (`--no-verify`) or skip signing.
- The `pre-commit` check runs the same hooks in CI on the files a PR changes. Without the dev shell, install `pre-commit`, `tofu`, `ansible-lint`, and `go` some other way and run the hooks anyway; CI is the backstop, not the first check.

## One task, one branch, one worktree, one PR

- Never edit files in the main clone. Create a worktree first: `wt switch --create <branch>`.
- Keep the worktree directory and its branch matched. Never `git switch` or `git checkout` to another branch inside a worktree.
- Keep each task small and touching few files. Small changes conflict less and plan faster.
- Do not reformat or reorganize files you are not otherwise changing.
- Before you start, check open PRs for the same stack: `gh pr list --search '<dir>'`. If another PR changes the same resources, coordinate in that PR instead of opening a competing one.

## Open a PR and wait for the plan

1. Commit in your worktree. The pre-commit hooks run on each commit.
2. Push the branch and open a PR: `git push -u origin HEAD`, then `gh pr create --fill`. Say in the description what the plan should show, for example "adds one A record, changes nothing else".
3. Wait for the checks: `gh pr checks --watch`. The `ci-ok` check (`.github/workflows/ci-gate.yaml`) runs on every PR, waits for all the others, and fails if any of them failed. If you re-run a failed check, re-run `ci-ok` too.
4. Read every plan comment on the PR (`gh pr view --comments`). Each stack posts its own comment and updates it on every push.
5. Compare each plan with what the description says it should show.
   - It matches and `ci-ok` passed: merge with `gh pr merge --squash --delete-branch`. To merge as soon as `ci-ok` passes, add `--auto` right after opening the PR instead of waiting.
   - It shows anything you did not intend (an extra replace, a destroy, drift from someone else's change): do not merge. Fix the change, or describe the unexpected diff in a PR comment and leave it for a human.
   - A plan that destroys or replaces a stateful resource (a DNS zone, an IAM user, a WireGuard server, an authentik flow) needs a human's approval in the PR, even when intended.
6. After the merge, the stack's workflow applies on `main`. Confirm it passed: `gh run list --branch main --limit 5`. If the apply fails, open a follow-up PR; do not retry by hand.
7. Remove the worktree once `gh pr view --json state -q .state` prints `MERGED`: `wt remove -D`. The squash merge gives `main` a new commit ID, so the local branch looks unmerged and needs `-D`.

If you abandon a task, close the PR (`gh pr close --delete-branch`) and run `wt remove -D`. Never leave a worktree or an open PR behind without saying why in the PR.

Never push to `main` directly, and never run `tofu apply` or `ansible-playbook` against production from your machine.

## When something goes wrong

- `main` moved: `main` only accepts a PR that contains its latest commit, so rebase (`git fetch origin && git rebase origin/main`), push with `git push --force-with-lease`, and wait for a fresh `ci-ok`. If the move touched the same stack, re-read the new plan: a plan made before someone else's merge to the same stack is stale.
- Rebase conflict: resolve it in your worktree, re-run the hooks, and continue. If another agent's change is involved, keep both intents.
- A plan shows changes you did not make: look for an open `Drift in <stack>` issue. Every OpenTofu stack plans nightly on `main` and keeps that issue open while the live state differs from `main`. Do not fold a fix for the drift into an unrelated PR; leave it for a human, or fix it in its own PR that links the issue.
- A hook fails: fix the cause and commit again. Do not bypass it.
- A plan job fails before it plans (credentials, network): say so in the PR and leave it for a human. Do not merge without a plan.

## Where checks run

| Directory | On the PR | On push to `main` |
| --- | --- | --- |
| every PR | `ci-ok`, which passes only when every other check passed | nothing |
| every PR | `pre-commit`: the commit hooks, on the files the PR changes | nothing |
| `ansible/` | `ansible-lint`, check-mode drift run | nothing; apply is a manual `Ansible` dispatch |
| `authentik/` | `tofu plan` comment | `tofu apply` |
| `aws/` (SES and SMTP stacks) | `tofu plan` comment per stack | `tofu apply` |
| `aws/state-bucket` | `tofu plan` comment | `tofu apply` |
| `datadog/` | `tofu plan` comment | `tofu apply` |
| `dns/` | `tofu plan` comment | `tofu apply` |
| `gateway/` | `tofu plan` comment | `tofu apply` |
| `kubernetes/` | yamlfmt, schema, kubeconform hooks; rendered manifest diff comment | Argo CD syncs |
| `tailnet/` | ACL tests, `tofu plan` comment | `tofu apply` |
| `tailnet/admin` | `tofu plan` comment | `tofu apply` |

Every OpenTofu stack's workflow is a short caller of `.github/workflows/_tofu-stack.yaml`, which plans on PRs and applies on `main`. To add a stack, copy `dns.yaml`, give it plan and apply roles in `aws/state-bucket/iam.tf`, and put its read-only plan credentials in `<stack>/secrets.plan.env` ([SECRETS.md](SECRETS.md) says which vault each kind of credential goes in).

`github`, `truenas`, and `arr` have no CI. A human applies them; open the PR anyway and say in it that it needs a local apply.
