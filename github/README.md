# github

[OpenTofu](https://opentofu.org) management of `nlopez/homelab` itself: the repository and its merge, Actions,
and security settings, the `production` environment, the ruleset on `main`, and
the Argo CD push webhook (which makes a push to `main` refresh the Applications
instead of waiting for Argo's poller).

# Dependencies
* [Nix](https://nixos.org) + [devenv](https://devenv.sh)
* [direnv](https://direnv.net)
* `op` -- 1Password CLI, for the webhook secret
* `gh` -- authenticated as a user that can administer the repository's hooks
* AWS credentials for the S3 state bucket (`aws/state-bucket`)

# Usage
`direnv allow` once at the repo root to load the devenv shell. Its `tofu` wrapper
resolves the webhook secret in `secrets.env` from 1Password for each run. The
GitHub token comes from `gh`:

```sh
export GITHUB_TOKEN="$(gh auth token)"
tofu init
tofu plan
tofu apply
```

No CI applies this stack: an operator runs `tofu plan` and `tofu apply` after a
change merges. The webhook secret is the 1Password item argocd-server verifies
against.

# Going public
Set `public = true` (for example `tofu apply -var public=true`). That changes the
repository visibility, turns on secret scanning with push protection, and creates
the `main` ruleset, which GitHub does not offer on private repositories on the free
plan. These settings have no provider support and stay manual in the repository
settings: requiring approval for all outside collaborators' workflow runs, private
vulnerability reporting, and the Actions secrets (`OP_CI_PR_SERVICE_ACCOUNT_TOKEN`
on the repository, `OP_SERVICE_ACCOUNT_TOKEN` on `production`).

# Recreating the repository
The `dns` and `tailnet` AWS role trust policies in `aws/state-bucket/iam.tf` match
the OIDC subject `repo:nlopez@20211302/homelab@<repository id>:environment:production`.
A new repository gets a new id, so update it there after the first apply.
