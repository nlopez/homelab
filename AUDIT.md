# Config management audit

What is managed by this repo, what is not, and where the gaps are. Audited against the live
tailnet, the LAN device inventory, and the running cluster. On 2026-11-25 the claims about the repo
itself were corrected against the repo; the claims about live systems were not re-checked.

## Coverage

| Machine | Managed by | Gap |
| --- | --- | --- |
| `knode1`, `knode2`, `odroid-lga1`, `odroid-lga2` | Ansible (`ansible/inventory`) | None. `ansible-playbook site.yaml --check` is clean. |
| `charon-0/1`, `heimdall-0/1`, `exit-lga1` | Argo CD (Tailscale operator proxy pods) | None. |
| `gw-lga1`, `gw-lga2` | `gateway/` OpenTofu | Only Unbound, routes, and gateways. |
| `akane` (laptop) | chezmoi (`nlopez/dotfiles`) | Separate repo. No nix-darwin. |
| `nas1`, `nas2` | `truenas/` OpenTofu, applied locally | No CI apply, no config backup, no Datadog agent. |
| `uos` (UniFi OS Server, DigitalOcean) | Nothing | No IaC, no config backup, no monitoring. |
| `nas1-ipmi`, `electabuzz` (PDU) | Nothing | BMC and PDU with no management. |

## Gaps

### 1. Unmanaged stateful machines

`nas1` and `nas2` run TrueNAS SCALE 25.10.7 and hold the NFS, SMB, and iSCSI data behind the
cluster's persistent volumes. `truenas/` manages their datasets, shares, users, apps, and snapshot
tasks, but only a local apply runs it. Neither is in the Ansible inventory. TrueNAS config backups stop at
2021 (the FreeNAS era), and `datadog-agent` is inactive on `nas1`.

`uos` is a DigitalOcean droplet running `uosserver.service` (UniFi OS Server). It has no backup and
no monitoring.

Fix: add both NAS boxes to `ansible/inventory` under `infra`, add a role that exports the TrueNAS
config on a schedule, and install the Datadog agent.

### 2. Gateways are mostly managed

`gateway/` covers firewall aliases and rules, NAT port forwards, DHCP (dnsmasq and Kea), VLANs and
virtual IPs, routes and gateways, Unbound, tunables, cron, syslog, site-to-site WireGuard, FRR/BGP,
Monit, users, and ACME; `gateway/README.md` lists it all. The provider has no resource for IDS,
Squid, BIND, radvd, captive portal, TAYGA, Tailscale, SNMP, Netflow, HA sync, or system general
settings, so those stay in the GUI. Each gateway uploads its own `config.xml` to Google Drive nightly
through the `os-gdrive-backup` plugin, keeping 60 copies; that plugin setting is GUI-only too.

Gap: the backup lives outside this repo and nothing checks that it still runs. A restore test, or an
alert when the newest copy is more than a day old, would close it.

### 3. Three OpenTofu projects have no CI

`github/`, `truenas/`, and `arr/` have no workflow, so a human plans and applies them locally. Every
other OpenTofu stack plans on pull requests and applies on `main`.

Fix: add a workflow per project. `truenas/` and `arr/` reach LAN hosts, so their jobs need to join
the tailnet as the `gateway/` jobs do; `github/` needs a token that can administer the repository.

### 4. Renovate covers five of seven dependency types

Enabled managers: `custom.regex`, `helm-values`, `github-actions`, `pre-commit`, `terraform`.

Not covered: the collections in `ansible/requirements.yaml`, and `devenv.lock`.

Renovate is not running on this repository yet (as of 2026-11-25), so none of these managers open
updates today, and the media-toolbox version bump still pushes to `main` itself.

Fix: run Renovate, then add `ansible-galaxy` and `nix` to `enabledManagers` and move the
media-toolbox bump to a Renovate regex manager so its GitHub Actions bypass of the `main` ruleset can go.

### 5. Repo hygiene

- `ansible/group_vars/os_Archlinux` and `os_FreeBSD` have no matching hosts, because the gateways
  are not in the inventory.
- There is no machine list beyond the four-host Ansible inventory and a CSV on the desktop. The
  root [README](README.md) lists the stacks, not the machines.

## Security notes

- Local OpenTofu applies use the Identity Center `AdministratorAccess` permission set
  (`AWS_PROFILE=admin`); the default profile is `ReadOnlyAccess`. Both live in
  `aws/state-bucket/sso.tf`. Root is break-glass only. CI uses the OIDC roles in
  `aws/state-bucket/iam.tf`.
- The tailnet `grants` block allows `*` to `*` on all ports. May be intentional.
- `nas2` rejects Tailscale SSH as root with `operation not permitted` despite matching the ACL.
  `nas1` works. Likely a stale `tailscaled` on `nas2`.
- The `[Synthetics] lga1 WAN ping` monitor is alerting.
