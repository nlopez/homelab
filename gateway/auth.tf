# The admin and agents-readonly groups and the ACME account on both gateways.
#
# Not managed, and why:
# - Auth users. `password` is required on every write, so managing a user means
#   either committing a password or leaving an empty one that the provider would
#   push on an unrelated update.
# - Trust CAs and certificates. The ACME client owns them (all but one carry an
#   "(ACME Client)" description) and renews them, so an import churns on every
#   renewal. Their private keys are write-only.

resource "opnsense_auth_group" "lga1_admins" {
  provider    = opnsense.lga1
  name        = "admins"
  description = "System Administrators"
  privileges  = ["page-all"]
  members     = ["0", "2000"]
}

resource "opnsense_auth_group" "lga2_admins" {
  provider    = opnsense.lga2
  name        = "admins"
  description = "System Administrators"
  privileges  = ["page-all"]
  members     = ["0", "2000"]
}

locals {
  # Read-only access for agent API keys: every settings and status page an API
  # key can reach whose GET responses carry no secret, plus
  # user-config-readonly so the API rejects every config write. Add an agent's
  # user to the group in the GUI or in users.tf; its API key inherits these.
  #
  # Left out because a GET returns a secret: backups and configuration history
  # (the full config.xml), users and groups (OTP seeds), trust CAs and
  # certificates (private keys), HA sync (password), WireGuard, IPsec and
  # OpenVPN (keys), ACME (DNS API tokens), Monit (mail server password),
  # Tailscale (auth key), wireless (passphrases), and the setup wizard.
  #
  # Included although their models hold a secret field that is empty on both
  # gateways today: aliases (URL table password), virtual IPs (CARP
  # password), Kea DHCPv4/v6 subnets (DDNS TSIG secret), and FRR (BGP neighbor
  # password, OSPF auth key). Setting one of those makes it readable here.
  # Dynamic DNS passwords are write-only in the API.
  #
  # Also left out: firmware, reboot, halt, factory defaults, snapshots, packet
  # capture, state and PF table edits, service control, and logs, which are
  # actions rather than settings or allow clearing. The read-only check
  # doesn't cover service actions (start, stop, restart, reconfigure) on the
  # pages included, the same gap as the ci-pr user in users.tf.
  agent_readonly_privileges = [
    "user-config-readonly",
    "page-dhcp-kea-ctrl-agent",
    "page-dhcp-kea-ddns",
    "page-dhcp-kea-v4",
    "page-dhcp-kea-v6",
    "page-diagnostics-arptable",
    "page-diagnostics-health",
    "page-diagnostics-logs-settings-targets",
    "page-diagnostics-ndptable",
    "page-diagnostics-netflow",
    "page-diagnostics-netstat",
    "page-diagnostics-networkinsight",
    "page-diagnostics-pf-info",
    "page-diagnostics-routingtables",
    "page-diagnostics-system-activity",
    "page-diagnostics-system-statistics",
    "page-filter-api",
    "page-filter-snat-api",
    "page-firewall-aliases",
    "page-firewall-categories",
    "page-firewall-nat-1-1-edit",
    "page-firewall-nat-npt",
    "page-firewall-nat-portforward-edit",
    "page-firewall-trafficshaper",
    "page-firewall-virtualipaddress-edit",
    "page-hostdiscovery",
    "page-interfaces-assignnetworkports",
    "page-interfaces-bridge-edit",
    "page-interfaces-gif-edit",
    "page-interfaces-gre-edit",
    "page-interfaces-groups-edit",
    "page-interfaces-lagg-edit",
    "page-interfaces-loopback",
    "page-interfaces-neighbor",
    "page-interfaces-tap",
    "page-interfaces-vlan-edit",
    "page-interfaces-vxlan",
    "page-routing",
    "page-services-dhcprelay",
    "page-services-dnsforwarder",
    "page-services-dyndns",
    "page-services-ids",
    "page-services-router-advertisements",
    "page-services-unbound",
    "page-status-carp",
    "page-status-dnsoverview",
    "page-status-interfaces",
    "page-system-advanced-firewall",
    "page-system-advanced-network",
    "page-system-advanced-sysctl",
    "page-system-cron",
    "page-system-crlmanager",
    "page-system-gatewaygroups",
    "page-system-gateways",
    "page-system-staticroutes",
    "page-system-status",
    "page-system-trust-settings",
  ]
}

resource "opnsense_auth_group" "lga1_agents_readonly" {
  provider    = opnsense.lga1
  name        = "agents-readonly"
  description = "Agent API keys: read settings, no secrets, no config writes"
  privileges  = local.agent_readonly_privileges
}

resource "opnsense_auth_group" "lga2_agents_readonly" {
  provider    = opnsense.lga2
  name        = "agents-readonly"
  description = "Agent API keys: read settings, no secrets, no config writes"
  privileges  = local.agent_readonly_privileges
}

resource "opnsense_acme_account" "lga1" {
  provider    = opnsense.lga1
  name        = "LE Aethertrail"
  description = ""
  email       = "letsencrypt@aethertrail.com"
  ca          = "letsencrypt"
  enabled     = true
}

resource "opnsense_acme_account" "lga2" {
  provider    = opnsense.lga2
  name        = "LE Aethertrail"
  description = ""
  email       = "letsencrypt@aethertrail.com"
  ca          = "letsencrypt"
  enabled     = true
}

import {
  provider = opnsense.lga1
  to       = opnsense_auth_group.lga1_admins
  id       = "6d49384f-8408-48ec-b419-bb7f6c29c793"
}

import {
  provider = opnsense.lga2
  to       = opnsense_auth_group.lga2_admins
  id       = "4dbef15e-f59d-4757-9a96-22e53b017f94"
}

import {
  provider = opnsense.lga1
  to       = opnsense_acme_account.lga1
  id       = "17b40743-f0ae-47c6-b2ab-93ebb7f7063a"
}

import {
  provider = opnsense.lga2
  to       = opnsense_acme_account.lga2
  id       = "6fdb3fc2-000f-475c-8672-e832893ea0a4"
}

