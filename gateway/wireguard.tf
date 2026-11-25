# Site-to-site WireGuard between lga1 and lga2. lga1 listens on its static
# WAN address; lga2 dials out to it. Each side's peer `tunnel_address` is the
# set of remote prefixes the tunnel carries, and OPNsense installs a route for
# every prefix there, so these lists are also the IPv6 routing table between
# the sites. The IPv4 prefixes also have static routes via the WG_* gateways.

locals {
  wg_lga1_tunnel = ["10.23.50.1/32", "fd77:7a::1/128"]
  wg_lga2_tunnel = ["10.23.50.2/32", "fd77:7a::2/128"]

  # Cilium pod CIDRs (kubernetes/apps-helm/cilium/values.yaml) and
  # LoadBalancer pools (kubernetes/apps-helm/cilium/manifests/bgp.yaml), all
  # announced to gw.lga1 over BGP. The IPv6 prefixes sit inside the lga1 /56
  # and /48 below and are listed so the tunnel keeps them if those ever narrow.
  k8s_nets = [
    "10.43.16.0/20",
    "2600:4041:5b21:6b10::/96",
    "10.43.64.0/24",
    "fd54:571b:560a:4364::/112",
    "2600:4041:5b21:6b64::/112",
  ]

  lga1_site_nets = concat([
    "192.168.221.0/24",
    "192.168.222.0/24",
    "192.168.223.0/24",
    "2600:4041:5b21:6b00::/56",
    "fd54:571b:560a::/48",
  ], local.k8s_nets)

  lga2_site_nets = [
    "192.168.239.0/24",
    "2600:4041:5b37:201::/64",
    "fd72:ce7b:d4a9:9511::/64",
  ]
}

variable "lga1_wg_private_key" {
  type      = string
  sensitive = true
}

variable "lga2_wg_private_key" {
  type      = string
  sensitive = true
}

variable "wg_psk" {
  type      = string
  sensitive = true
}

resource "opnsense_wireguard_settings" "lga1" {
  provider = opnsense.lga1
  enabled  = true
}

import {
  provider = opnsense.lga1
  to       = opnsense_wireguard_settings.lga1
  id       = "wireguard_settings"
}

resource "opnsense_wireguard_settings" "lga2" {
  provider = opnsense.lga2
  enabled  = true
}

import {
  provider = opnsense.lga2
  to       = opnsense_wireguard_settings.lga2
  id       = "wireguard_settings"
}

resource "opnsense_wireguard_peer" "lga1_lga2" {
  provider       = opnsense.lga1
  enabled        = true
  name           = "lga2"
  public_key     = "KyRT6D7likFJYPto8g0YCnt18iZOU5GhD4QsI1VfnRU="
  tunnel_address = concat(local.wg_lga2_tunnel, local.lga2_site_nets)
  psk            = var.wg_psk
  keepalive      = 25
}

import {
  provider = opnsense.lga1
  to       = opnsense_wireguard_peer.lga1_lga2
  id       = "70f7dc2f-85e4-4132-9ed7-6d856caa0f26"
}

resource "opnsense_wireguard_server" "lga1" {
  provider       = opnsense.lga1
  enabled        = true
  name           = "lga1"
  private_key    = var.lga1_wg_private_key
  public_key     = "/OAt/BzWNqo3w1NX9jeQhvaXVt3ds+aiHWgGDy8TjVw="
  port           = 24925
  tunnel_address = local.wg_lga1_tunnel
  peers          = [opnsense_wireguard_peer.lga1_lga2.id]
  disable_routes = false
}

import {
  provider = opnsense.lga1
  to       = opnsense_wireguard_server.lga1
  id       = "867d33d1-c690-4b9c-bbf4-40fdc449068b"
}

resource "opnsense_wireguard_peer" "lga2_lga1" {
  provider       = opnsense.lga2
  enabled        = true
  name           = "lga1"
  public_key     = "/OAt/BzWNqo3w1NX9jeQhvaXVt3ds+aiHWgGDy8TjVw="
  tunnel_address = concat(local.wg_lga1_tunnel, local.lga1_site_nets)
  server_address = "96.246.156.39"
  server_port    = 24925
  psk            = var.wg_psk
  keepalive      = 25
}

import {
  provider = opnsense.lga2
  to       = opnsense_wireguard_peer.lga2_lga1
  id       = "12fe2788-3c73-4a92-ab16-3da95721afcf"
}

resource "opnsense_wireguard_server" "lga2" {
  provider       = opnsense.lga2
  enabled        = true
  name           = "lga2"
  private_key    = var.lga2_wg_private_key
  public_key     = "KyRT6D7likFJYPto8g0YCnt18iZOU5GhD4QsI1VfnRU="
  port           = 33607
  tunnel_address = local.wg_lga2_tunnel
  peers          = [opnsense_wireguard_peer.lga2_lga1.id]
  disable_routes = false
}

import {
  provider = opnsense.lga2
  to       = opnsense_wireguard_server.lga2
  id       = "c898d45e-aeb7-4d82-bdaa-3845f40c64a8"
}
