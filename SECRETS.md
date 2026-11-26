# Secrets

Nothing secret is committed. Every credential lives in 1Password (account `my.1password.com`) and
the repo holds only `op://<vault>/<item>/<field>` references, by vault and item ID. This page maps
those IDs to what they are, who can read them, and how to rotate them.

Each vault's name is its name in 1Password.

## Vaults

| Vault ID | Name | Read by | Holds | Referenced from |
| --- | --- | --- | --- | --- |
| `6foq5pqns6uslgstwbfoyyyftu` | `ci-pr` | `OP_CI_PR_SERVICE_ACCOUNT_TOKEN` (repository secret), in every PR | Read-only credentials for pull-request plans and the tailnet ACL test | `<stack>/secrets.plan.env`, `.github/workflows/tailnet.yaml` |
| `kjgjpiwjlognsprl7qxsonrqoi` | `ci` | `OP_SERVICE_ACCOUNT_TOKEN` (`production` environment secret), on `main` only | CI copies of operator-vault items, for applies; the Discord webhook; the read-only Argo CD `ci` token | `<stack>/secrets.env` of the CI-applied stacks, `ansible/secrets.env`, `.github/actions/discord-notify`, `.github/workflows/kubernetes-sync-check.yaml` |
| `eirjdyavzyx7tegpglsc2udq3a` | `operator` | The operator, through the 1Password app | Originals of the items copied to `ci`; NAS, `arr`, and Ansible host credentials | `truenas/secrets.env`, `arr/secrets.env`, `ansible/group_vars/infra`, `ansible/scripts/device_inventory.py` |
| `evjh25ux2mnoufaut6qhvm2pdi` | `Automation` | 1Password Connect in the cluster; the operator | Every Kubernetes secret (`OnePasswordItem`), plus a few operator-only items | `kubernetes/**` (`itemPath: vaults/…`), `github/secrets.env`, `arr/secrets.env` |
| `bamv726zv6zbcfke3cnbwjtnuu` | `Private` | The operator | The 1Password Connect credentials and token, used once at cluster bootstrap | `kubernetes/README.md` |

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
- **Local applies** (`github/`, and break-glass for the rest) go through the
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

## Asking for a credential

Agents can't create credentials: most need an operator login (Argo CD admin, a NAS, the GitHub
settings page), and writing to 1Password needs the operator's approval in the 1Password app. A
cloud agent asks an agent on the operator's machine (a Remote Control session), and the operator
approves its 1Password prompts. Ask once, for everything the task needs, so the operator approves
one batch.

Say for each credential:

- what it's for (the workflow or stack), and that it must be read-only if it's for a plan;
- exactly how to create it: the command, or for a token made in a browser, every permission and
  its scope. Pre-filled token links don't always set every permission (a GitHub fine-grained
  token link missed Variables and Webhooks), so the operator checks the page by hand;
- the vault (`ci-pr` for pull-request plans, `ci` for applies and other runs on `main`), a new
  item's title, and the field name;
- an expiry (one year unless the provider forces less), written in the item's notes;
- the checks to run with it: one read that must succeed, and one harmless write that must be
  refused (a dry-run sync, an empty `PATCH`). A credential that can write where it should only
  read is the failure that matters;
- what to report back: item ID, field, expiry, and each check's result. Never the value.

Don't generate a credential that has nowhere to go yet: a token shown only once (Argo CD's, a
GitHub token's) has to be revoked if it can't be stored. Reference the item by ID in the stack's
`secrets.plan.env` or `secrets.env`, or in the workflow, and record what it is in the table above.

## Rotating a secret

Rotate the original, then every copy: the `ci` copy for CI, and the `ci-pr` credential if
the plan has its own. The comments in each `secrets.env` say which items are copies. Rotating a
service account token means updating the GitHub secret (`OP_CI_PR_SERVICE_ACCOUNT_TOKEN` on the
repository, `OP_SERVICE_ACCOUNT_TOKEN` on `production`), which no stack manages.
