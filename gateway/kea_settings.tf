# Kea singletons on lga2. Kea is configured but stopped on both gateways —
# dnsmasq serves DHCP and DNS — so these pin the "off" state and make a GUI
# change show up as a plan diff.

resource "opnsense_kea_ctrl_agent" "lga2" {
  provider = opnsense.lga2

  enabled   = false
  http_host = "127.0.0.1"
  http_port = "8000"
}

resource "opnsense_kea_ddns_settings" "lga2" {
  provider = opnsense.lga2

  enabled       = false
  manual_config = false
  server_ip     = "127.0.0.1"
  server_port   = 53001
}

resource "opnsense_kea_dhcpv4_settings" "lga2" {
  provider = opnsense.lga2

  enabled          = false
  manual_config    = false
  interfaces       = ["lan"]
  valid_lifetime   = 28800
  dhcp_socket_type = "raw"
  firewall_rules   = true
}

resource "opnsense_kea_dhcpv6_settings" "lga2" {
  provider = opnsense.lga2

  enabled          = false
  manual_config    = false
  interfaces       = ["lan"]
  valid_lifetime   = 4000
  dhcp_socket_type = ""
  firewall_rules   = true
}

import {
  provider = opnsense.lga2
  to       = opnsense_kea_ctrl_agent.lga2
  id       = "kea-ctrl-agent"
}

import {
  provider = opnsense.lga2
  to       = opnsense_kea_ddns_settings.lga2
  id       = "ddns"
}

import {
  provider = opnsense.lga2
  to       = opnsense_kea_dhcpv4_settings.lga2
  id       = "kea-dhcpv4-settings"
}

import {
  provider = opnsense.lga2
  to       = opnsense_kea_dhcpv6_settings.lga2
  id       = "kea-dhcpv6-settings"
}
