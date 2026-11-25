# homelab

Configuration for my homelab: the Kubernetes cluster, the hosts and gateways it runs on, and the
cloud services around it. Changes land through pull requests; see [AGENTS.md](AGENTS.md) for the
workflow, which people and agents both follow.

## Stacks

| Directory | Manages | On a PR | After merge |
| --- | --- | --- | --- |
| [`ansible/`](ansible) | Host config for `knode1`, `knode2`, `odroid-lga1`, `odroid-lga2` | `ansible-lint` | Manual `Ansible` dispatch; nightly drift check |
| [`kubernetes/`](kubernetes) | Cluster apps through Argo CD: `apps/` (manifests), `apps-helm/` (charts), `bootstrap/` (ApplicationSets) | Hooks, rendered manifest diff | Argo CD syncs |
| [`authentik/`](authentik) | SSO applications, OAuth2 providers, login flows | `tofu plan` | `tofu apply` |
| [`aws/`](aws) | SES (`ses/`) and one SMTP user per app (`*-smtp/`) | `tofu plan` per stack | `tofu apply` |
| [`aws/state-bucket/`](aws/state-bucket) | The OpenTofu state bucket, Identity Center access, CI OIDC roles | `tofu plan` | `tofu apply` |
| [`datadog/`](datadog) | Monitors and synthetics | `tofu plan` | `tofu apply` |
| [`dns/`](dns) | Cloudflare zones and records | `tofu plan` | `tofu apply` |
| [`gateway/`](gateway) | OPNsense on `gw-lga1` and `gw-lga2`: Unbound, routes, WireGuard, API users | `tofu plan` (WireGuard excluded) | `tofu apply` |
| [`tailnet/`](tailnet) | Tailnet policy (`policy.hujson`) and DNS (`tofu/`) | ACL tests, `tofu plan` | `tofu apply` |
| [`tailnet/admin/`](tailnet/admin) | Tailscale OAuth clients and CI federated identities | `tofu plan` | `tofu apply` |
| [`media-toolbox/`](media-toolbox) | Container image for media tools | Image build (on any branch push) | Image push; nightly version bump |
| [`github/`](github) | This repository's settings | None | **Local apply by a human** |
| [`truenas/`](truenas) | `nas1` and `nas2`: datasets, shares, users, apps, snapshots | None | **Local apply by a human** |
| [`arr/`](arr) | Sonarr and Radarr settings | None | **Local apply by a human** |

Every PR also runs `pre-commit` (the commit hooks) and `ci-ok`, which passes only when every other
check passed. Every OpenTofu stack also plans nightly on `main`, and keeps a `Drift in <stack>`
issue open while the live state differs from `main`. OpenTofu state lives in the S3 bucket from `aws/state-bucket`, one key per stack.

## Secrets

Nothing secret is committed. Each OpenTofu stack lists its 1Password references in `secrets.env`;
the dev shell's `tofu` wrapper resolves them with `op run`, and CI resolves them with a 1Password
service account. Pull-request plans use separate read-only credentials, listed in the stack's
`secrets.plan.env`. Kubernetes apps get their secrets from 1Password Connect through `OnePasswordItem`
resources.

## Other docs

- [AGENTS.md](AGENTS.md): how to make a change, from worktree to merged PR.
- [EXPOSURE.md](EXPOSURE.md): what each service exposes to the internet, and split-horizon DNS.
- [CODENAMES.md](CODENAMES.md): unused hostnames for new apps.
- [AUDIT.md](AUDIT.md): what is and isn't managed here, and known gaps.
- [kubernetes/README.md](kubernetes/README.md): cluster bootstrap and disaster recovery.
- [SECURITY.md](SECURITY.md): reporting a vulnerability.

## Dev shell

`direnv allow` (or `devenv shell`) at the root provides OpenTofu, Ansible, `ansible-lint`, and
pre-commit, and installs the hooks.
