# Local users on both gateways. Existing users keep their live passwords: an
# empty value leaves the password alone on update, and ignore_changes stops
# tofu from pushing one. Users tofu creates (the dns-webhook pair) carry a
# sensitive variable instead.

# Login password for the webhook user. OPNsense requires a non-empty password
# when creating a user; the account's API keypair is generated after apply
# (api/auth/user/addApiKey) and stored in 1Password.
variable "lga1_dns_webhook_password" {
  type      = string
  sensitive = true
}

variable "lga2_dns_webhook_password" {
  type      = string
  sensitive = true
}

# Login password for the pull-request plan user. Nobody logs in as it; OPNsense
# only requires one to create the user.
resource "random_password" "ci_pr" {
  length  = 40
  special = false
}

locals {
  # The pull-request plan user can read the pages tofu manages and nothing
  # else, and user-config-readonly ("System: Deny config write") makes the API
  # reject every config write for it. Left out on purpose: WireGuard (private
  # keys) and backups (the full config.xml). Two gaps the read-only check
  # doesn't cover: service actions (start, stop, restart, reconfigure), and
  # the firmware page, which the provider's Unbound and FRR resources need for
  # version checks and which also allows updates, plugin installs and reboots.
  # Its API keypair is generated after apply (api/auth/user/addApiKey) and
  # stored in the ci-pr vault as gateway-plan.
  ci_pr_privileges = [
    "user-config-readonly",
    "page-diagnostics-logs-settings-targets",
    "page-dhcp-kea-ctrl-agent",
    "page-dhcp-kea-ddns",
    "page-dhcp-kea-v4",
    "page-filter-api",
    "page-firewall-alias-edit",
    "page-firewall-aliases",
    "page-firewall-categories",
    "page-firewall-nat-portforward-edit",
    "page-firewall-trafficshaper",
    "page-firewall-virtualipaddress-edit",
    "page-interfaces-vlan-edit",
    "page-routing",
    "page-services-acmeclient",
    "page-services-dnsforwarder",
    "page-services-dnsresolver-overrides",
    "page-services-monit",
    "page-services-unbound",
    "page-status-interfaces",
    "page-system-advanced-sysctl",
    "page-system-cron",
    "page-system-firmware-manualupdate",
    "page-system-gateways",
    "page-system-staticroutes",
    "page-system-usermanager",
  ]
  ci_pr_user = {
    full_name         = "Pull-request tofu plans"
    uid               = 2002
    group_memberships = []
    privileges        = local.ci_pr_privileges
    password          = random_password.ci_pr.result
  }

  # Privileges the external-dns webhook needs: host override CRUD
  # (api/unbound/settings/*), reconfigure and status (api/unbound/service/*),
  # and the overview page. Names as listed in OPNsense's Unbound ACL model.
  unbound_webhook_privileges = [
    "page-services-dnsresolver-overrides",
    "page-services-unbound",
    "page-status-dnsoverview",
  ]

  lga1_users = {
    root = {
      uuid              = "c30a3fc2-6d75-4ad9-a164-04e1160ffa84"
      uid               = 0
      full_name         = "System Administrator"
      authorized_keys   = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6kTX4+xV3Xdo7QRHMIsZaZABV24Ini0/mcrGUfJeddpWzaD+63lI6h4Y9Pnrb1g/D5hvMUm/7AZ2BDiG+2/rJ3nTBdBqbNZXC5m9lLvn4G1uWDn7XmhBfZcXSv99vTHDzXSnHPLowkAT+CHBvT7ZEJZa5Xsmvtb1AQFZhw1U6DrahyXK09PDP41DImrb1Qb3yjSbyHLMzMZ0xroEVPqh3ncqLQH7+lXAxkt8Rn/GGUguhP71vPJgEOw3f81locrnhVERSErNC7BhxioQvPXQfjgK8ejx3YLo6pUYoELyAosekxeeWGR0ZZbWl6vBTB4rtea/N38HrWYfVTyMsF9u+7WTQoAAOhuQr7JUS+7ezBS+Elsva0rKmPdb5KMkHcEIKCEtxJC1V+gXY1g4Ij15k0/2dbnayn2oLboCI1jND945UEkgpajHMiLf1fgayocpyU8iREv5qFaztiTkCy11tv23W4tXDOESdtcHeTajKx8xj9WK+XzLnIu0A8DXWBCct7VGZEM8kRfa41OEIBQ7KFODpZgqMTGx3qC1gO+WZY3uKo6j/5GU/ZfCFs+6cMR60ctDVAholTCfhv2ihsyMfppm9vciwNw37wXrRT1UrM47pDgjPNJtMfchqzxf0zStIutuxfABzN6PLQGVkO6k2YXiFmzpHK4rr5JZl8RTQ9w==
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvDNgTluafxfN++WnyRNqyVO7LfbvpTY5M6N24Kr9dI
  EOT
      group_memberships = ["1999"]
      privileges        = []
    }
    nlopez = {
      uuid              = "f847a67a-2cba-4f84-b35c-f2022153752a"
      uid               = 2000
      shell             = "/bin/tcsh"
      authorized_keys   = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6kTX4+xV3Xdo7QRHMIsZaZABV24Ini0/mcrGUfJeddpWzaD+63lI6h4Y9Pnrb1g/D5hvMUm/7AZ2BDiG+2/rJ3nTBdBqbNZXC5m9lLvn4G1uWDn7XmhBfZcXSv99vTHDzXSnHPLowkAT+CHBvT7ZEJZa5Xsmvtb1AQFZhw1U6DrahyXK09PDP41DImrb1Qb3yjSbyHLMzMZ0xroEVPqh3ncqLQH7+lXAxkt8Rn/GGUguhP71vPJgEOw3f81locrnhVERSErNC7BhxioQvPXQfjgK8ejx3YLo6pUYoELyAosekxeeWGR0ZZbWl6vBTB4rtea/N38HrWYfVTyMsF9u+7WTQoAAOhuQr7JUS+7ezBS+Elsva0rKmPdb5KMkHcEIKCEtxJC1V+gXY1g4Ij15k0/2dbnayn2oLboCI1jND945UEkgpajHMiLf1fgayocpyU8iREv5qFaztiTkCy11tv23W4tXDOESdtcHeTajKx8xj9WK+XzLnIu0A8DXWBCct7VGZEM8kRfa41OEIBQ7KFODpZgqMTGx3qC1gO+WZY3uKo6j/5GU/ZfCFs+6cMR60ctDVAholTCfhv2ihsyMfppm9vciwNw37wXrRT1UrM47pDgjPNJtMfchqzxf0zStIutuxfABzN6PLQGVkO6k2YXiFmzpHK4rr5JZl8RTQ9w==
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvDNgTluafxfN++WnyRNqyVO7LfbvpTY5M6N24Kr9dI
  EOT
      group_memberships = ["1999"]
      privileges        = []
    }
    # API keypair is generated by OPNsense after apply (api/auth/user/addApiKey)
    # and stored in 1Password; the provider cannot manage it.
    dns-webhook = {
      uuid              = "6084d45b-2339-44d1-a6cc-7683b3060fba"
      full_name         = "external-dns Unbound webhook"
      uid               = 2001
      shell             = "/bin/sh"
      group_memberships = []
      privileges        = local.unbound_webhook_privileges
      password          = var.lga1_dns_webhook_password
    }
    ci-pr = local.ci_pr_user
  }
  lga2_users = {
    root = {
      uuid              = "4a0425de-7790-4778-aa31-d4e8b19a818e"
      uid               = 0
      full_name         = "System Administrator"
      group_memberships = ["1999"]
      privileges        = []
    }
    nlopez = {
      uuid              = "7e167b8c-1c4b-420b-b390-1352fa5ee27e"
      uid               = 2000
      shell             = "/usr/local/bin/bash"
      authorized_keys   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvDNgTluafxfN++WnyRNqyVO7LfbvpTY5M6N24Kr9dI"
      group_memberships = ["1999"]
      privileges        = []
    }
    dns-webhook = {
      uuid              = "c008cc59-155a-42f8-8c70-bc098a056a66"
      full_name         = "external-dns Unbound webhook"
      uid               = 2001
      shell             = "/bin/sh"
      group_memberships = []
      privileges        = local.unbound_webhook_privileges
      password          = var.lga2_dns_webhook_password
    }
    ci-pr = local.ci_pr_user
  }
}

resource "opnsense_auth_user" "lga1" {
  provider = opnsense.lga1
  for_each = local.lga1_users

  name              = each.key
  uid               = each.value.uid
  full_name         = try(each.value.full_name, null)
  shell             = try(each.value.shell, null)
  authorized_keys   = try(each.value.authorized_keys, null)
  group_memberships = each.value.group_memberships
  privileges        = each.value.privileges
  password          = try(each.value.password, "")

  lifecycle {
    ignore_changes = [password]
  }
}

import {
  provider = opnsense.lga1
  for_each = { for name, user in local.lga1_users : name => user if can(user.uuid) }
  to       = opnsense_auth_user.lga1[each.key]
  id       = each.value.uuid
}

resource "opnsense_auth_user" "lga2" {
  provider = opnsense.lga2
  for_each = local.lga2_users

  name              = each.key
  uid               = each.value.uid
  full_name         = try(each.value.full_name, null)
  shell             = try(each.value.shell, null)
  authorized_keys   = try(each.value.authorized_keys, null)
  group_memberships = each.value.group_memberships
  privileges        = each.value.privileges
  password          = try(each.value.password, "")

  lifecycle {
    ignore_changes = [password]
  }
}

import {
  provider = opnsense.lga2
  for_each = { for name, user in local.lga2_users : name => user if can(user.uuid) }
  to       = opnsense_auth_user.lga2[each.key]
  id       = each.value.uuid
}
