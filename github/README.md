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

# Usage
`direnv allow` once, to load the devenv shell, the GitHub token from `gh` and
the webhook secret from 1Password.

```sh
tofu init
tofu import github_repository_webhook.argocd homelab/<hook id>
tofu plan
tofu apply
```

List the hook ids with `gh api repos/nlopez/homelab/hooks`. State is local and
gitignored, so a machine that has never applied needs the import first.
