# tailnet

[OpenTofu](https://opentofu.org) management of the tailnet policy file and the
tailnet-wide DNS settings, using the
[tailscale Terraform provider](https://github.com/tailscale/terraform-provider-tailscale).

# Dependencies
* [Nix](https://nixos.org) + [devenv](https://devenv.sh)
* [direnv](https://direnv.net)
* `op` -- 1Password CLI
* AWS CLI credentials with access to the S3 state bucket (`aws/state-bucket`).
  The backend reads them from the AWS CLI, so there is nothing to set in
  `.envrc`.
* The Tailscale OAuth client the ACL apply workflow already used, expanded with
  the `dns` and `devices:routes` scopes. It has the `dns`, `policy_file`,
  `devices:core:write`, `devices:routes:write` and `devices:posture_attributes`
  scopes. Its ID and secret are stored in 1Password
  as `Tailscale GitOps` in the `Automation` vault. The pull-request validation
  workflow uses the same client.

# Usage
`direnv allow` once, in `tofu/`, to load the devenv shell and the OAuth client
credentials from 1Password.

```sh
cd tofu
tofu init
tofu plan
tofu apply
```

Pull requests validate the policy file with `tailscale/gitops-acl-action`. A
push to `main` that touches `tailnet/` runs `tofu apply` in the `Tailnet`
workflow, which needs `TS_OAUTH_ID`, `TS_OAUTH_SECRET` and `TS_TAILNET` in the
`production` environment. AWS access comes from the `homelab-tailnet-apply`
role, assumed through GitHub's OIDC provider; both are defined in
`aws/state-bucket/iam.tf`.

# Layout
* `policy.hujson` -- the tailnet policy file. Edited by hand, in HuJSON, so
  comments and the `tests` block are kept.
* `tofu/` -- the OpenTofu project. `acl.tf` uploads `policy.hujson`; `dns.tf`
  holds the tailnet-wide DNS configuration; `devices.tf` tags the gateways and
  approves their subnet routes.

# Not managed here
* The subnet routes a device advertises. The devices advertise their own site
  ranges: the odroids take their list from `tailscale_advertise_routes` in
  `ansible/host_vars/`, and each site's OPNsense gateway runs
  `tailscale set --advertise-routes`. Approving them is managed here, in both
  the `autoApprovers` block of `policy.hujson` and the
  `tailscale_device_subnet_routes` resources in `devices.tf`. The block only
  auto-approves what a device advertises later, so it does not cover the IPv6
  ranges a node is already advertising; the resources enable the full set on
  every node.
* Exit nodes and per-device settings pushed by the Ansible role in
  `ansible/roles/tailscale/`.
* Per-device settings pushed by the Ansible role in `ansible/roles/tailscale/`.
