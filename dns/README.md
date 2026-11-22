# dns
[OpenTofu](https://opentofu.org) management of the DNS zones and records for my personal domains on Cloudflare.

# Dependencies
* [Nix](https://nixos.org) + [devenv](https://devenv.sh)
* [direnv](https://direnv.net)
* `op` -- 1Password CLI
* AWS credentials for the S3 state bucket (`aws/state-bucket`)

# Usage
`direnv allow` once, to load the devenv shell and the Cloudflare credentials from 1Password.

```sh
tofu init
tofu plan
tofu apply
```

Nothing applies automatically on merge.

# Layout
* `main.tf` -- provider, backend, zones, and the record resource.
* `<zone>.tf` -- one map of records per zone. Add or change a record there.

Only records listed in these maps are managed. Anything else in a zone (external-dns, cert-manager, and DDNS records) is left alone.
