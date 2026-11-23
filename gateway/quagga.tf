# FRR/Quagga general settings, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

resource "opnsense_quagga_general" "lga1" {
  provider = opnsense.lga1

  enabled        = true
  profile        = "traditional"
  enable_carp    = false
  enable_syslog  = true
  enable_snmp    = false
  syslog_level   = "notifications"
  firewall_rules = true
}

import {
  provider = opnsense.lga1
  to       = opnsense_quagga_general.lga1
  id       = "general"
}

resource "opnsense_quagga_general" "lga2" {
  provider = opnsense.lga2

  enabled        = true
  profile        = "traditional"
  enable_carp    = false
  enable_syslog  = true
  enable_snmp    = false
  syslog_level   = "notifications"
  firewall_rules = true
}

import {
  provider = opnsense.lga2
  to       = opnsense_quagga_general.lga2
  id       = "general"
}

