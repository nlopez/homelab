---
name: ship
description: Land a change in this homelab repo end to end - commit, PR with expected plans, wait for ci-ok, check the plans, merge, confirm the apply, clean up. Use for any change to this repo, including several PRs in a row.
---

# Ship a change

AGENTS.md is the rulebook; this is the order to do it in, with what tends to go wrong.
Read the `AGENTS.md` of any directory you change (`kubernetes/`, `gateway/`, `aws/`).

## 1. Start clean

- `git fetch origin main` and start from `origin/main`.
- Check open PRs for the same stack first. The `ci-ok` summary comment lists any that overlap.
- One concern per PR. Several small PRs merge faster than one large one, because each only plans
  the stacks it touches.

## 2. Change and verify locally

- Commit with the hooks; never `--no-verify`. If a hook fails, fix the cause.
- Changed a script in `.github/scripts/` or `scripts/`: run `.github/scripts/tests/run.sh`, add a
  case, and break the script on purpose once to see the new case fail.
- Changed a workflow or a shell script: the hooks run `actionlint` and `shellcheck` on it.
- Changed an OpenTofu stack: `scripts/plan <stack>` shows the PR plan before you push, if this
  machine has AWS and `ci-pr` access. `tofu fmt` runs in the hooks.
- Don't commit build output or caches (`.direnv/`, `.terraform/`, anything a tool just created).

## 3. Open the PR

- Fill in the template: what changes, why, and **what each stack's plan should show** ("adds one
  A record, changes nothing else"; "No changes" for stacks the PR touches only incidentally).
  Writing it before CI runs is what makes the comparison in step 5 honest.
- Say if the change needs a human: a local apply (`github/`), a destroy
  approval, or a decision only the owner can make.

## 4. Wait for CI

- `scripts/pr-wait <pr>` waits for `ci-ok` and prints the summary comment. Run it in the
  background if your agent can, rather than polling. Plans take 2-6 minutes.
- Exit 1: a check failed. Find the cause in the failing job's log and push a fix; don't re-run
  hoping it passes, and never weaken a check to get green.
- Exit 3: `main` moved. Rebase, `git push --force-with-lease`, wait again.

## 5. Compare and merge

- Read every row of the summary. Each must match what the description said; open the linked plan
  job for any row that isn't `No changes`.
- A destroy or replace: stop and leave it for a human (AGENTS.md). Never add `destroy-approved`.
- Anything you didn't intend, including drift: don't merge. Check for a `Drift in <stack>` issue.
- Merge and confirm the apply with `scripts/pr-land <pr>`: one command that squash-merges with
  head-commit matching, waits for all workflow runs on main to complete, and reports each run's
  result. For a stack that should change, check its Apply step ran (not just its Plan); a green
  run with a skipped Apply means nothing was applied. For `kubernetes/`, it includes the
  `Kubernetes sync check` run, which fails if a changed Application isn't Synced and Healthy
  within 15 minutes. To merge as soon as `ci-ok` passes without waiting, add `--auto` right
  after opening the PR instead (applies the merge without waiting for apply runs).

## 6. After the merge

- If a run failed, open the failed job's log and fix the issue in a follow-up PR; do not retry
  by hand.
- Several PRs open at once: `main` requires each to be up to date, so after every merge, rebase
  the next one and wait for its fresh `ci-ok` before merging it. Merge the quickest checks first.
