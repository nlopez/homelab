# Secrets

Nothing secret is committed. Every credential lives in 1Password (account `my.1password.com`) and
the repo holds only `op://<vault>/<item>/<field>` references, by vault and item ID. This page maps
those IDs to what they are, who can read them, and how to rotate them.

The vault names below come from comments in this repo. Where nothing in the repo names a vault, the
name says *unnamed*; fill it in when you know it.

## Vaults

| Vault ID | Name | Read by | Holds | Referenced from |
| --- | --- | --- | --- | --- |
| `6foq5pqns6uslgstwbfoyyyftu` | `ci-pr` | `OP_CI_PR_SERVICE_ACCOUNT_TOKEN` (repository secret), in every PR | Read-only credentials for pull-request plans and the tailnet ACL test | `<stack>/secrets.plan.env`, `.github/workflows/tailnet.yaml` |
| `kjgjpiwjlognsprl7qxsonrqoi` | `ci` | `OP_SERVICE_ACCOUNT_TOKEN` (`production` environment secret), on `main` only | CI copies of operator-vault items, for applies; the Discord webhook | `<stack>/secrets.env` of the CI-applied stacks, `ansible/secrets.env`, `.github/actions/discord-notify` |
| `eirjdyavzyx7tegpglsc2udq3a` | Operator vault, *unnamed* | The operator, through the 1Password app | Originals of the items copied to `ci`; NAS, `arr`, and Ansible host credentials | `truenas/secrets.env`, `arr/secrets.env`, `ansible/group_vars/infra`, `ansible/scripts/device_inventory.py` |
| `evjh25ux2mnoufaut6qhvm2pdi` | `Automation` | 1Password Connect in the cluster; the operator | Every Kubernetes secret (`OnePasswordItem`), plus a few operator-only items | `kubernetes/**` (`itemPath: vaults/…`), `github/secrets.env`, `arr/secrets.env` |
| `bamv726zv6zbcfke3cnbwjtnuu` | *unnamed* | The operator | The 1Password Connect credentials and token, used once at cluster bootstrap | `kubernetes/README.md` |

The `ci` name comes from `tailnet/README.md`, which puts the `Tailscale GitOps` client in the `ci`
vault, the vault `tailnet/tofu/secrets.env` reads it from. The `Automation` name comes from
`authentik/gateway.tf`, which puts the Kubernetes copies of the `gateway-oidc-<app>` secrets in the
`Automation` vault, the vault their `OnePasswordItem`s read.

## Who reads what

- **Pull-request plans** run with `OP_CI_PR_SERVICE_ACCOUNT_TOKEN`, which can read only `ci-pr`.
  Each item there is a read-only credential: a separate API user, OAuth client, or token scoped so
  that a plan can read and nothing can write. `.github/workflows/_tofu-stack.yaml` resolves the
  stack's `secrets.plan.env` with it.
- **Applies on `main`** run in the `production` environment with `OP_SERVICE_ACCOUNT_TOKEN`, which
  reads `ci`. `_tofu-stack.yaml` resolves the stack's `secrets.env` with it, and the
  `Ansible` workflow resolves `ansible/secrets.env`.
- **Local applies** (`github/`, `truenas/`, `arr/`, and break-glass for the rest) go through the
  dev shell's `tofu` wrapper, which runs `op run --env-file secrets.env` with the operator's
  1Password app (`OP_APP_AUTH=1`). Agents have no operator session, so they can't run these.
- **The cluster** reads `evjh…` through 1Password Connect. Each `OnePasswordItem` names its item by
  ID.
- **AWS** needs no stored secret in CI: every workflow assumes an OIDC role from
  `aws/state-bucket/iam.tf`. Locally, `aws/config` uses Identity Center profiles.
- **Tailscale** needs no stored secret to join the tailnet from CI: the federated identities in
  `tailnet/admin/ci.tf` trust the workflow's OIDC token.

## Adding a secret

1. Put the original in the operator vault (or `Automation`, for a Kubernetes secret).
2. If CI applies the stack, add a copy to `ci` and reference it in `<stack>/secrets.env`.
3. If the stack plans on pull requests, create a read-only credential, store it in `ci-pr`, and
   reference it in `<stack>/secrets.plan.env`. If no read-only credential exists for that provider,
   the plan can use a placeholder through `plan-env` in the stack's workflow, as `gateway.yaml` does
   for the WireGuard keys, as long as the plan doesn't need the real value.
4. Never put a credential value in the repo, in a workflow, or in a PR comment.

## Rotating a secret

Rotate the original, then every copy: the `ci` copy for CI, and the `ci-pr` credential if
the plan has its own. The comments in each `secrets.env` say which items are copies. Rotating a
service account token means updating the GitHub secret (`OP_CI_PR_SERVICE_ACCOUNT_TOKEN` on the
repository, `OP_SERVICE_ACCOUNT_TOKEN` on `production`), which no stack manages.
