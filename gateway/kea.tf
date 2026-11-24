# Kea DHCPv4 configuration on lga2, imported from the live gateway.
# Generated from the Kea API; keep in sync with the appliance.
# Kea is stopped on both sites: dnsmasq serves DHCP and DNS, and its hosts and
# ranges are managed in dnsmasq.tf. These objects are dormant configuration, so
# a GUI edit shows up as a plan diff.

locals {
  lga2_kea_subnets = {
    "192.168.239.0/24" = {
      uuid            = "baab919b-ba64-4dce-b695-085ade996cc3"
      subnet          = "192.168.239.0/24"
      pools           = "192.168.239.100-192.168.239.200"
      routers         = ["192.168.239.254"]
      dns_servers     = ["1.1.1.1", "1.0.0.1"]
      ntp_servers     = ["192.168.239.254"]
      auto_collect    = false
      match_client_id = true
      ping_check      = false
    }
  }

  lga2_kea_reservations = {
    "192.168.239.53" = {
      uuid        = "a5305a52-c1ca-44a2-9342-1250d86be0ee"
      ip_address  = "192.168.239.53"
      hw_address  = "00:06:78:70:48:94"
      hostname    = "avr"
      description = "Denon-AVR-S760H eth"
    }
    "192.168.239.2" = {
      uuid        = "1f0b49ed-376a-4aa9-b6ac-be2fbdb8554d"
      ip_address  = "192.168.239.2"
      hw_address  = "00:1e:06:33:da:2c"
      hostname    = "odroid"
      description = "pi-hole"
    }
    "192.168.239.47" = {
      uuid        = "3ebe0f69-3188-43ab-bb37-09e197699642"
      ip_address  = "192.168.239.47"
      hw_address  = "00:24:9b:09:72:d3"
      hostname    = "switch-dock"
      description = "Switch dock ethernet adapter"
    }
    "192.168.239.114" = {
      uuid        = "047c785a-c4a6-4056-a82b-325dcd9c3956"
      ip_address  = "192.168.239.114"
      hw_address  = "04:99:b9:9d:84:55"
      hostname    = "living-room-3"
      description = "Home Pod - Living Room"
    }
    "192.168.239.110" = {
      uuid        = "9b1afe81-c0bd-4092-b4ad-a2bbaea1bc9e"
      ip_address  = "192.168.239.110"
      hw_address  = "04:99:b9:97:0f:02"
      hostname    = "bathroom"
      description = "Home Pod - Bathroom"
    }
    "192.168.239.104" = {
      uuid        = "895b73ec-fa6f-4858-be72-0a98a253b2e8"
      ip_address  = "192.168.239.104"
      hw_address  = "7c:e1:ff:04:88:c9"
      hostname    = "electabuzz"
      description = "Digital Loggers Smart Power Switch"
    }
    "192.168.239.100" = {
      uuid        = "1396f113-346c-4431-bbd8-0dec2d64c3a7"
      ip_address  = "192.168.239.100"
      hw_address  = "24:2f:d0:b9:9e:1d"
      hostname    = "tplink-s505-bedroom"
      description = "smart light switch"
    }
    "192.168.239.23" = {
      uuid        = "53e0ad0f-ec05-4159-a848-d488c86c1af1"
      ip_address  = "192.168.239.23"
      hw_address  = "24:41:FE:73:67:03"
      hostname    = "cr1000a"
      description = "Verizon Router CR1000A WAN port"
    }
    "192.168.239.253" = {
      uuid        = "4453d30b-6191-43d2-98d0-f06eb0a1a275"
      ip_address  = "192.168.239.253"
      hw_address  = "24:41:FE:73:67:04"
      hostname    = "cr1000a"
      description = "Verizon Router CR1000A LAN port"
    }
    "192.168.239.48" = {
      uuid       = "960d66ae-5062-44b7-84c0-60c0345f3167"
      ip_address = "192.168.239.48"
      hw_address = "48:a5:e7:39:f3:d1"
      hostname   = "switch-acnh"
    }
    "192.168.239.139" = {
      uuid        = "c82f4a15-65c8-41d2-913b-efb055f70f10"
      ip_address  = "192.168.239.139"
      hw_address  = "64:cb:e9:2c:4f:82"
      hostname    = "lgwebostv"
      description = "LG C1"
    }
    "192.168.239.7" = {
      uuid       = "7acab460-bac0-4e12-9476-3d96895203aa"
      ip_address = "192.168.239.7"
      hw_address = "80:2a:a8:59:8f:94"
      hostname   = "uap-ac-pro"
    }
    "192.168.239.116" = {
      uuid        = "21bfbb74-9202-4795-a000-dbc7959a65ca"
      ip_address  = "192.168.239.116"
      hw_address  = "90:dd:5d:9a:b8:66"
      hostname    = "living-room"
      description = "Apple TV - Living Room"
    }
    "192.168.239.109" = {
      uuid        = "ad30e109-7bcb-4004-8e71-45554dccf6ee"
      ip_address  = "192.168.239.109"
      hw_address  = "ac:bc:b5:e6:dc:af"
      hostname    = "bedroom"
      description = "Home Pod - Bedroom"
    }
    "192.168.239.101" = {
      uuid        = "5477da99-ed61-41be-813a-b27e38e56d21"
      ip_address  = "192.168.239.101"
      hw_address  = "c8:db:26:05:23:15"
      hostname    = "harmonyhub"
      description = "Harmony Hub"
    }
    "192.168.239.107" = {
      uuid       = "cc851ee6-8b58-43fb-bd80-88e3dcf2ee11"
      ip_address = "192.168.239.107"
      hw_address = "cc:40:85:3e:84:5c"
      hostname   = "wiz3e845c"
    }
    "192.168.239.145" = {
      uuid       = "704064f8-8b41-4c21-bbf3-acdeb5cc1810"
      ip_address = "192.168.239.145"
      hw_address = "cc:40:85:3f:5b:d2"
      hostname   = "wiz3f5bd2"
    }
    "192.168.239.143" = {
      uuid       = "1d597c5f-4fa6-4dcc-9ce2-07a1b3a94729"
      ip_address = "192.168.239.143"
      hw_address = "cc:40:85:3f:5b:f8"
      hostname   = "wiz3f5bf8"
    }
    "192.168.239.105" = {
      uuid       = "0dffc4c7-0c07-4288-a80a-7b882632901b"
      ip_address = "192.168.239.105"
      hw_address = "cc:40:85:3f:c9:f6"
      hostname   = "wiz3fc9f6"
    }
    "192.168.239.129" = {
      uuid       = "7297da29-b739-426b-a047-5710c13b5e4f"
      ip_address = "192.168.239.129"
      hw_address = "cc:40:85:4a:7f:a0"
      hostname   = "wiz4a7fa0"
    }
    "192.168.239.144" = {
      uuid       = "fc68dbca-dd8d-4007-8209-c5da32b6f740"
      ip_address = "192.168.239.144"
      hw_address = "cc:40:85:36:c9:0e"
      hostname   = "wiz36c90e"
    }
    "192.168.239.106" = {
      uuid       = "3790d2fe-4fec-4c3b-b7d3-8a700b7b2f77"
      ip_address = "192.168.239.106"
      hw_address = "cc:40:85:36:cb:6a"
      hostname   = "wiz36cb6a"
    }
    "192.168.239.123" = {
      uuid       = "539d9c99-cbf0-489b-9e31-35f11e2105a5"
      ip_address = "192.168.239.123"
      hw_address = "cc:40:85:40:12:5a"
      hostname   = "wiz40125a"
    }
    "192.168.239.146" = {
      uuid       = "5d869b73-7a63-4d01-bceb-fd187bf6d8d7"
      ip_address = "192.168.239.146"
      hw_address = "cc:40:85:40:13:80"
      hostname   = "wiz401380"
    }
    "192.168.239.127" = {
      uuid       = "4d6b6993-df2e-4510-b77f-40e3c971daee"
      ip_address = "192.168.239.127"
      hw_address = "cc:40:85:44:98:98"
      hostname   = "wiz449898"
    }
    "192.168.239.128" = {
      uuid       = "160eb6bb-6865-46f2-9396-bfadbabed489"
      ip_address = "192.168.239.128"
      hw_address = "cc:40:85:44:a1:d4"
      hostname   = "wiz44a1d4"
    }
    "192.168.239.156" = {
      uuid       = "639d2de4-7225-443a-8e79-b7adac061aab"
      ip_address = "192.168.239.156"
      hw_address = "dc:68:eb:5c:cf:b6"
      hostname   = "switch-orig"
    }
    "192.168.239.37" = {
      uuid       = "342469a6-0791-49a3-be9e-5abffcb4420e"
      ip_address = "192.168.239.37"
      hw_address = "fc:ec:da:4f:aa:7b"
      hostname   = "us-8-60w"
    }
  }
}

resource "opnsense_kea_dhcpv4_subnet" "lga2_kea_subnets" {
  provider = opnsense.lga2
  for_each = local.lga2_kea_subnets

  subnet          = each.value.subnet
  pools           = try(each.value.pools, null)
  routers         = try(each.value.routers, null)
  dns_servers     = try(each.value.dns_servers, null)
  ntp_servers     = try(each.value.ntp_servers, null)
  domain_name     = try(each.value.domain_name, null)
  domain_search   = try(each.value.domain_search, null)
  description     = try(each.value.description, null)
  auto_collect    = each.value.auto_collect
  match_client_id = each.value.match_client_id
  ping_check      = each.value.ping_check
}

resource "opnsense_kea_dhcpv4_reservation" "lga2_kea_reservations" {
  provider = opnsense.lga2
  for_each = local.lga2_kea_reservations

  subnet_id   = opnsense_kea_dhcpv4_subnet.lga2_kea_subnets["192.168.239.0/24"].id
  ip_address  = each.value.ip_address
  hw_address  = each.value.hw_address
  hostname    = try(each.value.hostname, null)
  client_id   = try(each.value.client_id, null)
  description = try(each.value.description, null)
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_kea_subnets
  to       = opnsense_kea_dhcpv4_subnet.lga2_kea_subnets[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_kea_reservations
  to       = opnsense_kea_dhcpv4_reservation.lga2_kea_reservations[each.key]
  id       = each.value.uuid
}
