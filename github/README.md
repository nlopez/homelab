# github

[OpenTofu](https://opentofu.org) management of `nlopez/homelab` itself: the repository and its merge, Actions,
and security settings, the `production` environment, the ruleset on `main`, and
the Argo CD push webhook (which makes a push to `main` refresh the Applications
instead of waiting for Argo's poller).

# Dependencies
* [Nix](https://nixos.org) with flakes
* [direnv](https://direnv.net)
* `op` -- 1Password CLI, for the webhook secret
* `gh` -- authenticated as a user that can administer the repository's hooks
* AWS credentials for the S3 state bucket (`aws/state-bucket`)

# Usage
`direnv allow` once at the repo root to load the dev shell (`flake.nix`). Its `tofu` wrapper
resolves the webhook secret in `secrets.env` from 1Password for each run. The
GitHub token comes from `gh`:

```sh
export GITHUB_TOKEN="$(gh auth token)"
tofu init
tofu plan
tofu apply
```

No CI applies this stack: an operator runs `tofu plan` and `tofu apply` after a
change merges. Pull requests do get a plan (`.github/workflows/github.yaml`): the change against
the last applied state, with `-refresh=false`, so it shows what the PR changes but not drift.
The read-only token in `secrets.plan.env` can't see the repository's merge settings, so a
refreshing plan would always show them changing. The webhook is excluded, since its secret
isn't readable there. Run `tofu plan` yourself before applying to see drift. The webhook secret is the 1Password item argocd-server verifies
against.

# Public by default
The repository is public, and `public` defaults to `true`: the visibility, secret
scanning with push protection, and the `main` ruleset all follow from it. Setting
`public = false` makes the repository private and deletes the ruleset, which GitHub
offers on private repositories only on a paid plan (`rulesets = true`). These
settings have no provider support and stay manual in the repository settings:
requiring approval for all outside collaborators' workflow runs, private
vulnerability reporting, and the Actions secrets (`OP_CI_PR_SERVICE_ACCOUNT_TOKEN`
on the repository, `OP_SERVICE_ACCOUNT_TOKEN` on `production`).

# Protecting main
The `main` ruleset requires a pull request that is up to date with `main` and whose
`ci-ok` check passed, a linear history, and signed commits, with no bypass for admins. It exists only when
`public = true` or `rulesets = true`. Set `rulesets = true` to keep the
repository private on a plan that offers rulesets there. Until one of them is
set, nothing enforces the pull request flow in `AGENTS.md`.

Nothing bypasses it, workflows included. GitHub only accepts a GitHub App as a
bypass actor when the app belongs to the repository's owner, and on a user-owned
repository the GitHub Actions app doesn't. So the media-toolbox schedule builds
new releases without committing the new pins (see its workflow).

# The ci-gate app
A pull request's own workflows can post a passing `ci-ok` as GitHub Actions, so the
protected gate reports as a GitHub App instead, from a `pull_request_target` workflow
that runs `main`'s code (see `ci-gate.tf`). Setting it up:

1. `tofu apply` here creates the `ci-gate` environment, deployable only from `main`.
2. `scripts/create-ci-gate-app` creates the app through GitHub's manifest flow (one
   click in the browser), puts its private key in the environment's `CI_GATE_APP_KEY`
   secret and a copy in the `operator` vault, and prints its ID and install link.
3. Install the app on this repository only.
4. Set `ci_gate_app_id` to the printed ID and apply, which sets the `CI_GATE_APP_ID`
   variable.

## The Actions policy that lets it run
Since December 2, 2026, GitHub blocks `pull_request_target` in public repositories
unless an Actions event policy allows it. Without one, the protected gate never runs,
`ci-ok` never posts, and no pull request can merge, including one that would fix it.
The repository has a policy that allows `pull_request_target` for the gate's workflow
only. The provider has no resource for Actions policies yet (checked at
`integrations/github` 6.13.0), so it's set by hand, in Settings → Actions → Policies
or with:

```sh
gh api -X POST repos/nlopez/homelab/actions/policies \
  -H "X-GitHub-Api-Version: 2026-03-10" --input - <<'EOF'
{
  "name": "Allow the protected ci-ok gate",
  "enforcement": "active",
  "conditions": {
    "workflow_path": {
      "include": [".github/workflows/ci-gate-protected.yaml"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "restrict_action_events",
      "parameters": { "allowed_events": ["pull_request_target"] }
    }
  ]
}
EOF
```

`gh api repos/nlopez/homelab/actions/policies` lists it. Renaming or moving the gate's
workflow file needs the policy's `workflow_path` updated first. Move the policy into
this stack once the provider supports it. See
[Securely using pull_request_target](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target).

# Recreating the repository
The `dns` and `tailnet` AWS role trust policies in `aws/state-bucket/iam.tf` match
the OIDC subject `repo:nlopez@20211302/homelab@<repository id>:environment:production`.
A new repository gets a new id, so update it there after the first apply.
