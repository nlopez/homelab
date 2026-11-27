# Cloud sessions: Without `gh`

Claude Code cloud sessions, and other agents without GitHub CLI, can still follow the PR flow using git and the GitHub API (or the GitHub tools your agent has).

| Step | With `gh` | Without it |
| --- | --- | --- |
| Find PRs on a stack | `gh pr list --search '<dir>'` | List open PRs and their changed files (`GET /repos/{owner}/{repo}/pulls`, then `/pulls/{n}/files`) |
| Open a PR | `gh pr create --fill` | Create a pull request against `main` with the description the ship skill's step 3 asks for |
| Wait for checks | `scripts/pr-wait <pr>` (or `gh pr checks --watch`) | Poll the head commit's check runs (`GET /repos/{owner}/{repo}/commits/{sha}/check-runs`) until `ci-ok` completes; it takes 2–6 minutes when stacks plan |
| Read the plans | `gh pr view --comments` | Read the PR's comment that starts with `<!-- ci-summary -->`; each row links to its plan job, whose summary holds the full plan |
| Merge | `gh pr merge --squash --match-head-commit <sha> --delete-branch` | Squash-merge with the head commit's SHA as the expected head; the repository deletes the branch |
| Check the apply | `gh run list --branch main --limit 5` | List workflow runs for the merge commit (`GET /repos/{owner}/{repo}/actions/runs?head_sha=<sha>`) |
