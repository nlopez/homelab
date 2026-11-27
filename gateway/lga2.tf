
locals {
  lga2_unbound_forwards = {
    "239.168.192.in-addr.arpa" = {
      uuid        = "ff45439a-69d9-4322-9eb4-554c30ba2914"
      domain      = "239.168.192.in-addr.arpa"
      server      = "192.168.239.254"
      port        = 5353
      type        = "query"
      description = "local reverse zone via dnsmasq DHCP names"
    }
  }

  lga2_gateways = {
    "WG_LGA1" = {
      name            = "WG_LGA1"
      interface       = "opt1"
      gateway         = "10.23.50.1"
      ip_protocol     = "inet"
      description     = "WireGuard to lga1"
      default_gateway = false
      monitor_disable = true
    }
    "ODROID_LGA2" = {
      uuid            = "92610032-6ca6-47d3-9ce5-d77f97e86b96"
      name            = "ODROID_LGA2"
      interface       = "lan"
      gateway         = "192.168.239.2"
      ip_protocol     = "inet"
      description     = ""
      default_gateway = false
      monitor_disable = true
    }
  }

  lga2_routes = {
    "192.168.221.0/24" = {
      uuid        = "832fed0c-5043-44ea-a38f-2c124d3f61d6"
      network     = "192.168.221.0/24"
      gateway     = "WG_LGA1"
      description = "To lga1 (IPv4, WireGuard)"
    }
    "10.43.64.0/24" = {
      uuid        = "763805ca-4d9b-454b-9236-72fba3e0fde3"
      network     = "10.43.64.0/24"
      gateway     = "WG_LGA1"
      description = "To the private gateway (IPv4, WireGuard)"
    }
    "10.43.16.0/20" = {
      network     = "10.43.16.0/20"
      gateway     = "WG_LGA1"
      description = "To lga1 Kubernetes pods (IPv4, WireGuard)"
    }
    "192.168.222.0/24" = {
      uuid        = "c30286cd-e2b2-4804-9926-5e6dd90454bc"
      network     = "192.168.222.0/24"
      gateway     = "WG_LGA1"
      description = "To lga1 (IPv4, WireGuard)"
    }
    "192.168.223.0/24" = {
      uuid        = "cdc1c293-a923-453f-8c88-4d46cab3b26f"
      network     = "192.168.223.0/24"
      gateway     = "WG_LGA1"
      description = "To lga1 (IPv4, WireGuard)"
    }
    "100.64.0.0/10" = {
      uuid        = "d6ba02a4-b1c0-441e-9828-dae077711020"
      network     = "100.64.0.0/10"
      gateway     = "ODROID_LGA2"
      description = "To tailnet via odroid.lga2"
    }
  }
}

resource "opnsense_unbound_domain_override" "lga2_unbound_forwards" {
  provider = opnsense.lga2
  for_each = local.lga2_unbound_forwards

  domain      = each.value.domain
  server      = each.value.server
  server_port = each.value.port
  type        = each.value.type
  description = each.value.description
  enabled     = true
}

resource "opnsense_system_gateway" "lga2_gateways" {
  provider = opnsense.lga2
  for_each = local.lga2_gateways

  name            = each.value.name
  interface       = each.value.interface
  gateway         = each.value.gateway
  ip_protocol     = each.value.ip_protocol
  description     = each.value.description
  default_gateway = each.value.default_gateway
  monitor_disable = each.value.monitor_disable
  enabled         = true
}

resource "opnsense_system_route" "lga2_routes" {
  provider = opnsense.lga2
  for_each = local.lga2_routes

  depends_on = [opnsense_system_gateway.lga2_gateways]

  network     = each.value.network
  gateway     = each.value.gateway
  description = each.value.description
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_unbound_forwards
  to       = opnsense_unbound_domain_override.lga2_unbound_forwards[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga2
  for_each = { for k, v in local.lga2_gateways : k => v if can(v.uuid) }
  to       = opnsense_system_gateway.lga2_gateways[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga2
  for_each = { for k, v in local.lga2_routes : k => v if can(v.uuid) }
  to       = opnsense_system_route.lga2_routes[each.key]
  id       = each.value.uuid
}
