# Syslog destinations, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

locals {
  lga1_syslog_destinations = {
    "192.168.222.2-5514" = {
      uuid        = "45a4a50f-fc29-448f-a2e3-af338d1e4941"
      hostname    = "192.168.222.2"
      transport   = "udp4"
      port        = 5514
      level       = ["info", "notice", "warn", "err", "crit", "alert", "emerg"]
      description = "Datadog agent on odroid"
      enabled     = true
      rfc5424     = false
    }
  }

  lga2_syslog_destinations = {
  }

}

resource "opnsense_syslog_destination" "lga1_syslog_destinations" {
  provider = opnsense.lga1
  for_each = local.lga1_syslog_destinations

  hostname    = each.value.hostname
  transport   = each.value.transport
  port        = try(each.value.port, null)
  level       = try(each.value.level, null)
  facility    = try(each.value.facility, null)
  description = try(each.value.description, null)
  enabled     = each.value.enabled
  rfc5424     = each.value.rfc5424
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_syslog_destinations
  to       = opnsense_syslog_destination.lga1_syslog_destinations[each.key]
  id       = each.value.uuid
}

resource "opnsense_syslog_destination" "lga2_syslog_destinations" {
  provider = opnsense.lga2
  for_each = local.lga2_syslog_destinations

  hostname    = each.value.hostname
  transport   = each.value.transport
  port        = try(each.value.port, null)
  level       = try(each.value.level, null)
  facility    = try(each.value.facility, null)
  description = try(each.value.description, null)
  enabled     = each.value.enabled
  rfc5424     = each.value.rfc5424
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_syslog_destinations
  to       = opnsense_syslog_destination.lga2_syslog_destinations[each.key]
  id       = each.value.uuid
}

