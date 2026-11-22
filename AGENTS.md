# Agent guide

Several agents and people work in this repo at the same time. Every rule below exists to avoid conflicts and keep `main` moving.

## Setup

- Enter the dev shell (`direnv allow` or `devenv shell`). It provides every tool the pre-commit hooks need and installs the hooks.
- Hooks run on every commit and must pass. Never skip them (`--no-verify`) or skip signing.

## One task, one branch, one worktree

- Never edit files in the main clone. Create a worktree first: `wt switch --create <branch>`.
- Keep the worktree directory and its branch matched. Never `git switch` or `git checkout` to another branch inside a worktree.
- Keep each task small and touching few files. Small changes conflict less.
- Do not reformat or reorganize files you are not otherwise changing.

## Merge to main before you push

1. Commit in your worktree. The pre-commit hooks run on each commit.
2. Run `wt merge --no-remove`. It squashes, rebases onto the latest `main`, and fast-forwards `main`. The worktree stays, so your shell keeps a valid directory.
3. Push `main` from the main clone: `git -C ~/src/github.com/nlopez/homelab push origin main`.
4. Run `wt remove` as the last command. Removing the worktree you are standing in ends your shell.

Never push a feature branch's work to `main` without rebasing onto current `main` first.

## When something goes wrong

- Push rejected because `main` moved: run `wt merge --no-remove` again, then push. Do not force-push.
- Rebase conflict: resolve it in your worktree, re-run the hooks, and continue. If another agent's change is involved, keep both intents.
- A hook fails: fix the cause and commit again. Do not bypass it.

## Where checks run

- `ansible/` changes: `ansible-lint` hook.
- `dns/` changes: `dnscontrol check` hook. `main` pushes apply DNS changes automatically, so review these carefully.
- `kubernetes/` changes: yamlfmt, schema, and kubeconform hooks. Rendered manifest diffs only appear on PRs.
- `tailnet/` changes apply on push to `main` with no pre-merge check.
