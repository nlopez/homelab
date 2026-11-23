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

Nothing applies automatically on merge. Pull requests validate the policy file
with `tailscale/gitops-acl-action`, but the apply happens locally.

# Layout
* `policy.hujson` -- the tailnet policy file. Edited by hand, in HuJSON, so
  comments and the `tests` block are kept.
* `tofu/` -- the OpenTofu project. `acl.tf` uploads `policy.hujson`; `dns.tf`
  holds the tailnet-wide DNS configuration.

# Not managed here
* Subnet routes and exit nodes. Routes are advertised by the devices themselves
  (see `tailscale_advertise_routes` in `ansible/host_vars/`) and approved by the
  `autoApprovers` block in `policy.hujson`. Adding a
  `tailscale_device_subnet_routes` resource would duplicate that and drift.
* Per-device settings pushed by the Ansible role in `ansible/roles/tailscale/`.
