
locals {
  lga2_unbound_forwards = {
    "desertbluffs.com" = {
      uuid        = "8f76533f-cd8a-4f8f-8d63-dee6b5d46c4d"
      domain      = "desertbluffs.com"
      server      = "10.43.64.53"
      port        = 53
      type        = "query"
      description = "Cluster Technitium (the only authority for this zone)"
    }
    "nulogorsk.com" = {
      uuid        = "165ce9a9-4338-44d5-b351-b96a7b84ca71"
      domain      = "nulogorsk.com"
      server      = "10.43.64.53"
      port        = 53
      type        = "query"
      description = "Cluster Technitium (the only authority for this zone)"
    }
    "239.168.192.in-addr.arpa" = {
      uuid        = "ff45439a-69d9-4322-9eb4-554c30ba2914"
      domain      = "239.168.192.in-addr.arpa"
      server      = "192.168.239.254"
      port        = 5353
      type        = "query"
      description = "local reverse zone via dnsmasq DHCP names"
    }
  }

  lga2_unbound_hosts = {
    "dns-A" = {
      uuid        = "2e97c1d3-5582-45a0-9ce7-e88c46c297ba"
      hostname    = "dns"
      domain      = "lga2.radoncanyon.com"
      rr          = "A"
      server      = "192.168.239.2"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "gw-A" = {
      uuid        = "084d3588-2efa-4cab-9249-fda1945ab555"
      hostname    = "gw"
      domain      = "lga2.radoncanyon.com"
      rr          = "A"
      server      = "192.168.239.254"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "odroid-A" = {
      uuid        = "f89a60df-6d4b-4510-98f7-703ad3b3abf3"
      hostname    = "odroid"
      domain      = "lga2.radoncanyon.com"
      rr          = "A"
      server      = "192.168.239.2"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "gw-AAAA" = {
      uuid        = "d398d013-3005-40a3-908a-056e37a00566"
      hostname    = "gw"
      domain      = "lga2.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd72:ce7b:d4a9:9511::254"
      description = "Site infrastructure name"
    }
    "dns-AAAA" = {
      uuid        = "83f3d42b-71b5-4c84-9f51-390872beb5a9"
      hostname    = "dns"
      domain      = "lga2.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd72:ce7b:d4a9:9511::2"
      description = "Site infrastructure name"
    }
    "odroid-AAAA" = {
      uuid        = "99fed737-5eb9-4159-890e-f27f65fa5ef6"
      hostname    = "odroid"
      domain      = "lga2.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd72:ce7b:d4a9:9511::2"
      description = "Site infrastructure name"
    }
  }

  lga2_gateways = {
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
      gateway     = "ODROID_LGA2"
      description = "lga1 prefixes and tailnet range via odroid.lga2"
    }
    "10.43.64.0/24" = {
      uuid        = "763805ca-4d9b-454b-9236-72fba3e0fde3"
      network     = "10.43.64.0/24"
      gateway     = "ODROID_LGA2"
      description = "To the private gateway (IPv4, Tailscale)"
    }
    "192.168.222.0/24" = {
      uuid        = "c30286cd-e2b2-4804-9926-5e6dd90454bc"
      network     = "192.168.222.0/24"
      gateway     = "ODROID_LGA2"
      description = "lga1 prefixes and tailnet range via odroid.lga2"
    }
    "192.168.223.0/24" = {
      uuid        = "cdc1c293-a923-453f-8c88-4d46cab3b26f"
      network     = "192.168.223.0/24"
      gateway     = "ODROID_LGA2"
      description = "lga1 prefixes and tailnet range via odroid.lga2"
    }
    "100.64.0.0/10" = {
      uuid        = "d6ba02a4-b1c0-441e-9828-dae077711020"
      network     = "100.64.0.0/10"
      gateway     = "ODROID_LGA2"
      description = "lga1 prefixes and tailnet range via odroid.lga2"
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

resource "opnsense_unbound_host_override" "lga2_unbound_hosts" {
  provider = opnsense.lga2
  for_each = local.lga2_unbound_hosts

  hostname    = each.value.hostname
  domain      = each.value.domain
  rr          = each.value.rr
  server      = each.value.server
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
  for_each = local.lga2_unbound_hosts
  to       = opnsense_unbound_host_override.lga2_unbound_hosts[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_gateways
  to       = opnsense_system_gateway.lga2_gateways[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_routes
  to       = opnsense_system_route.lga2_routes[each.key]
  id       = each.value.uuid
}
