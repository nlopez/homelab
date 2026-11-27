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
- WAN DHCPv6 client settings (prefix request and the WAN's prefix ID)
- Custom gateways and static routes
- Unbound query forwards and general settings
- System tunables with a non-default value
- Cron jobs, traffic shaper pipes, and syslog destinations
- Site-to-site WireGuard: instances, peers, and the global enable
- FRR/Quagga general settings and BGP (prefix lists, route maps, neighbors, redistribution)
- Monit tests and services
- Auth users, auth groups, ACME accounts, certificate definitions, and DNS-01 validations
- Dynamic DNS general settings (native backend on both)

## Not managed here

The provider has no resource for these, so they stay in the GUI and are covered by the
`config.xml` backup:

- IDS, Squid, BIND, radvd, captive portal, TAYGA (all disabled or absent)
- Tailscale (enabled on lga1)
- SNMP (enabled on lga1)
- Netflow (enabled on both)
- HA sync (configured on both)
- Dynamic DNS accounts: `opnsense_ddclient_account` has no `zone` or `interface`, which the
  Cloudflare service needs. Each gateway keeps `<site>.desertbluffs.com` pointed at its WAN
  address (lga1: A; lga2: A and AAAA) with the `ddclient-gw.<site>-cloudflare` token
  (`.github/credentials.yaml`)
- System general settings (hostname, timezone, SSH, webgui, DNS servers): upstream-blocked

Each gateway uploads its own `config.xml` to Google Drive nightly at 01:00 through the
`os-gdrive-backup` plugin (System > Configuration > Backups), keeping 60 copies. The provider
has no resource for that setting either, so it is set in the GUI.

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
- **WireGuard keys.** `private_key` is required and the API reads it and the peer `psk` back,
  so both are sensitive variables sourced from 1Password. The interface assignments (`opt1` on lga2, `opt3` on lga1)
  stay in the GUI.
- **`enabled` on routes and gateways.** Provider `~> 0.30` never reads it back, so a route
  disabled here would show a permanent diff and fail the apply that tries to write it.

## Running it

Credentials are 1Password references in `secrets.env`: the API keys from the two items
that `ansible/scripts/device_inventory.py` uses, the WireGuard keys, and the dns-webhook
user passwords. The root dev shell's (`flake.nix`) `tofu` wrapper resolves them for each run:

```sh
tofu init && tofu plan
```

State is in the `homelab-tofu-state-546422192262` bucket under `gateway/terraform.tfstate`.
A push to `main` that touches `gateway/` runs `tofu apply` in the `Gateway` workflow
(`.github/workflows/gateway.yaml`), as the `homelab-gateway-apply` AWS role. Nothing plans
a change before it merges, so run `tofu plan` locally first. A local plan or apply holds
the state lock, and a workflow run that starts during it fails; re-run it from the
Actions tab.

Local runs need write access to the state bucket: the default SSO profile is read-only,
so set `AWS_PROFILE=admin` for `tofu apply`.

### DNSBL reload

The provider saves Unbound DNSBL settings without rebuilding the blocklist. When an
apply changes a gateway's `opnsense_unbound_dnsbl`, its `terraform_data` refresh calls
`api/unbound/service/dnsbl`, which regenerates the Unbound templates and the list. The
running dnsbl module reloads the list within 60 seconds, without restarting Unbound, so
blocking and allowlist changes can lag the apply by up to a minute. This runs on local
applies and in the workflow alike.

DNSBL allowlist entries are regexes that OPNsense matches from the start of the query
name, so `dnsbl_allowed_domains` in `unbound.tf` lists plain domains and the config turns
each into a pattern that also matches its subdomains.

## Adding an object

Objects live in `lga1.tf` or `lga2.tf` as `for_each` maps keyed by something
stable (domain, `hostname-rr`, gateway name, network). Each entry carries the
`uuid` that its `import` block uses. To adopt an existing object, read its UUID
from the API, then add both the map entry and the resource attribute if it is a
new field. An entry without a `uuid` is a new object: OpenTofu creates it,
and the `import` blocks skip it.

Anything the GUI still owns is not imported, so it never shows up as drift.
