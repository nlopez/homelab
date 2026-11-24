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

No CI applies this stack: an operator runs `tofu plan` and `tofu apply` after a
change merges. The webhook secret is the 1Password item argocd-server verifies
against.
