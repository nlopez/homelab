# github

[OpenTofu](https://opentofu.org) management of the settings on `nlopez/homelab`
that live outside the repository. Right now that is the Argo CD push webhook,
which makes a push to `main` refresh the Applications instead of waiting for
Argo's poller.

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

A push to `main` that touches `github/` runs `tofu apply` in the `GitHub`
workflow, which authenticates to GitHub with the `GITHUB_HOOKS_TOKEN` secret: a
fine-grained token with `Webhooks: write` on this repository. The webhook secret
comes from `ARGOCD_WEBHOOK_SECRET`, the same value argocd-server verifies
against.
