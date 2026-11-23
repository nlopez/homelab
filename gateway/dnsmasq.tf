# Dnsmasq DNS hosts, DHCP ranges, options, and tags, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

locals {
  lga1_dnsmasq_hosts = {
    "knode1-192_168_222_143" = {
      uuid        = "14fec44f-ba5a-4609-bdcf-e1d6fe71bf46"
      host        = "knode1"
      ip          = "192.168.222.143"
      hwaddr      = "d4:5d:df:07:51:37"
      description = "k8s"
      local       = false
      ignore      = false
    }
    "knode2-192_168_222_144" = {
      uuid        = "af686d60-23e8-454e-a14c-1c6185c27361"
      host        = "knode2"
      ip          = "192.168.222.144"
      hwaddr      = "00:1f:c6:9c:bf:d7"
      description = "k8s"
      local       = false
      ignore      = false
    }
    "electabuzz-192_168_221_139" = {
      uuid        = "ef755fe2-7b8c-4c1e-bc89-f58340122e50"
      host        = "electabuzz"
      ip          = "192.168.221.139"
      hwaddr      = "7C:E1:FF:04:88:C9"
      description = "Web PDU"
      local       = false
      ignore      = false
    }
    "odroid-192_168_222_2" = {
      uuid      = "a6aaf18a-fbf1-4633-ac4f-1a7ee15a1e33"
      host      = "odroid"
      ip        = "192.168.222.2"
      hwaddr    = "00:1e:06:33:da:28"
      client_id = "01:00:1e:06:33:da:28"
      local     = false
      ignore    = false
    }
    "uap-ac-lr-192_168_221_193" = {
      uuid   = "775f2b8c-aece-4f49-b831-302430937d06"
      host   = "uap-ac-lr"
      ip     = "192.168.221.193"
      hwaddr = "fc:ec:da:f3:5b:e4"
      local  = false
      ignore = false
    }
    "nas1-192_168_222_149" = {
      uuid        = "73cfc37b-6c28-49a2-8220-ab6c68709651"
      host        = "nas1"
      ip          = "192.168.222.149"
      domain      = "lga1.radoncanyon.com"
      description = "static PTR"
      local       = false
      ignore      = false
    }
    "nas2-192_168_222_114" = {
      uuid        = "5f4f800a-4cf4-4d24-9094-611d5791ed1f"
      host        = "nas2"
      ip          = "192.168.222.114"
      domain      = "lga1.radoncanyon.com"
      description = "static PTR"
      local       = false
      ignore      = false
    }
    "nas1-ipmi-192_168_222_113" = {
      uuid        = "1f91551c-bb90-4d9a-91b5-a9246596207e"
      host        = "nas1-ipmi"
      ip          = "192.168.222.113"
      hwaddr      = "00:25:90:9f:c2:7d"
      description = "nas1 IPMI"
      local       = false
      ignore      = false
    }
    "nest-192_168_223_128" = {
      uuid   = "6edc3e42-e3be-47d4-8dad-aac43ccf20f9"
      host   = "nest"
      ip     = "192.168.223.128"
      hwaddr = "18:b4:30:56:97:06"
      local  = false
      ignore = false
    }
    "tuya-1-192_168_223_139" = {
      uuid   = "8c0d5bca-67b1-49fc-a935-1ea4c4e0f178"
      host   = "tuya-1"
      ip     = "192.168.223.139"
      hwaddr = "fc:3c:d7:29:93:4d"
      local  = false
      ignore = false
    }
    "irobot-192_168_223_147" = {
      uuid   = "6099bd0e-f93b-41fe-a4ac-74a32d54a5f9"
      host   = "irobot"
      ip     = "192.168.223.147"
      hwaddr = "4c:b9:ea:f8:8c:4e"
      local  = false
      ignore = false
    }
    "echo-1-192_168_223_188" = {
      uuid   = "26297273-d8ec-4b6c-9093-c9a65d860330"
      host   = "echo-1"
      ip     = "192.168.223.188"
      hwaddr = "ac:41:6a:7b:ec:05"
      local  = false
      ignore = false
    }
  }

  lga1_dnsmasq_ranges = {
    "opt1-192.168.223.100-0" = {
      uuid          = "5a6a4472-246a-407d-9183-cab44606fd1c"
      start_address = "192.168.223.100"
      end_address   = "192.168.223.200"
      interface     = "opt1"
      subnet_mask   = "255.255.255.0"
      domain_type   = "interface"
      domain        = "lga1.radoncanyon.com"
      lease_time    = 28800
      no_sync       = false
    }
    "opt2-192.168.222.100-1" = {
      uuid          = "d4e4308e-6fee-447e-bd5e-827cfba483f6"
      start_address = "192.168.222.100"
      end_address   = "192.168.222.200"
      interface     = "opt2"
      domain_type   = "interface"
      domain        = "lga1.radoncanyon.com"
      lease_time    = 28800
      no_sync       = false
    }
    "lan-192.168.221.100-2" = {
      uuid          = "57744957-8aec-4d49-97ab-1f92ff13fa6d"
      start_address = "192.168.221.100"
      end_address   = "192.168.221.200"
      interface     = "lan"
      domain_type   = "interface"
      domain        = "lga1.radoncanyon.com"
      lease_time    = 28800
      no_sync       = false
    }
    "opt2-::-3" = {
      uuid          = "09cc44fe-3d62-46f9-ac77-9f6e1d6fc5fa"
      start_address = "::"
      interface     = "opt2"
      constructor   = "opt2"
      domain_type   = "interface"
      domain        = "lga1.radoncanyon.com"
      ra_mode       = ["slaac", "ra-names"]
      lease_time    = 28800
      no_sync       = false
    }
    "lan-::-4" = {
      uuid          = "78f241aa-6dc5-4ff5-ba25-34cbeb4d33df"
      start_address = "::"
      interface     = "lan"
      constructor   = "lan"
      domain_type   = "interface"
      domain        = "lga1.radoncanyon.com"
      ra_mode       = ["slaac", "ra-names"]
      lease_time    = 28800
      no_sync       = false
    }
    "opt1-::-5" = {
      uuid          = "ce7edd34-1f11-4e97-8388-e0cd84d65178"
      start_address = "::"
      interface     = "opt1"
      constructor   = "opt1"
      domain_type   = "interface"
      domain        = "lga1.radoncanyon.com"
      ra_mode       = ["slaac", "ra-names"]
      lease_time    = 28800
      no_sync       = false
    }
  }

  lga1_dnsmasq_options = {
  }

  lga1_dnsmasq_tags = {
    "disabled" = {
      uuid = "034e91c3-f605-45e5-9894-7cba9901493d"
      tag  = "disabled"
    }
  }

  lga2_dnsmasq_hosts = {
    "gw-192_168_239_254" = {
      uuid   = "72d80c43-dbe0-40d9-a85a-168d34a5092e"
      host   = "gw"
      ip     = "192.168.239.254"
      domain = "lga2.radoncanyon.com"
      local  = true
      ignore = false
    }
    "watch-" = {
      uuid   = "7f529d12-564f-4c1f-89d5-69981c76e6bc"
      host   = "watch"
      ip     = ""
      domain = "lga2.radoncanyon.com"
      hwaddr = "b6:3c:0a:db:04:29"
      local  = true
      ignore = false
    }
    "raphael-" = {
      uuid   = "1e2ab8ae-a853-4c8c-b397-4febb9ef15ff"
      host   = "raphael"
      ip     = ""
      domain = "lga2.desertbluffs.com"
      hwaddr = "c8:7f:54:09:59:f0"
      local  = true
      ignore = false
    }
    "shimmer-" = {
      uuid        = "1409dc01-69b2-4f23-b8a3-e3dd510de0eb"
      host        = "shimmer"
      ip          = ""
      domain      = "lga2.desertbluffs.com"
      hwaddr      = "14:d4:24:71:3c:07"
      description = "Steam Deck Wireless"
      local       = true
      ignore      = false
    }
    "harmony-hub-" = {
      uuid   = "afc6cd16-507b-4b15-be88-d31981bc3d03"
      host   = "harmony-hub"
      ip     = ""
      domain = "lga2.desertbluffs.com"
      hwaddr = "c8:db:26:05:23:15"
      local  = true
      ignore = false
    }
    "homepod-bedroom-" = {
      uuid   = "8a3534fa-0457-4d67-a6e8-a0b051b15cfd"
      host   = "homepod-bedroom"
      ip     = ""
      domain = "lga2.desertbluffs.com"
      hwaddr = "ac:bc:b5:e6:dc:af"
      local  = true
      ignore = false
    }
    "homepod-living-room-" = {
      uuid   = "a87261bf-9bdb-487d-ab2d-039ed76e15dc"
      host   = "homepod-living-room"
      ip     = ""
      domain = "lga2.desertbluffs.com"
      hwaddr = "04:99:b9:9d:84:55"
      local  = true
      ignore = false
    }
    "homepod-washroom-" = {
      uuid   = "11b0e15b-ce5b-4041-975c-010cd4386167"
      host   = "homepod-washroom"
      ip     = ""
      domain = "lga2.desertbluffs.com"
      hwaddr = "04:99:b9:97:0f:02"
      local  = true
      ignore = false
    }
    "ipad-" = {
      uuid   = "f96713b6-ca66-423b-92a0-86edd0d7e971"
      host   = "ipad"
      ip     = ""
      domain = "lga2.radoncanyon.com"
      hwaddr = "e2:6d:85:3d:a8:71"
      local  = true
      ignore = false
    }
    "switch-ac-wifi-" = {
      uuid        = "eb3ebd5c-886b-4a04-a930-1bff22e30eb9"
      host        = "switch-ac-wifi"
      ip          = ""
      domain      = "lga2.radoncanyon.com"
      hwaddr      = "48:a5:e7:39:f3:d1"
      description = "Animal Crossing Switch Wireless"
      local       = true
      ignore      = false
    }
    "intelol-" = {
      uuid        = "c4e9f6a6-0360-412b-b308-15e0a597baae"
      host        = "intelol"
      ip          = ""
      domain      = "lga2.radoncanyon.com"
      hwaddr      = "b2:fe:83:54:37:45"
      description = "Personal Laptop"
      local       = true
      ignore      = false
    }
    "unifi-sw8-" = {
      uuid   = "1a551afc-ea86-4658-a4cc-08d31a248d67"
      host   = "unifi-sw8"
      ip     = ""
      domain = "lga2.radoncanyon.com"
      hwaddr = "fc:ec:da:4f:aa:7b"
      local  = true
      ignore = false
    }
    "odroid-192_168_239_2" = {
      uuid        = "48bcd66f-b53e-4731-a28c-9ee4192d330e"
      host        = "odroid"
      ip          = "192.168.239.2"
      domain      = "lga2.radoncanyon.com"
      hwaddr      = "00:1e:06:33:da:2c"
      description = "ODROID"
      local       = true
      ignore      = false
    }
    "unifi-68_183_136_131" = {
      uuid   = "ee44300f-4287-42d7-a14f-4c9fc177b933"
      host   = "unifi"
      ip     = "68.183.136.131"
      local  = true
      ignore = false
    }
  }

  lga2_dnsmasq_ranges = {
    "lan-192.168.239.100-0" = {
      uuid          = "e331fdc3-b0f9-45a5-98ec-f1a5fb77adec"
      start_address = "192.168.239.100"
      end_address   = "192.168.239.249"
      interface     = "lan"
      domain_type   = "interface"
      domain        = "lga2.radoncanyon.com"
      description   = "DHCP"
      lease_time    = 28800
      no_sync       = false
    }
    "lan-::-1" = {
      uuid          = "9ecfd50b-a61d-407b-a0ec-21ee1ea05ab1"
      start_address = "::"
      interface     = "lan"
      constructor   = "lan"
      domain_type   = "interface"
      domain        = "lga2.radoncanyon.com"
      description   = "v6"
      ra_mode       = ["slaac", "ra-names"]
      lease_time    = 28800
      no_sync       = false
    }
  }

  lga2_dnsmasq_options = {
  }

  lga2_dnsmasq_tags = {
    "disabled" = {
      uuid = "9e25bfd7-e82d-42c8-9f40-0f1f36fb0601"
      tag  = "disabled"
    }
  }

}

resource "opnsense_dnsmasq_host" "lga1_dnsmasq_hosts" {
  provider = opnsense.lga1
  for_each = local.lga1_dnsmasq_hosts

  host        = each.value.host
  ip          = each.value.ip
  domain      = try(each.value.domain, null)
  hwaddr      = try(each.value.hwaddr, null)
  client_id   = try(each.value.client_id, null)
  description = try(each.value.description, null)
  comments    = try(each.value.comments, null)
  aliases     = try(each.value.aliases, null)
  lease_time  = try(each.value.lease_time, null)
  set_tag     = try(each.value.set_tag, null)
  cnames      = try(each.value.cnames, null)
  local       = each.value.local
  ignore      = each.value.ignore
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_dnsmasq_hosts
  to       = opnsense_dnsmasq_host.lga1_dnsmasq_hosts[each.key]
  id       = each.value.uuid
}

resource "opnsense_dnsmasq_range" "lga1_dnsmasq_ranges" {
  provider = opnsense.lga1
  for_each = local.lga1_dnsmasq_ranges

  start_address      = each.value.start_address
  end_address        = try(each.value.end_address, null)
  interface          = try(each.value.interface, null)
  subnet_mask        = try(each.value.subnet_mask, null)
  constructor        = try(each.value.constructor, null)
  mode               = try(each.value.mode, null)
  prefix_length      = try(each.value.prefix_length, null)
  lease_time         = try(each.value.lease_time, null)
  domain_type        = try(each.value.domain_type, null)
  domain             = try(each.value.domain, null)
  ra_mode            = try(each.value.ra_mode, null)
  ra_priority        = try(each.value.ra_priority, null)
  ra_mtu             = try(each.value.ra_mtu, null)
  ra_interval        = try(each.value.ra_interval, null)
  ra_router_lifetime = try(each.value.ra_router_lifetime, null)
  description        = try(each.value.description, null)
  set_tag            = try(each.value.set_tag, null)
  no_sync            = each.value.no_sync
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_dnsmasq_ranges
  to       = opnsense_dnsmasq_range.lga1_dnsmasq_ranges[each.key]
  id       = each.value.uuid
}

resource "opnsense_dnsmasq_option" "lga1_dnsmasq_options" {
  provider = opnsense.lga1
  for_each = local.lga1_dnsmasq_options

  type        = each.value.type
  option      = try(each.value.option, null)
  option6     = try(each.value.option6, null)
  interface   = try(each.value.interface, null)
  tag         = try(each.value.tag, null)
  set_tag     = try(each.value.set_tag, null)
  value       = try(each.value.value, null)
  description = try(each.value.description, null)
  force       = each.value.force
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_dnsmasq_options
  to       = opnsense_dnsmasq_option.lga1_dnsmasq_options[each.key]
  id       = each.value.uuid
}

resource "opnsense_dnsmasq_tag" "lga1_dnsmasq_tags" {
  provider = opnsense.lga1
  for_each = local.lga1_dnsmasq_tags

  tag = each.value.tag
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_dnsmasq_tags
  to       = opnsense_dnsmasq_tag.lga1_dnsmasq_tags[each.key]
  id       = each.value.uuid
}

resource "opnsense_dnsmasq_host" "lga2_dnsmasq_hosts" {
  provider = opnsense.lga2
  for_each = local.lga2_dnsmasq_hosts

  host        = each.value.host
  ip          = each.value.ip
  domain      = try(each.value.domain, null)
  hwaddr      = try(each.value.hwaddr, null)
  client_id   = try(each.value.client_id, null)
  description = try(each.value.description, null)
  comments    = try(each.value.comments, null)
  aliases     = try(each.value.aliases, null)
  lease_time  = try(each.value.lease_time, null)
  set_tag     = try(each.value.set_tag, null)
  cnames      = try(each.value.cnames, null)
  local       = each.value.local
  ignore      = each.value.ignore
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_dnsmasq_hosts
  to       = opnsense_dnsmasq_host.lga2_dnsmasq_hosts[each.key]
  id       = each.value.uuid
}

resource "opnsense_dnsmasq_range" "lga2_dnsmasq_ranges" {
  provider = opnsense.lga2
  for_each = local.lga2_dnsmasq_ranges

  start_address      = each.value.start_address
  end_address        = try(each.value.end_address, null)
  interface          = try(each.value.interface, null)
  subnet_mask        = try(each.value.subnet_mask, null)
  constructor        = try(each.value.constructor, null)
  mode               = try(each.value.mode, null)
  prefix_length      = try(each.value.prefix_length, null)
  lease_time         = try(each.value.lease_time, null)
  domain_type        = try(each.value.domain_type, null)
  domain             = try(each.value.domain, null)
  ra_mode            = try(each.value.ra_mode, null)
  ra_priority        = try(each.value.ra_priority, null)
  ra_mtu             = try(each.value.ra_mtu, null)
  ra_interval        = try(each.value.ra_interval, null)
  ra_router_lifetime = try(each.value.ra_router_lifetime, null)
  description        = try(each.value.description, null)
  set_tag            = try(each.value.set_tag, null)
  no_sync            = each.value.no_sync
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_dnsmasq_ranges
  to       = opnsense_dnsmasq_range.lga2_dnsmasq_ranges[each.key]
  id       = each.value.uuid
}

resource "opnsense_dnsmasq_option" "lga2_dnsmasq_options" {
  provider = opnsense.lga2
  for_each = local.lga2_dnsmasq_options

  type        = each.value.type
  option      = try(each.value.option, null)
  option6     = try(each.value.option6, null)
  interface   = try(each.value.interface, null)
  tag         = try(each.value.tag, null)
  set_tag     = try(each.value.set_tag, null)
  value       = try(each.value.value, null)
  description = try(each.value.description, null)
  force       = each.value.force
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_dnsmasq_options
  to       = opnsense_dnsmasq_option.lga2_dnsmasq_options[each.key]
  id       = each.value.uuid
}

resource "opnsense_dnsmasq_tag" "lga2_dnsmasq_tags" {
  provider = opnsense.lga2
  for_each = local.lga2_dnsmasq_tags

  tag = each.value.tag
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_dnsmasq_tags
  to       = opnsense_dnsmasq_tag.lga2_dnsmasq_tags[each.key]
  id       = each.value.uuid
}

