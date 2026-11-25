# FRR/Quagga BGP on the gateways. lga1 peers with Cilium on both Kubernetes nodes;
# lga2 has BGP enabled with no neighbors.

locals {
  # Entries that share a name form one FRR prefix list, which ends in an implicit deny.
  # A neighbor links a list through any one of its entries.
  lga1_bgp_prefix_lists = {
    "bc-any" = {
      name        = "bc-any"
      action      = "permit"
      network     = "any"
      sequence    = 10
      version     = "IPv4"
      description = "Allow Any"
    }
    # Per-node pod CIDRs (/24s of the cluster pool) and Cilium load balancer addresses.
    "cilium-in-pods" = {
      name        = "cilium-in"
      action      = "permit"
      network     = "10.43.16.0/20 le 24"
      sequence    = 10
      version     = "IPv4"
      description = "Cilium pod CIDRs"
    }
    "cilium-in-lb" = {
      name        = "cilium-in"
      action      = "permit"
      network     = "10.43.64.0/24 le 32"
      sequence    = 20
      version     = "IPv4"
      description = "Cilium LB pool"
    }
    "cilium-in-v6-pods" = {
      name        = "cilium-in-v6"
      action      = "permit"
      network     = "2600:4041:5b21:6b10::/96 le 112"
      sequence    = 10
      version     = "IPv6"
      description = "Cilium pod CIDRs"
    }
    "cilium-in-v6-lb" = {
      name        = "cilium-in-v6"
      action      = "permit"
      network     = "fd54:571b:560a:4364::/112 le 128"
      sequence    = 20
      version     = "IPv6"
      description = "Cilium LB pool"
    }
    "cilium-in-v6-public" = {
      name        = "cilium-in-v6"
      action      = "permit"
      network     = "2600:4041:5b21:6b64::/112 le 128"
      sequence    = 30
      version     = "IPv6"
      description = "Cilium public-v6 LB pool"
    }
    # Cilium does not install routes it learns, so the gateway sends it none.
    "deny-all" = {
      name        = "deny-all"
      action      = "deny"
      network     = "any"
      sequence    = 10
      version     = "IPv4"
      description = "Deny all"
    }
    "deny-all-v6" = {
      name        = "deny-all-v6"
      action      = "deny"
      network     = "any"
      sequence    = 10
      version     = "IPv6"
      description = "Deny all"
    }
  }

  lga1_bgp_neighbors = {
    "knode2" = {
      address        = "192.168.222.144"
      description    = "knode2"
      update_source  = "opt2"
      family         = ["ipv4"]
      prefixlist_in  = "bc-any"
      prefixlist_out = "bc-any"
      remote_as      = 64512
      enabled        = false
      next_hop_self  = true
    }
    "knode1" = {
      address        = "192.168.222.143"
      description    = "knode1"
      update_source  = "opt2"
      family         = ["ipv4"]
      prefixlist_in  = "bc-any"
      prefixlist_out = "bc-any"
      remote_as      = 64512
      enabled        = false
      next_hop_self  = true
    }
    "knode2-cilium" = {
      address        = "192.168.222.144"
      description    = "knode2-cilium"
      family         = ["ipv4"]
      prefixlist_in  = "cilium-in-pods"
      prefixlist_out = "deny-all"
      remote_as      = 64514
      enabled        = true
    }
    "knode1-cilium" = {
      address        = "192.168.222.143"
      description    = "knode1-cilium"
      family         = ["ipv4"]
      prefixlist_in  = "cilium-in-pods"
      prefixlist_out = "deny-all"
      remote_as      = 64514
      enabled        = true
    }
    "knode1-cilium-v6" = {
      address        = "fd54:571b:560a:2:d65d:dfff:fe07:5137"
      description    = "knode1-cilium-v6"
      family         = ["ipv6"]
      prefixlist_in  = "cilium-in-v6-pods"
      prefixlist_out = "deny-all-v6"
      remote_as      = 64514
      enabled        = true
    }
    "knode2-cilium-v6" = {
      address        = "fd54:571b:560a:2:21f:c6ff:fe9c:bfd7"
      description    = "knode2-cilium-v6"
      family         = ["ipv6"]
      prefixlist_in  = "cilium-in-v6-pods"
      prefixlist_out = "deny-all-v6"
      remote_as      = 64514
      enabled        = true
    }
  }

  lga1_bgp_redistributions = {
    "connected" = {
      redistribute = "connected"
      description  = "Migrated route redistribution (bgp)"
      enabled      = true
    }
  }
}

resource "opnsense_quagga_bgp_global" "lga1" {
  provider = opnsense.lga1

  enabled              = true
  as_number            = 64513
  router_id            = "192.168.222.1"
  graceful_restart     = true
  log_neighbor_changes = true
  network_import_check = true
  enforce_first_as     = true
  networks             = []
}

import {
  provider = opnsense.lga1
  to       = opnsense_quagga_bgp_global.lga1
  id       = "bgp"
}

resource "opnsense_quagga_bgp_global" "lga2" {
  provider = opnsense.lga2

  enabled              = true
  as_number            = 65551
  graceful_restart     = false
  log_neighbor_changes = false
  network_import_check = true
  enforce_first_as     = true
  networks             = []
}

import {
  provider = opnsense.lga2
  to       = opnsense_quagga_bgp_global.lga2
  id       = "bgp"
}

resource "opnsense_quagga_prefix_list" "lga1_bgp_prefix_lists" {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_prefix_lists

  name        = each.value.name
  action      = each.value.action
  network     = each.value.network
  sequence    = each.value.sequence
  version     = each.value.version
  description = each.value.description
  enabled     = true
}

resource "opnsense_quagga_bgp_neighbor" "lga1_bgp_neighbors" {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_neighbors

  address               = each.value.address
  description           = each.value.description
  family                = each.value.family
  remote_as             = each.value.remote_as
  update_source         = try(each.value.update_source, null)
  linked_prefixlist_in  = [opnsense_quagga_prefix_list.lga1_bgp_prefix_lists[each.value.prefixlist_in].id]
  linked_prefixlist_out = [opnsense_quagga_prefix_list.lga1_bgp_prefix_lists[each.value.prefixlist_out].id]
  linked_routemap_in    = []
  linked_routemap_out   = []
  enabled               = each.value.enabled
  next_hop_self         = try(each.value.next_hop_self, false)
  bfd                   = true

  next_hop_self_all            = false
  multihop                     = false
  route_reflector_client       = false
  soft_reconfiguration_inbound = false
  bfd_strict                   = false
  default_originate            = false
  as_override                  = false
  disable_connected_check      = false
}

resource "opnsense_quagga_bgp_redistribution" "lga1_bgp_redistributions" {
  provider = opnsense.lga1
  for_each = local.lga1_bgp_redistributions

  redistribute = each.value.redistribute
  description  = each.value.description
  enabled      = each.value.enabled
}
