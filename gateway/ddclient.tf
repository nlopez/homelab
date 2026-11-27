# Dynamic DNS general settings. The accounts (lga1.desertbluffs.com A;
# lga2.desertbluffs.com A and AAAA) stay in the GUI: opnsense_ddclient_account
# has no zone or interface field, and the Cloudflare service needs both.
# The native backend replaces ddclient, which upstream is winding down.

resource "opnsense_ddclient_settings" "lga1" {
  provider = opnsense.lga1

  enabled    = true
  backend    = "opnsense"
  interval   = 300
  verbose    = false
  allow_ipv6 = true
}

import {
  provider = opnsense.lga1
  to       = opnsense_ddclient_settings.lga1
  id       = "ddclient-settings"
}

resource "opnsense_ddclient_settings" "lga2" {
  provider = opnsense.lga2

  enabled    = true
  backend    = "opnsense"
  interval   = 300
  verbose    = false
  allow_ipv6 = true
}

import {
  provider = opnsense.lga2
  to       = opnsense_ddclient_settings.lga2
  id       = "ddclient-settings"
}
