# WAN DHCPv6 client settings, with the fields that keep the WAN up pinned so a
# plan shows them. The provider keeps every omitted assignment field as saved.
# Each gateway asks Verizon for a /56 prefix only and numbers the WAN from it
# with dhcp6_prefix_id, so the WAN gets a global address for the AAAA record.
# The ID must differ from every track6/idassoc6 interface's prefix ID (lga1:
# lan 0, opt1 1, opt2 2; lga2: lan 1).

resource "opnsense_interface_assignment" "lga1_wan" {
  provider = opnsense.lga1

  name                   = "wan"
  enabled                = true
  device                 = "igc1"
  ipv4_mode              = "dhcp"
  ipv6_mode              = "dhcp6"
  dhcp6_prefix_length    = "56"
  dhcp6_prefix_only      = true
  dhcp6_send_prefix_hint = true
  dhcp6_prefix_id        = "0x3"
}

import {
  provider = opnsense.lga1
  to       = opnsense_interface_assignment.lga1_wan
  id       = "wan"
}

resource "opnsense_interface_assignment" "lga2_wan" {
  provider = opnsense.lga2

  name                   = "wan"
  enabled                = true
  device                 = "igc1"
  ipv4_mode              = "dhcp"
  ipv6_mode              = "dhcp6"
  dhcp6_prefix_length    = "56"
  dhcp6_prefix_only      = true
  dhcp6_send_prefix_hint = true
  dhcp6_prefix_id        = "0x0"
}

import {
  provider = opnsense.lga2
  to       = opnsense_interface_assignment.lga2_wan
  id       = "wan"
}
