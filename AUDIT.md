# Config management audit

What is managed by this repo, what is not, and where the gaps are. Audited against the live
tailnet, the LAN device inventory, and the running cluster.

## Coverage

| Machine | Managed by | Gap |
| --- | --- | --- |
| `knode1`, `knode2`, `odroid-lga1`, `odroid-lga2` | Ansible (`ansible/inventory`) | None. `ansible-playbook site.yaml --check` is clean. |
| `charon-0/1`, `heimdall-0/1`, `exit-lga1` | Argo CD (Tailscale operator proxy pods) | None. |
| `gw-lga1`, `gw-lga2` | `gateway/` OpenTofu | Only Unbound, routes, and gateways. |
| `akane` (laptop) | chezmoi (`nlopez/dotfiles`) | Separate repo. No nix-darwin. |
| `nas1`, `nas2` | Nothing | No IaC, no config backup, no Datadog agent. |
| `uos` (UniFi OS Server, DigitalOcean) | Nothing | No IaC, no config backup, no monitoring. |
| `nas1-ipmi`, `electabuzz` (PDU) | Nothing | BMC and PDU with no management. |

## Gaps

### 1. Unmanaged stateful machines

`nas1` and `nas2` run TrueNAS SCALE 25.10.7 and hold the NFS, SMB, and iSCSI data behind the
cluster's persistent volumes. Neither is in the Ansible inventory. TrueNAS config backups stop at
2021 (the FreeNAS era), and `datadog-agent` is inactive on `nas1`.

`uos` is a DigitalOcean droplet running `uosserver.service` (UniFi OS Server). It has no backup and
no monitoring.

Fix: add both NAS boxes to `ansible/inventory` under `infra`, add a role that exports the TrueNAS
config on a schedule, and install the Datadog agent.

### 2. Gateways are partially managed

`gateway/` covers Unbound query forwards, host overrides, custom gateways, and static routes.
Firewall rules, NAT, DHCP, IDS, Tailscale, SNMP, captive portal, TAYGA, and system settings are
GUI-only. The README says those are "left to the GUI and `config.xml` snapshots", but nothing takes
the snapshots.

Fix: schedule a `config.xml` download from the OPNsense API to the state bucket, or add a
`gateway_backup` role.

### 3. Three OpenTofu projects have no CI apply

`datadog/`, `gateway/`, and `aws/*` are applied by hand. Only `dns/`, `github/`, and `tailnet/` have
workflows. `datadog/` is also missing from the `tofu fmt` pre-commit hook, whose `files:` pattern is
`^(aws|dns|gateway|github|tailnet/tofu)/`.

Fix: add a workflow per project, and add `datadog` to the pre-commit pattern.

### 4. Renovate covers four of seven dependency types

Enabled managers: `custom.regex`, `helm-values`, `github-actions`, `pre-commit`.

Not covered: OpenTofu provider versions (`~> 5.0`, `~> 0.30`, `~> 6.0`), the collections in
`ansible/requirements.yaml`, and `devenv.lock`.

Fix: add `terraform`, `ansible`, and `nix` to `enabledManagers`.

### 5. Repo hygiene

- `kubernetes/apps-helm/cdi/` holds one `values.yaml`. It is not in `bootstrap/apps-helm.yaml` and
  not in Argo CD. Delete it.
- `ansible/group_vars/os_Archlinux` and `os_FreeBSD` have no matching hosts, because the gateways
  are not in the inventory.
- The `forgejo` and `immich` Argo CD applications have `automated.enabled: false` and are currently
  `OutOfSync`.
- There is no root README. The only machine list is the four-host Ansible inventory plus a CSV on
  the desktop.

## Security notes

- Local OpenTofu applies use the Identity Center `AdministratorAccess` permission set
  (`AWS_PROFILE=admin`); the default profile is `ReadOnlyAccess`. Both live in
  `aws/state-bucket/sso.tf`. Root is break-glass only. CI uses the OIDC roles in
  `aws/state-bucket/iam.tf`.
- The tailnet `grants` block allows `*` to `*` on all ports. May be intentional.
- `nas2` rejects Tailscale SSH as root with `operation not permitted` despite matching the ACL.
  `nas1` works. Likely a stale `tailscaled` on `nas2`.
- The `[Synthetics] lga1 WAN ping` monitor is alerting.
