# FRR/Quagga BGP, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

locals {
  lga1_bgp_prefix_lists = {
    "bc-any" = {
      uuid        = "de2386f6-d277-4a28-83af-1ca9a4c9b9fe"
      name        = "bc-any"
      action      = "permit"
      network     = "any"
      sequence    = 10
      version     = "IPv4"
      description = "Allow Any"
      enabled     = true
    }
    "bc-any-v6" = {
      uuid        = "034220bf-09af-4596-ac4b-d89410cd3d3a"
      name        = "bc-any-v6"
      action      = "permit"
      network     = "any"
      sequence    = 10
      version     = "IPv6"
      description = "Any IPv6 prefix"
      enabled     = true
    }
  }

  lga1_bgp_route_maps = {
    "Allow-All" = {
      uuid         = "07105833-39ba-44ab-917e-b4bc4f230611"
      name         = "Allow-All"
      action       = "permit"
      order        = 10
      match_prefix = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      enabled      = true
    }
  }

  lga1_bgp_neighbors = {
    "knode2" = {
      uuid                         = "a43d682d-56fc-4d70-9c3e-8efa59e6a870"
      address                      = "192.168.222.144"
      description                  = "knode2"
      update_source                = "opt2"
      family                       = ["ipv4"]
      linked_prefixlist_in         = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      linked_prefixlist_out        = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      linked_routemap_in           = ["07105833-39ba-44ab-917e-b4bc4f230611"]
      linked_routemap_out          = ["07105833-39ba-44ab-917e-b4bc4f230611"]
      remote_as                    = 64512
      enabled                      = false
      next_hop_self                = true
      next_hop_self_all            = false
      multihop                     = false
      route_reflector_client       = false
      soft_reconfiguration_inbound = false
      bfd                          = true
      bfd_strict                   = false
      default_originate            = false
      as_override                  = false
      disable_connected_check      = false
    }
    "knode1" = {
      uuid                         = "2f926a16-09d2-40c3-99f0-b8d1202d8f8c"
      address                      = "192.168.222.143"
      description                  = "knode1"
      update_source                = "opt2"
      family                       = ["ipv4"]
      linked_prefixlist_in         = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      linked_prefixlist_out        = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      linked_routemap_in           = ["07105833-39ba-44ab-917e-b4bc4f230611"]
      linked_routemap_out          = ["07105833-39ba-44ab-917e-b4bc4f230611"]
      remote_as                    = 64512
      enabled                      = false
      next_hop_self                = true
      next_hop_self_all            = false
      multihop                     = false
      route_reflector_client       = false
      soft_reconfiguration_inbound = false
      bfd                          = true
      bfd_strict                   = false
      default_originate            = false
      as_override                  = false
      disable_connected_check      = false
    }
    "knode2-cilium" = {
      uuid                         = "f0ad120b-b7b2-4804-9c51-04984f196ef4"
      address                      = "192.168.222.144"
      description                  = "knode2-cilium"
      family                       = ["ipv4"]
      linked_prefixlist_in         = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      linked_prefixlist_out        = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      linked_routemap_in           = ["07105833-39ba-44ab-917e-b4bc4f230611"]
      linked_routemap_out          = ["07105833-39ba-44ab-917e-b4bc4f230611"]
      remote_as                    = 64514
      enabled                      = true
      next_hop_self                = false
      next_hop_self_all            = false
      multihop                     = false
      route_reflector_client       = false
      soft_reconfiguration_inbound = false
      bfd                          = true
      bfd_strict                   = false
      default_originate            = false
      as_override                  = false
      disable_connected_check      = false
    }
    "knode1-cilium" = {
      uuid                         = "e04a2591-9031-4553-affc-55e5c8366cd9"
      address                      = "192.168.222.143"
      description                  = "knode1-cilium"
      family                       = ["ipv4"]
      linked_prefixlist_in         = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      linked_prefixlist_out        = ["de2386f6-d277-4a28-83af-1ca9a4c9b9fe"]
      linked_routemap_in           = ["07105833-39ba-44ab-917e-b4bc4f230611"]
      linked_routemap_out          = ["07105833-39ba-44ab-917e-b4bc4f230611"]
      remote_as                    = 64514
      enabled                      = true
      next_hop_self                = false
      next_hop_self_all            = false
      multihop                     = false
      route_reflector_client       = false
      soft_reconfiguration_inbound = false
      bfd                          = true
      bfd_strict                   = false
      default_originate            = false
      as_override                  = false
      disable_connected_check      = false
    }
    "knode1-cilium-v6" = {
      uuid                         = "7d0aed1f-cc8d-4585-8876-2ce82818a66d"
      address                      = "fd54:571b:560a:2:d65d:dfff:fe07:5137"
      description                  = "knode1-cilium-v6"
      family                       = ["ipv6"]
      linked_prefixlist_in         = ["034220bf-09af-4596-ac4b-d89410cd3d3a"]
      linked_prefixlist_out        = ["034220bf-09af-4596-ac4b-d89410cd3d3a"]
      remote_as                    = 64514
      enabled                      = true
      next_hop_self                = false
      next_hop_self_all            = false
      multihop                     = false
      route_reflector_client       = false
      soft_reconfiguration_inbound = false
      bfd                          = true
      bfd_strict                   = false
      default_originate            = false
      as_override                  = false
      disable_connected_check      = false
    }
    "knode2-cilium-v6" = {
      uuid                         = "432afef1-36d4-4525-8b52-e860253f9ea0"
      address                      = "fd54:571b:560a:2:21f:c6ff:fe9c:bfd7"
      description                  = "knode2-cilium-v6"
      family                       = ["ipv6"]
      linked_prefixlist_in         = ["034220bf-09af-4596-ac4b-d89410cd3d3a"]
      linked_prefixlist_out        = ["034220bf-09af-4596-ac4b-d89410cd3d3a"]
      remote_as                    = 64514
      enabled                      = true
      next_hop_self                = false
      next_hop_self_all            = false
      multihop                     = false
      route_reflector_client       = false
      soft_reconfiguration_inbound = false
      bfd                          = true
      bfd_strict                   = false
      default_originate            = false
      as_override                  = false
      disable_connected_check      = false
    }
  }

  lga1_bgp_redistributions = {
    "connected" = {
      uuid         = "bb3b8ee2-3f45-4478-aa5d-bcdaed17e881"
      redistribute = "connected"
      description  = "Migrated route redistribution (bgp)"
      enabled      = true
    }
  }

  lga2_bgp_prefix_lists = {
  }

  lga2_bgp_route_maps = {
  }

  lga2_bgp_neighbors = {
  }

  lga2_bgp_redistributions = {
  }

}

resource "opnsense_quagga_prefix_list" "lga1_bgp_prefix_lists" {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_prefix_lists

  name        = each.value.name
  action      = each.value.action
  network     = each.value.network
  sequence    = each.value.sequence
  version     = try(each.value.version, null)
  description = try(each.value.description, null)
  enabled     = each.value.enabled
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_prefix_lists
  to       = opnsense_quagga_prefix_list.lga1_bgp_prefix_lists[each.key]
  id       = each.value.uuid
}

resource "opnsense_quagga_route_map" "lga1_bgp_route_maps" {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_route_maps

  name         = each.value.name
  action       = each.value.action
  order        = each.value.order
  match_prefix = try(each.value.match_prefix, null)
  description  = try(each.value.description, null)
  enabled      = each.value.enabled
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_route_maps
  to       = opnsense_quagga_route_map.lga1_bgp_route_maps[each.key]
  id       = each.value.uuid
}

resource "opnsense_quagga_bgp_neighbor" "lga1_bgp_neighbors" {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_neighbors

  address                      = each.value.address
  description                  = try(each.value.description, null)
  family                       = try(each.value.family, null)
  remote_as                    = try(each.value.remote_as, null)
  local_as                     = try(each.value.local_as, null)
  weight                       = try(each.value.weight, null)
  update_source                = try(each.value.update_source, null)
  link_local_interface         = try(each.value.link_local_interface, null)
  keepalive                    = try(each.value.keepalive, null)
  holddown                     = try(each.value.holddown, null)
  connect_timer                = try(each.value.connect_timer, null)
  remove_private_as            = try(each.value.remove_private_as, null)
  allow_as_in                  = try(each.value.allow_as_in, null)
  attribute_unchanged          = try(each.value.attribute_unchanged, null)
  capabilities                 = try(each.value.capabilities, null)
  linked_prefixlist_in         = try(each.value.linked_prefixlist_in, null)
  linked_prefixlist_out        = try(each.value.linked_prefixlist_out, null)
  linked_routemap_in           = try(each.value.linked_routemap_in, null)
  linked_routemap_out          = try(each.value.linked_routemap_out, null)
  peer_group                   = try(each.value.peer_group, null)
  enabled                      = try(each.value.enabled, null)
  next_hop_self                = try(each.value.next_hop_self, null)
  next_hop_self_all            = try(each.value.next_hop_self_all, null)
  multihop                     = try(each.value.multihop, null)
  route_reflector_client       = try(each.value.route_reflector_client, null)
  soft_reconfiguration_inbound = try(each.value.soft_reconfiguration_inbound, null)
  bfd                          = try(each.value.bfd, null)
  bfd_strict                   = try(each.value.bfd_strict, null)
  default_originate            = try(each.value.default_originate, null)
  as_override                  = try(each.value.as_override, null)
  disable_connected_check      = try(each.value.disable_connected_check, null)
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_neighbors
  to       = opnsense_quagga_bgp_neighbor.lga1_bgp_neighbors[each.key]
  id       = each.value.uuid
}

resource "opnsense_quagga_bgp_redistribution" "lga1_bgp_redistributions" {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_redistributions

  redistribute = each.value.redistribute
  route_map    = try(each.value.route_map, null)
  description  = try(each.value.description, null)
  enabled      = each.value.enabled
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_redistributions
  to       = opnsense_quagga_bgp_redistribution.lga1_bgp_redistributions[each.key]
  id       = each.value.uuid
}

resource "opnsense_quagga_prefix_list" "lga2_bgp_prefix_lists" {
  provider = opnsense.lga2
  for_each = local.lga2_bgp_prefix_lists

  name        = each.value.name
  action      = each.value.action
  network     = each.value.network
  sequence    = each.value.sequence
  version     = try(each.value.version, null)
  description = try(each.value.description, null)
  enabled     = each.value.enabled
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_bgp_prefix_lists
  to       = opnsense_quagga_prefix_list.lga2_bgp_prefix_lists[each.key]
  id       = each.value.uuid
}

resource "opnsense_quagga_route_map" "lga2_bgp_route_maps" {
  provider = opnsense.lga2
  for_each = local.lga2_bgp_route_maps

  name         = each.value.name
  action       = each.value.action
  order        = each.value.order
  match_prefix = try(each.value.match_prefix, null)
  description  = try(each.value.description, null)
  enabled      = each.value.enabled
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_bgp_route_maps
  to       = opnsense_quagga_route_map.lga2_bgp_route_maps[each.key]
  id       = each.value.uuid
}

resource "opnsense_quagga_bgp_neighbor" "lga2_bgp_neighbors" {
  provider = opnsense.lga2
  for_each = local.lga2_bgp_neighbors

  address                      = each.value.address
  description                  = try(each.value.description, null)
  family                       = try(each.value.family, null)
  remote_as                    = try(each.value.remote_as, null)
  local_as                     = try(each.value.local_as, null)
  weight                       = try(each.value.weight, null)
  update_source                = try(each.value.update_source, null)
  link_local_interface         = try(each.value.link_local_interface, null)
  keepalive                    = try(each.value.keepalive, null)
  holddown                     = try(each.value.holddown, null)
  connect_timer                = try(each.value.connect_timer, null)
  remove_private_as            = try(each.value.remove_private_as, null)
  allow_as_in                  = try(each.value.allow_as_in, null)
  attribute_unchanged          = try(each.value.attribute_unchanged, null)
  capabilities                 = try(each.value.capabilities, null)
  linked_prefixlist_in         = try(each.value.linked_prefixlist_in, null)
  linked_prefixlist_out        = try(each.value.linked_prefixlist_out, null)
  linked_routemap_in           = try(each.value.linked_routemap_in, null)
  linked_routemap_out          = try(each.value.linked_routemap_out, null)
  peer_group                   = try(each.value.peer_group, null)
  enabled                      = try(each.value.enabled, null)
  next_hop_self                = try(each.value.next_hop_self, null)
  next_hop_self_all            = try(each.value.next_hop_self_all, null)
  multihop                     = try(each.value.multihop, null)
  route_reflector_client       = try(each.value.route_reflector_client, null)
  soft_reconfiguration_inbound = try(each.value.soft_reconfiguration_inbound, null)
  bfd                          = try(each.value.bfd, null)
  bfd_strict                   = try(each.value.bfd_strict, null)
  default_originate            = try(each.value.default_originate, null)
  as_override                  = try(each.value.as_override, null)
  disable_connected_check      = try(each.value.disable_connected_check, null)
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_bgp_neighbors
  to       = opnsense_quagga_bgp_neighbor.lga2_bgp_neighbors[each.key]
  id       = each.value.uuid
}

resource "opnsense_quagga_bgp_redistribution" "lga2_bgp_redistributions" {
  provider = opnsense.lga2
  for_each = local.lga2_bgp_redistributions

  redistribute = each.value.redistribute
  route_map    = try(each.value.route_map, null)
  description  = try(each.value.description, null)
  enabled      = each.value.enabled
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_bgp_redistributions
  to       = opnsense_quagga_bgp_redistribution.lga2_bgp_redistributions[each.key]
  id       = each.value.uuid
}

