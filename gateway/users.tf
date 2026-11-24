# Local users on both gateways. The password is never managed: the provider
# requires the argument, and OPNsense only re-hashes a password when the field
# is non-empty, so an empty value leaves the existing one alone.

locals {
  dns_sync_user = {
    uid               = 2001
    full_name         = "Private DNS sync"
    shell             = "/bin/sh"
    group_memberships = []
    privileges        = []
  }

  lga1_users = {
    dns-sync = local.dns_sync_user
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
  }
  lga2_users = {
    dns-sync = local.dns_sync_user
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
  password          = ""

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
  password          = ""

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
