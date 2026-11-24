# Gateway config management coverage

Steps to bring `gw-lga1` and `gw-lga2` under full config management. See
[`../AUDIT.md`](../AUDIT.md) for the audit that produced this list.

Two targets:

- **Provider coverage:** every object the `matthew-on-git/opnsense` provider supports is in
  OpenTofu.
- **Everything else:** the domains the provider cannot manage are backed up and drift-checked
  through `config.xml`.

## Phase 0 — Safety net

- [x] Back up both `config.xml` files nightly to Google Drive (`os-gdrive-backup`, GUI-managed).
- [x] Add `homelab-gateway-apply` IAM role in `aws/state-bucket/iam.tf`.

## Phase 1 — Independent primitives

- [x] Import firewall aliases (26 on lga1, 10 on lga2).
- [x] Import firewall categories (none configured).
- [ ] Import trust CA and certificates. Not viable, and not needed: the issued certificates and
      their CAs are ACME output that renews itself (9 of 10 CAs and both certificates carry an
      "(ACME Client)" description), and private keys are write-only. The config that produces them
      is managed instead, below.
- [x] Import the ACME certificate definitions and their DNS-01 validations (1 of each per
      gateway). Together with the ACME account and the renewal cron job, this is the whole
      certificate pipeline.
- [x] Import auth users (2 per gateway). The password is left alone: the provider requires the
      argument, `password = ""` is set, and OPNsense only re-hashes a password when the field is
      non-empty.
- [x] Import auth groups (1 per gateway).
- [x] Import ACME accounts (1 per gateway).
- [x] Import Kea DHCPv4 subnets and reservations on lga2 (1 subnet, 28 reservations).
- [x] Import the Kea singletons on lga2 (`ctrl_agent`, `ddns_settings`, `dhcpv4_settings`,
      `dhcpv6_settings`).

Kea is stopped on both gateways; dnsmasq serves DHCP and DNS, and its objects are imported in
`dnsmasq.tf`. The Kea objects above are dormant configuration, imported so that a GUI edit to
them shows up as drift. lga1's ISC `dhcpd` sections are inactive for the same reason.
- [x] Import Dnsmasq settings, hosts, ranges, options, tags.
- [x] Import system tunables (4 on lga1, 3 on lga2 have non-default values).

### Dnsmasq objects left unmanaged

The provider cannot round-trip these four objects, so they stay in `config.xml`:

- `lga1` host `gw`: `ip` is a comma-separated pair; the provider reads only the first.
- `lga2` host `avr`: `hwaddr` is a comma-separated pair; the provider reads only the first.
- `lga2` options `set-23-0` and `set-6-1`: the provider normalizes `[::]` and `0.0.0.0` to
  concrete interface addresses on read.

## Phase 2 — Network foundations

- [x] Import VLANs (3 on each).
- [x] Import VIPs (3 on lga1, 1 on lga2).
- [ ] Import interface assignments. Not needed: the interfaces are already assigned and the
      provider's assignment resource is still gated on acceptance proof.
- [x] Import the WireGuard instances and peers on lga1 and lga2.
- [x] Confirm gateways and static routes still plan clean.

## Phase 3 — Edge policy

- [x] Import firewall filter rules on lga1 (31).
- [x] Import firewall filter rules on lga2 (24 of 25; the TAYGA rule does not round-trip).
- [x] Import NAT port forwards on lga1 (11 of 14; 3 have no target and cannot be imported).
- [x] Import NAT port forwards on lga2 (3 of 4; the DNS-redirect exemption has no target).
- [x] Import outbound NAT (none configured).
- [x] Import Quagga/FRR general settings.
- [x] Import Quagga/FRR BGP (2 prefix lists, 1 route map, 6 neighbors, 1 redistribution on lga1).
- [x] OSPF/OSPFv3/RIP are disabled on both gateways; nothing to import.
- [x] Import Monit tests and services (11 tests, 4 services on each).
- [x] Import cron jobs (2 on lga1, 3 on lga2).
- [x] Import traffic shaper pipes (2 on each).
- [x] Import syslog destinations (1 on lga1).

## Phase 4 — Provider-unsupported domains

- [x] Tailscale (enabled on lga1): documented as an exception in `README.md`.
- [x] SNMP (enabled on lga1): documented as an exception in `README.md`.
- [x] Netflow (enabled on both): documented as an exception in `README.md`.
- [x] HA sync (configured on both): documented as an exception in `README.md`.
- [x] IDS, Squid, BIND, radvd, captive portal, TAYGA: documented as not configured.
- [x] System general settings: documented as upstream-blocked.

## Phase 5 — Lock it in

- [x] Enable CI apply for `gateway/` on push to `main`.
- [x] Add the drift check to the schedule.
- [x] Add `terraform` to Renovate's `enabledManagers`.
- [x] Update `gateway/README.md` with the managed/unsupported split.

## Provider bugs found

1. **`config.xml` download lags the API on lga2.** `core/backup/download/this` returns a config
   dated 2026-11-16 with 16 filter rules and 5 NAT rules, while `firewall/filter/searchRule` and
   `firewall/d_nat/search_rule` report 25 and 4. Import and generation use the API. Whether the
   on-disk config is stale is unresolved; the nightly backup would archive the older state.
2. **`ip_protocol` default.** The provider defaults `ip_protocol` to `inet` but reads an empty
   value back, so every NAT rule shows a permanent diff. Suppressed with
   `lifecycle { ignore_changes = [ip_protocol] }`.
3. **`update_freq` on `urljson`.** The provider rejects `update_freq` for `urljson` aliases but
   the live config carries it. Suppressed with `lifecycle { ignore_changes = [update_freq] }`.
