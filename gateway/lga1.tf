
locals {
  lga1_unbound_forwards = {
    "221.168.192.in-addr.arpa" = {
      uuid        = "26f65298-b2f8-47f0-ba27-4831f26857ab"
      domain      = "221.168.192.in-addr.arpa"
      server      = "192.168.221.1"
      port        = 5353
      type        = "query"
      description = "local reverse zone via dnsmasq DHCP names"
    }
    "222.168.192.in-addr.arpa" = {
      uuid        = "ceddc4e5-c592-4cce-ac23-6397019c0b81"
      domain      = "222.168.192.in-addr.arpa"
      server      = "192.168.221.1"
      port        = 5353
      type        = "query"
      description = "local reverse zone via dnsmasq DHCP names"
    }
    "223.168.192.in-addr.arpa" = {
      uuid        = "eeadd565-c016-4630-a4e5-7db4855b3d68"
      domain      = "223.168.192.in-addr.arpa"
      server      = "192.168.221.1"
      port        = 5353
      type        = "query"
      description = "local reverse zone via dnsmasq DHCP names"
    }
  }

  lga1_local_hosts = {
    "gw-A" = {
      uuid        = "9b431324-55d6-44cb-bbba-0805e0ca2e59"
      hostname    = "gw"
      domain      = "lga1.radoncanyon.com"
      rr          = "A"
      server      = "192.168.222.1"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "knode1-A" = {
      uuid        = "e464a0f7-29fa-4eb1-b0cc-8ed69eed4723"
      hostname    = "knode1"
      domain      = "lga1.radoncanyon.com"
      rr          = "A"
      server      = "192.168.222.143"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "knode2-A" = {
      uuid        = "7b76a925-2ab6-4d84-940a-e693d102ff26"
      hostname    = "knode2"
      domain      = "lga1.radoncanyon.com"
      rr          = "A"
      server      = "192.168.222.144"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "nas1-A" = {
      uuid        = "f392b398-2fdb-4457-a4c0-87a8a56217ea"
      hostname    = "nas1"
      domain      = "lga1.radoncanyon.com"
      rr          = "A"
      server      = "192.168.222.149"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "nas2-A" = {
      uuid        = "59bf554d-6db2-4e4e-a5e2-29b6bb98b768"
      hostname    = "nas2"
      domain      = "lga1.radoncanyon.com"
      rr          = "A"
      server      = "192.168.222.114"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "odroid-A" = {
      uuid        = "445b4ac2-2700-461c-afda-5541cc5c5caa"
      hostname    = "odroid"
      domain      = "lga1.radoncanyon.com"
      rr          = "A"
      server      = "192.168.222.2"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "odroid-AAAA" = {
      uuid        = "8977f4cc-f7ba-46b7-9956-3b6076435a9c"
      hostname    = "odroid"
      domain      = "lga1.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd54:571b:560a:2::2"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "gw-AAAA" = {
      uuid        = "99a3dd82-91e0-43c6-a6b8-748a2f55ee00"
      hostname    = "gw"
      domain      = "lga1.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd54:571b:560a:2::1"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "knode1-AAAA" = {
      uuid        = "7ef097a7-22d1-4a5f-810d-7171a1420eb8"
      hostname    = "knode1"
      domain      = "lga1.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd54:571b:560a:2::143"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "knode2-AAAA" = {
      uuid        = "13f3dc41-87b9-4136-989b-deeccd5087fe"
      hostname    = "knode2"
      domain      = "lga1.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd54:571b:560a:2::144"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "nas1-AAAA" = {
      uuid        = "38df524f-8894-4522-953a-dcf7f522bf5a"
      hostname    = "nas1"
      domain      = "lga1.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd54:571b:560a:2:ec4:7aff:fe33:59ee"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
    "nas2-AAAA" = {
      uuid        = "ce762ceb-bd17-48c1-ac73-dba07ee7ee9f"
      hostname    = "nas2"
      domain      = "lga1.radoncanyon.com"
      rr          = "AAAA"
      server      = "fd54:571b:560a:2:225:90ff:fe9b:4ae2"
      description = "Site infrastructure name (was in the cluster Technitium radoncanyon.com zone)"
    }
  }

  lga1_unbound_hosts = merge(
    local.lga1_local_hosts,
    { for k, v in local.lga2_local_hosts : "lga2-${k}" => {
      hostname    = v.hostname
      domain      = v.domain
      rr          = v.rr
      server      = v.server
      description = v.description
    } }
  )

  lga1_gateways = {
    "WG_LGA2" = {
      uuid            = "93404547-6ff4-4ad7-a1aa-4825d72ec309"
      name            = "WG_LGA2"
      interface       = "opt3"
      gateway         = "10.23.50.2"
      ip_protocol     = "inet"
      description     = "WireGuard to lga2"
      default_gateway = false
      monitor_disable = true
    }
    "odroid6" = {
      uuid            = "20fcdf8f-91ab-4d35-a35b-d9462d4fb8bf"
      name            = "odroid6"
      interface       = "opt2"
      gateway         = "fd54:571b:560a:2::2"
      ip_protocol     = "inet6"
      description     = "Tailscale Subnet Router (IPv6, ULA)"
      default_gateway = false
      monitor_disable = true
    }
    "odroid" = {
      uuid            = "3409424e-b7c8-49f2-8dfe-e0ad61fde620"
      name            = "odroid"
      interface       = "opt2"
      gateway         = "192.168.222.2"
      ip_protocol     = "inet"
      description     = "Tailscale Subnet Router"
      default_gateway = false
      monitor_disable = true
    }
  }

  lga1_routes = {
    "100.64.0.0/10" = {
      uuid        = "5fbc20df-9df3-4f08-abbb-4f976d4b8056"
      network     = "100.64.0.0/10"
      gateway     = "odroid"
      description = "To tailnet"
    }
    "fd7a:115c:a1e0::/48" = {
      uuid        = "f0cc5db5-ec42-4192-beec-3c5430e99903"
      network     = "fd7a:115c:a1e0::/48"
      gateway     = "odroid6"
      description = "To tailnet (IPv6)"
    }
    "192.168.239.0/24" = {
      uuid        = "f1affa99-feb8-451c-b5a6-0ec339c2be66"
      network     = "192.168.239.0/24"
      gateway     = "WG_LGA2"
      description = "To lga2 LAN (IPv4, WireGuard)"
    }
  }
}

resource "opnsense_unbound_domain_override" "lga1_unbound_forwards" {
  provider = opnsense.lga1
  for_each = local.lga1_unbound_forwards

  domain      = each.value.domain
  server      = each.value.server
  server_port = each.value.port
  type        = each.value.type
  description = each.value.description
  enabled     = true
}

resource "opnsense_unbound_host_override" "lga1_unbound_hosts" {
  provider = opnsense.lga1
  for_each = local.lga1_unbound_hosts

  hostname    = each.value.hostname
  domain      = each.value.domain
  rr          = each.value.rr
  server      = each.value.server
  description = each.value.description
  enabled     = true
}

resource "opnsense_system_gateway" "lga1_gateways" {
  provider = opnsense.lga1
  for_each = local.lga1_gateways

  name            = each.value.name
  interface       = each.value.interface
  gateway         = each.value.gateway
  ip_protocol     = each.value.ip_protocol
  description     = each.value.description
  default_gateway = each.value.default_gateway
  monitor_disable = each.value.monitor_disable
  enabled         = true
}

resource "opnsense_system_route" "lga1_routes" {
  provider = opnsense.lga1
  for_each = local.lga1_routes

  depends_on = [opnsense_system_gateway.lga1_gateways]

  network     = each.value.network
  gateway     = each.value.gateway
  description = each.value.description
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_unbound_forwards
  to       = opnsense_unbound_domain_override.lga1_unbound_forwards[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga1
  for_each = { for k, v in local.lga1_local_hosts : k => v if can(v.uuid) }
  to       = opnsense_unbound_host_override.lga1_unbound_hosts[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_gateways
  to       = opnsense_system_gateway.lga1_gateways[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_routes
  to       = opnsense_system_route.lga1_routes[each.key]
  id       = each.value.uuid
}
