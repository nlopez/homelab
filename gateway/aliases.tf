# Firewall aliases, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

locals {
  lga1_aliases = {
    "cf_ips_v4" = {
      uuid        = "2b2bf8fe-5efb-4fb5-b9a5-39115ab79c7c"
      type        = "urltable"
      content     = ["https://www.cloudflare.com/ips-v4"]
      description = "Cloudflare IPv4 source IPs"
      enabled     = true
      stats       = true
      update_freq = "1"
    }
    "cf_ips_v6" = {
      uuid        = "08b42fb9-87a4-4468-a6ab-70372555173d"
      type        = "urltable"
      content     = ["https://www.cloudflare.com/ips-v6"]
      description = "Cloudflare IPv6 source IPs"
      enabled     = true
      stats       = true
      update_freq = "1"
    }
    "rfc1918" = {
      uuid    = "2ef1cc26-2169-4c64-83fd-98355b5c841b"
      type    = "network"
      content = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      enabled = true
      stats   = false
    }
    "ingress_gateway" = {
      uuid    = "99554320-cd93-44bc-8b6c-9754bb1d4dc3"
      type    = "host"
      content = ["10.43.64.20"]
      enabled = true
      stats   = false
    }
    "pms_host" = {
      uuid    = "7b342a04-822b-4911-b6aa-eb2bbfbcfdf2"
      type    = "host"
      content = ["10.43.64.2"]
      enabled = true
      stats   = false
    }
    "qbittorrent" = {
      uuid    = "8732103a-cb4c-4ccf-a880-bfe8c1a4990b"
      type    = "host"
      content = ["192.168.222.149"]
      enabled = true
      stats   = false
    }
    "pms_port" = {
      uuid        = "1a7d1f09-ee70-457e-ae6a-1e31db6eca68"
      type        = "port"
      content     = ["32400"]
      description = "Plex Media Server port"
      enabled     = true
      stats       = false
    }
    "k8s_lb_net" = {
      uuid    = "82850a68-0cb6-489f-ae76-da3b8154457b"
      type    = "network"
      content = ["10.0.10.0/24"]
      enabled = true
      stats   = false
    }
    "HTTP_S" = {
      uuid    = "5f14bb8b-ce03-4eed-aae5-5947a43be5f7"
      type    = "port"
      content = ["80", "443"]
      enabled = true
      stats   = false
    }
    "k8s_net_network" = {
      uuid    = "a99cee21-5cb8-4a0b-87ae-7f8a7960b01a"
      type    = "network"
      content = ["10.43.0.0/16"]
      enabled = true
      stats   = false
    }
    "palworld" = {
      uuid        = "2a32b654-d9f9-4dbb-8d25-bf9bc9d63e80"
      type        = "port"
      content     = ["8211", "8311", "8411", "8511", "8611", "8711", "8811", "8911", "9111", "9211"]
      description = "Palworld Dedicated Server Game Port"
      enabled     = true
      stats       = false
    }
    "odroid" = {
      uuid        = "5145898d-2589-4b70-a8af-1c31b9da72f3"
      type        = "host"
      content     = ["192.168.222.2", "fd54:571b:560a:2::2"]
      description = "odroid.lga1 (DNS server)"
      enabled     = true
      stats       = false
    }
    "DoH_v4" = {
      uuid        = "0f59348f-0709-4ecc-9382-ec87fb545522"
      type        = "urltable"
      content     = ["https://raw.githubusercontent.com/hagezi/dns-blocklists/main/ips/doh.txt"]
      description = "DoH server IPv4 blocklist (hagezi)"
      enabled     = true
      stats       = false
      update_freq = "1"
    }
    "DoH_v6" = {
      uuid        = "a0d6fd35-56ce-46f9-8e17-c7e273855717"
      type        = "urltable"
      content     = ["https://raw.githubusercontent.com/dibdot/DoH-IP-blocklists/master/doh-ipv6.txt"]
      description = "DoH server IPv6 blocklist (dibdot)"
      enabled     = true
      stats       = false
      update_freq = "1"
    }
    "odroid_gua" = {
      uuid        = "25caeffb-1417-483c-991c-d0bb66915b59"
      type        = "dynipv6host"
      content     = ["::21e:6ff:fe33:da28"]
      description = "odroid.lga1 EUI-64 global IPv6 on LAB (follows prefix changes)"
      enabled     = true
      stats       = false
      interface   = "opt2"
    }
    "odroid_self" = {
      uuid        = "db868de0-b324-4e0b-9856-3622007819ca"
      type        = "host"
      content     = ["192.168.222.2", "fd54:571b:560a:2::2", "odroid_gua"]
      description = "odroid.lga1 own addresses: exempt from DNS/DoT/DoH steering"
      enabled     = true
      stats       = false
    }
    "knode1_gua_lab" = {
      uuid        = "251631c9-ebf9-4eeb-afac-2e5b720622b0"
      type        = "dynipv6host"
      content     = ["::d65d:dfff:fe07:5137"]
      description = "knode1 eno1 EUI-64 global IPv6 on LAB"
      enabled     = true
      stats       = false
      interface   = "opt2"
    }
    "knode2_gua_lab" = {
      uuid        = "6051225e-4102-47da-9a0d-91c0077cd65e"
      type        = "dynipv6host"
      content     = ["::21f:c6ff:fe9c:bfd7"]
      description = "knode2 eno1 EUI-64 global IPv6 on LAB"
      enabled     = true
      stats       = false
      interface   = "opt2"
    }
    "knode1_gua_wlan" = {
      uuid        = "ce862218-3796-458e-b946-a834e05abea0"
      type        = "dynipv6host"
      content     = ["::1de:a90d:fd93:8653"]
      description = "knode1 wlp2s0 global IPv6 on WLAN (stable-privacy IID)"
      enabled     = true
      stats       = false
      interface   = "opt1"
    }
    "knodes" = {
      uuid        = "e2b3953a-adbe-4c72-bf53-f369589052ff"
      type        = "host"
      content     = ["192.168.222.143", "192.168.222.144", "192.168.223.163", "knode1_gua_lab", "knode2_gua_lab", "knode1_gua_wlan"]
      description = "Kubernetes nodes knode1/knode2 (all addresses)"
      enabled     = true
      stats       = false
    }
    "doh_exempt" = {
      uuid        = "5147b2ff-ce4b-4059-9c4e-7d4c61abbdf1"
      type        = "host"
      content     = ["odroid_self", "knodes", "remote_nets"]
      description = "Hosts allowed to use DoH directly"
      enabled     = true
      stats       = false
    }
    "remote_nets" = {
      uuid        = "90f6d7ec-1b50-4f1c-9dd1-49792c01de46"
      type        = "network"
      content     = ["100.64.0.0/10", "fd7a:115c:a1e0::/48", "192.168.239.0/24", "fd72:ce7b:d4a9::/48"]
      description = "Tailnet and lga2 networks routed in via subnet routers (not local clients)"
      enabled     = true
      stats       = false
    }
    "dns_steer_exempt" = {
      uuid        = "c2815620-7c75-413e-82b4-af0c00efdd1d"
      type        = "network"
      content     = ["192.168.222.2/32", "fd54:571b:560a:2::2/128", "odroid_gua", "remote_nets", "192.168.222.143/32", "192.168.222.144/32"]
      description = "Sources exempt from DNS redirect and DNS/DoT blocks: odroid and routed remote traffic"
      enabled     = true
      stats       = false
    }
    "spamhaus_drop" = {
      uuid            = "d5d3b217-e9ae-4dda-8750-b4c2a1721a87"
      type            = "urljson"
      content         = ["https://www.spamhaus.org/drop/drop_v4.json"]
      description     = "Spamhaus DROP"
      enabled         = true
      stats           = false
      path_expression = "cidr"
    }
    "spamhaus_dropv6" = {
      uuid            = "b24b9ae0-0a6e-437e-a797-aa4535098d90"
      type            = "urljson"
      content         = ["https://www.spamhaus.org/drop/drop_v6.json"]
      description     = "Spamhaus DROPv6"
      enabled         = true
      stats           = false
      path_expression = "cidr"
    }
    "ingress_gateway_v6" = {
      uuid        = "a4dcb758-6eb9-46af-943a-6a18b2f240b6"
      type        = "host"
      content     = ["2600:4041:5b21:6b64::20"]
      description = "Internet gateway public IPv6 (Cilium public-v6 pool)"
      enabled     = true
      stats       = false
    }
    "lga1_site_nets" = {
      type        = "network"
      content     = concat(local.wg_lga1_tunnel, local.lga1_site_nets)
      description = "lga1 networks carried by the site-to-site WireGuard tunnel"
      enabled     = true
      stats       = false
    }
    "lga2_site_nets" = {
      type        = "network"
      content     = concat(local.wg_lga2_tunnel, local.lga2_site_nets)
      description = "lga2 networks carried by the site-to-site WireGuard tunnel"
      enabled     = true
      stats       = false
    }
  }

  lga2_aliases = {
    "wiz_smart_lights" = {
      uuid    = "401412cb-f074-43a9-a9f6-4726b6a2a2d9"
      type    = "mac"
      content = ["cc:40:85:36:c9:0e", "cc:40:85:36:cb:6a", "cc:40:85:3e:84:5c", "cc:40:85:3f:5b:d2", "cc:40:85:3f:5b:f8", "cc:40:85:3f:c9:f6", "cc:40:85:40:12:5a", "cc:40:85:40:13:80", "cc:40:85:44:98:98", "cc:40:85:44:a1:d4", "cc:40:85:4a:7f:a0"]
      enabled = true
      stats   = false
    }
    "lga1_wan_ip" = {
      uuid    = "57d46ac5-1cd1-4ab5-bc74-bec9b74c70f7"
      type    = "host"
      content = ["68.160.239.62"]
      enabled = true
      stats   = false
    }
    "plex" = {
      uuid    = "c3594d17-f5ec-4f03-b089-d893ccf1fd72"
      type    = "port"
      content = ["32400"]
      enabled = true
      stats   = false
    }
    "lg_c1_tv" = {
      uuid        = "44108384-925e-4de7-b959-bc9085494433"
      type        = "mac"
      content     = ["64:cb:e9:2c:4f:82"]
      description = "65\" Living Room TV"
      enabled     = true
      stats       = false
    }
    "raphael" = {
      uuid    = "4a30cab9-f005-4e9f-af81-0a2ee8f9d12d"
      type    = "mac"
      content = ["C8:7F:54:09:59:F0"]
      enabled = true
      stats   = false
    }
    "DoH_v4" = {
      uuid        = "a8d80dec-0f43-47c2-a0e5-34d3815e4dde"
      type        = "urltable"
      content     = ["https://raw.githubusercontent.com/hagezi/dns-blocklists/main/ips/doh.txt"]
      description = "DoH server IPv4 blocklist (hagezi)"
      enabled     = true
      stats       = false
      update_freq = "1"
    }
    "DoH_v6" = {
      uuid        = "7b728932-7004-4374-8349-26c6381e5681"
      type        = "urltable"
      content     = ["https://raw.githubusercontent.com/dibdot/DoH-IP-blocklists/master/doh-ipv6.txt"]
      description = "DoH server IPv6 blocklist (dibdot)"
      enabled     = true
      stats       = false
      update_freq = "1"
    }
    "odroid" = {
      uuid    = "80f19cb7-1685-4082-ad80-e71ee0f5db79"
      type    = "host"
      content = ["192.168.239.2", "fd72:ce7b:d4a9:9511::2"]
      enabled = true
      stats   = false
    }
    "odroid_mac" = {
      uuid        = "ea7a22c1-b0f3-4f65-a63b-de8f488d9dec"
      type        = "mac"
      content     = ["00:1e:06:33:da:2c"]
      description = "odroid.lga2 by MAC: follows all its IPv4/IPv6 addresses (DNS and DoH exemption)"
      enabled     = true
      stats       = false
    }
    "LGA1_NETS" = {
      uuid        = "a27a2fbf-c628-4a36-93dc-ecd1654835aa"
      type        = "network"
      content     = ["10.43.64.0/24", "192.168.221.0/24", "192.168.222.0/24", "192.168.223.0/24", "100.64.0.0/10"]
      description = "lga1 subnets and tailnet range, routed via odroid.lga2"
      enabled     = true
      stats       = false
    }
    "lga1_site_nets" = {
      type        = "network"
      content     = concat(local.wg_lga1_tunnel, local.lga1_site_nets)
      description = "lga1 networks carried by the site-to-site WireGuard tunnel"
      enabled     = true
      stats       = false
    }
    "lga2_site_nets" = {
      type        = "network"
      content     = concat(local.wg_lga2_tunnel, local.lga2_site_nets)
      description = "lga2 networks carried by the site-to-site WireGuard tunnel"
      enabled     = true
      stats       = false
    }
  }
}

resource "opnsense_firewall_alias" "lga1_aliases" {
  provider = opnsense.lga1
  for_each = local.lga1_aliases

  name            = each.key
  type            = each.value.type
  content         = each.value.content
  description     = try(each.value.description, null)
  enabled         = each.value.enabled
  stats           = each.value.stats
  update_freq     = try(each.value.update_freq, null)
  path_expression = try(each.value.path_expression, null)
  interface       = try(each.value.interface, null)

  lifecycle {
    # urljson aliases carry an updatefreq the provider does not expose.
    ignore_changes = [update_freq]
  }
}

import {
  provider = opnsense.lga1
  for_each = { for k, v in local.lga1_aliases : k => v if can(v.uuid) }
  to       = opnsense_firewall_alias.lga1_aliases[each.key]
  id       = each.value.uuid
}

resource "opnsense_firewall_alias" "lga2_aliases" {
  provider = opnsense.lga2
  for_each = local.lga2_aliases

  name            = each.key
  type            = each.value.type
  content         = each.value.content
  description     = try(each.value.description, null)
  enabled         = each.value.enabled
  stats           = each.value.stats
  update_freq     = try(each.value.update_freq, null)
  path_expression = try(each.value.path_expression, null)
  interface       = try(each.value.interface, null)

  lifecycle {
    # urljson aliases carry an updatefreq the provider does not expose.
    ignore_changes = [update_freq]
  }
}

import {
  provider = opnsense.lga2
  for_each = { for k, v in local.lga2_aliases : k => v if can(v.uuid) }
  to       = opnsense_firewall_alias.lga2_aliases[each.key]
  id       = each.value.uuid
}

