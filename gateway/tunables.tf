# System tunables with a non-default value, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

locals {
  lga1_tunables = {
    "kern.ipc.maxsockbuf" = {
      uuid        = "3e6ce998-b442-4f23-b140-af97758dad1d"
      value       = "16777216"
      description = "Maximum socket buffer size"
    }
    "net.inet.icmp.drop_redirect" = {
      uuid        = "87e90167-087f-482f-8419-9963136dfa11"
      value       = "1"
      description = "\n        Redirect attacks are the purposeful mass-issuing of ICMP type 5 packets. In a normal network, redirects\n        to the end stations should not be required. This option enables the NIC to drop all inbound ICMP redirect\n        packets without returning a response.\n      "
    }
    "coretemp_load" = {
      uuid        = "5e9f4a04-6122-4815-933a-f821982d030d"
      value       = "YES"
      description = "Intel CPU temperature"
    }
    "net.route.multipath" = {
      uuid        = "661889be-89cc-4d6f-a0b6-ac87ed9d2880"
      value       = "1"
      description = "Enable route multipath"
    }
  }

  lga2_tunables = {
    "net.link.bridge.pfil_member" = {
      uuid        = "5ab7f2fc-87b2-4bd8-8c6d-a666c96a98f2"
      value       = "1"
      description = "Set to 0 to disable filtering on the incoming and outgoing member interfaces."
    }
    "net.link.bridge.pfil_bridge" = {
      uuid        = "e23586df-634a-4d81-bae5-124975d1d82b"
      value       = "0"
      description = "Set to 1 to enable filtering on the bridge interface"
    }
    "net.inet.icmp.drop_redirect" = {
      uuid        = "e6942434-0fe5-4008-9997-f4bbcddca989"
      value       = "1"
      description = "\n        Redirect attacks are the purposeful mass-issuing of ICMP type 5 packets. In a normal network, redirects\n        to the end stations should not be required. This option enables the NIC to drop all inbound ICMP redirect\n        packets without returning a response.\n      "
    }
  }

}

resource "opnsense_system_tunable" "lga1_tunables" {
  provider = opnsense.lga1
  for_each = local.lga1_tunables

  tunable     = each.key
  value       = each.value.value
  description = try(each.value.description, null)
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_tunables
  to       = opnsense_system_tunable.lga1_tunables[each.key]
  id       = each.value.uuid
}

resource "opnsense_system_tunable" "lga2_tunables" {
  provider = opnsense.lga2
  for_each = local.lga2_tunables

  tunable     = each.key
  value       = each.value.value
  description = try(each.value.description, null)
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_tunables
  to       = opnsense_system_tunable.lga2_tunables[each.key]
  id       = each.value.uuid
}

