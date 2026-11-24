# dns
[OpenTofu](https://opentofu.org) management of the DNS zones and records for my personal domains on Cloudflare.

# Dependencies
* [Nix](https://nixos.org) + [devenv](https://devenv.sh)
* [direnv](https://direnv.net)
* `op` -- 1Password CLI
* AWS credentials for the S3 state bucket (`aws/state-bucket`)

# Usage
`direnv allow` once at the repo root to load the devenv shell. Its `tofu` wrapper
resolves the Cloudflare credentials in `secrets.env` from 1Password for each run.

```sh
tofu init
tofu plan
tofu apply
```

A push to `main` that touches `dns/` runs `tofu apply` in the `DNS` workflow, which
resolves the same `secrets.env` with the `homelab-ci` service account. The Cloudflare
token lives in the `ci` vault so both can read it.

# Layout
* `main.tf` -- provider, backend, zones, and the record resource.
* `<zone>.tf` -- one map of records per zone. Add or change a record there.

Only records listed in these maps are managed. Anything else in a zone (external-dns, cert-manager, and DDNS records) is left alone.
