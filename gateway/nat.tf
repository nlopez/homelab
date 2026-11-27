# NAT port forwards on both gateways, imported from the live gateways.
# Generated from the d_nat API; keep in sync with the appliance.
# Rules with an empty target, local port, or destination are not imported:
# the provider marks those fields required. That excludes 3 of 14 on lga1 and
# the lga2 DNS-redirect exemption (sequence 395).

locals {
  lga1_nat_port_forwards = {
    "100-ingress gateway" = {
      uuid             = "895b0ede-db6b-4667-aa5d-c28ef3803cfe"
      sequence         = 100
      enabled          = true
      ip_protocol      = "inet"
      interface        = "wan"
      protocol         = "tcp/udp"
      target           = "ingress_gateway"
      local_port       = "HTTP_S"
      description      = "ingress gateway"
      source_not       = false
      destination_net  = "wanip"
      destination_port = "HTTP_S"
      destination_not  = false
      log              = false
    }
    "300-qbittorrent - nas1" = {
      uuid             = "92b03497-3bb1-4ee2-8349-2592b9de0e36"
      sequence         = 300
      enabled          = true
      ip_protocol      = "inet"
      interface        = "wan"
      protocol         = "tcp/udp"
      target           = "192.168.222.149"
      local_port       = "43673"
      description      = "qbittorrent - nas1"
      source_not       = false
      destination_net  = "wanip"
      destination_port = "43673"
      destination_not  = false
      log              = false
    }
    "400-qbittorrent - nas2" = {
      uuid             = "3777667c-9d52-4d03-93d6-f1e649bedb75"
      sequence         = 400
      enabled          = true
      ip_protocol      = "inet"
      interface        = "wan"
      protocol         = "tcp/udp"
      target           = "192.168.222.114"
      local_port       = "22890"
      description      = "qbittorrent - nas2"
      source_not       = false
      destination_net  = "wanip"
      destination_port = "22890"
      destination_not  = false
      log              = false
    }
    "600-Plex Media Server" = {
      uuid             = "0c86210a-d0d4-4c60-af95-74572efc8a97"
      sequence         = 600
      enabled          = false
      ip_protocol      = "inet"
      interface        = "wan"
      protocol         = "tcp"
      target           = "pms_host"
      local_port       = "pms_port"
      description      = "Plex Media Server"
      source_not       = false
      destination_net  = "wanip"
      destination_port = "pms_port"
      destination_not  = false
      log              = false
    }
    "700-palworld" = {
      uuid             = "e87a5834-aace-4f2a-8a71-adb022c24ca5"
      sequence         = 700
      enabled          = true
      ip_protocol      = "inet"
      interface        = "wan"
      protocol         = "udp"
      target           = "ingress_gateway"
      local_port       = "palworld"
      description      = "palworld"
      source_not       = false
      destination_net  = "wanip"
      destination_port = "palworld"
      destination_not  = false
      log              = true
    }
    "900-DERP HTTPS Noise" = {
      uuid             = "ebd9fe76-3603-4a64-a976-8c5a323872a4"
      sequence         = 900
      enabled          = false
      ip_protocol      = "inet"
      interface        = "wan"
      protocol         = "tcp"
      target           = "10.43.64.30"
      local_port       = "https"
      description      = "DERP HTTPS Noise"
      source_not       = false
      destination_net  = "wanip"
      destination_port = "8443"
      destination_not  = false
      log              = false
    }
    "1000-DERP STUN" = {
      uuid             = "b1568f01-1d86-48da-92ea-5f3d73ff6d9c"
      sequence         = 1000
      enabled          = false
      ip_protocol      = "inet"
      interface        = "wan"
      protocol         = "udp"
      target           = "10.43.64.30"
      local_port       = "nat-stun-port"
      description      = "DERP STUN"
      source_not       = false
      destination_net  = "wanip"
      destination_port = "3478"
      destination_not  = false
      log              = false
    }
    "400-Redirect LAN DNS to odroid" = {
      uuid             = "4454d04c-ad1a-426a-882f-c11b2eb1c456"
      sequence         = 400
      enabled          = false
      ip_protocol      = "inet"
      interface        = "lan"
      protocol         = "tcp/udp"
      target           = "odroid"
      local_port       = "domain"
      description      = "Redirect LAN DNS to odroid"
      reflection       = "disable"
      source_net       = "any"
      source_not       = false
      destination_net  = "odroid"
      destination_port = "domain"
      destination_not  = true
      log              = false
    }
    "401-Redirect WLAN DNS to odroid" = {
      uuid             = "41d345cb-424e-460b-abf6-5ef9eac7eca8"
      sequence         = 401
      enabled          = false
      ip_protocol      = "inet"
      interface        = "opt1"
      protocol         = "tcp/udp"
      target           = "odroid"
      local_port       = "domain"
      description      = "Redirect WLAN DNS to odroid"
      reflection       = "disable"
      source_net       = "any"
      source_not       = false
      destination_net  = "odroid"
      destination_port = "domain"
      destination_not  = true
      log              = false
    }
    "402-Redirect LAB DNS to odroid" = {
      uuid             = "84745328-dd7b-42c0-9166-105f8bb98782"
      sequence         = 402
      enabled          = false
      ip_protocol      = "inet"
      interface        = "opt2"
      protocol         = "tcp/udp"
      target           = "odroid"
      local_port       = "domain"
      description      = "Redirect LAB DNS to odroid"
      reflection       = "disable"
      source_net       = "dns_steer_exempt"
      source_not       = true
      destination_net  = "odroid"
      destination_port = "domain"
      destination_not  = true
      log              = false
    }
  }
}

resource "opnsense_firewall_nat_port_forward" "lga1_nat_port_forwards" {
  provider = opnsense.lga1
  for_each = local.lga1_nat_port_forwards

  sequence         = each.value.sequence
  enabled          = each.value.enabled
  interface        = try(each.value.interface, null)
  ip_protocol      = each.value.ip_protocol
  protocol         = try(each.value.protocol, null)
  target           = each.value.target
  local_port       = each.value.local_port
  description      = try(each.value.description, null)
  reflection       = try(each.value.reflection, null)
  source_net       = try(each.value.source_net, null)
  source_port      = try(each.value.source_port, null)
  source_not       = each.value.source_not
  destination_net  = each.value.destination_net
  destination_port = each.value.destination_port
  destination_not  = each.value.destination_not
  log              = each.value.log

  lifecycle {
    # The provider defaults ip_protocol to inet but reads an empty value back.
    ignore_changes = [ip_protocol]
  }
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_nat_port_forwards
  to       = opnsense_firewall_nat_port_forward.lga1_nat_port_forwards[each.key]
  id       = each.value.uuid
}

locals {
  lga2_nat_port_forwards = {
    "100-Nintendo Switch dock ethernet adapter" = {
      uuid             = "6a01b67a-953c-4fc2-b1ae-4b001ce65792"
      sequence         = 100
      enabled          = false
      ip_protocol      = "inet"
      interface        = "wan"
      protocol         = "udp"
      target           = "192.168.239.47"
      local_port       = "1024"
      description      = "Nintendo Switch dock ethernet adapter"
      source_not       = false
      destination_net  = "wanip"
      destination_port = "1024-65535"
      destination_not  = false
      log              = false
    }
    "400-Redirect DNS to odroid" = {
      uuid             = "75d9a239-dcc1-471f-851c-d96fe4d09e83"
      sequence         = 400
      enabled          = false
      ip_protocol      = "inet"
      interface        = "lan"
      protocol         = "tcp/udp"
      target           = "odroid"
      local_port       = "domain"
      description      = "Redirect DNS to odroid"
      source_net       = "dns_steer_exempt"
      source_not       = true
      destination_net  = "odroid"
      destination_port = "domain"
      destination_not  = true
      log              = false
      reflection       = "disable"
    }
  }
}

resource "opnsense_firewall_nat_port_forward" "lga2_nat_port_forwards" {
  provider = opnsense.lga2
  for_each = local.lga2_nat_port_forwards

  sequence         = each.value.sequence
  enabled          = each.value.enabled
  interface        = try(each.value.interface, null)
  ip_protocol      = each.value.ip_protocol
  protocol         = try(each.value.protocol, null)
  target           = each.value.target
  local_port       = each.value.local_port
  description      = try(each.value.description, null)
  reflection       = try(each.value.reflection, null)
  source_net       = try(each.value.source_net, null)
  source_port      = try(each.value.source_port, null)
  source_not       = each.value.source_not
  destination_net  = each.value.destination_net
  destination_port = each.value.destination_port
  destination_not  = each.value.destination_not
  log              = each.value.log

  lifecycle {
    # The provider defaults ip_protocol to inet but reads an empty value back.
    ignore_changes = [ip_protocol]
  }
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_nat_port_forwards
  to       = opnsense_firewall_nat_port_forward.lga2_nat_port_forwards[each.key]
  id       = each.value.uuid
}
