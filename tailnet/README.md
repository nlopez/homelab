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
  the `dns` scope. It has the `dns`, `policy_file`, `devices:core:read` and
  `devices:posture_attributes` scopes. Its ID and secret are stored in 1Password
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
  holds the tailnet-wide DNS configuration.

# Not managed here
* Subnet routes and exit nodes. Routes are advertised by the devices themselves
  and approved by the `autoApprovers` block in `policy.hujson`. The odroids take
  their list from `tailscale_advertise_routes` in `ansible/host_vars/`; each
  site's OPNsense gateway advertises the same site ranges with
  `tailscale set --advertise-routes`. Adding a
  `tailscale_device_subnet_routes` resource would duplicate that and drift.
* Per-device settings pushed by the Ansible role in `ansible/roles/tailscale/`.
