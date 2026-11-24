# Site gateways

OPNsense configuration for `gw.lga1` and `gw.lga2`, managed with the
[`matthew-on-git/opnsense`](https://registry.terraform.io/providers/matthew-on-git/opnsense)
provider.

## Managed here

- Firewall aliases, categories, and filter rules
- NAT port forwards
- Dnsmasq DNS hosts, DHCP ranges, options, and tags
- Kea DHCPv4 subnets, reservations, and singleton settings (lga2, dormant: Kea is stopped and
  dnsmasq serves DHCP)
- VLANs and virtual IPs
- Custom gateways and static routes
- Unbound query forwards, host overrides, and general settings
- System tunables with a non-default value
- Cron jobs, traffic shaper pipes, and syslog destinations
- FRR/Quagga general settings and BGP (prefix lists, route maps, neighbors, redistribution)
- Monit tests and services
- Auth users, auth groups, ACME accounts, certificate definitions, and DNS-01 validations

## Not managed here

The provider has no resource for these, so they stay in the GUI and are covered by the
`config.xml` backup:

- IDS, Squid, BIND, radvd, captive portal, TAYGA (all disabled or absent)
- Tailscale (enabled on lga1)
- SNMP (enabled on lga1)
- Netflow (enabled on both)
- HA sync (configured on both)
- System general settings (hostname, timezone, SSH, webgui, DNS servers): upstream-blocked

`gateway/scripts/backup-config.sh` downloads both `config.xml` files to
`s3://homelab-tofu-state-546422192262/gateway-backups/` on a daily schedule
(`.github/workflows/gateway-backup.yaml`).

## Provider limitations

- **Pseudo-interfaces do not round-trip.** `opnsense_firewall_filter_rule` reads the interface
  of the TAYGA rule (lga2 sequence 71) back as empty.
- **Auth user passwords.** `password` is required, so it is set to `""` and ignored; OPNsense
  re-hashes only a non-empty password, and the provider never reads one back.
- **Trust CAs and certificates are ACME-owned.** The ACME client creates and renews them, so an
  import churns on every renewal; their private keys are write-only. The ACME account,
  certificate definitions, and DNS-01 validations that produce them are managed here, so the
  pipeline is covered even though its output is not.
- **NAT rules with an empty target.** The provider marks `target`, `local_port`, and
  `destination.network` required, so pass-through rules cannot be imported.
- **`ip_protocol` default.** The provider defaults `ip_protocol` to `inet` but reads an empty
  value back, so every NAT rule shows a permanent diff. Suppressed with
  `lifecycle { ignore_changes = [ip_protocol] }`.
- **`update_freq` on `urljson`.** The provider rejects `update_freq` for `urljson` aliases but
  the live config carries it. Suppressed with `lifecycle { ignore_changes = [update_freq] }`.
- **`enabled` on routes and gateways.** Provider `~> 0.30` never reads it back, so a route
  disabled here would show a permanent diff and fail the apply that tries to write it.

## Running it

Credentials come from the two 1Password items that `ansible/scripts/device_inventory.py`
uses:

```sh
V=op://eirjdyavzyx7tegpglsc2udq3a
export TF_VAR_lga1_api_key="$(op read $V/y5eerewvka7h5hn2cbydqyyyli/key --account my.1password.com)"
export TF_VAR_lga1_api_secret="$(op read $V/y5eerewvka7h5hn2cbydqyyyli/credential --account my.1password.com)"
export TF_VAR_lga2_api_key="$(op read $V/yojhqgnskyosers54jtgsvjhmu/key --account my.1password.com)"
export TF_VAR_lga2_api_secret="$(op read $V/yojhqgnskyosers54jtgsvjhmu/credential --account my.1password.com)"
tofu init && tofu plan
```

State is in the `homelab-tofu-state-546422192262` bucket under `gateway/terraform.tfstate`.
`.github/workflows/gateway.yaml` plans on pull requests and on a daily schedule, and applies on
push to `main`.

## Adding an object

Objects live in `lga1.tf` or `lga2.tf` as `for_each` maps keyed by something
stable (domain, `hostname-rr`, gateway name, network). Each entry carries the
`uuid` that its `import` block uses. To adopt an existing object, read its UUID
from the API, then add both the map entry and the resource attribute if it is a
new field.

Anything the GUI still owns is not imported, so it never shows up as drift.
