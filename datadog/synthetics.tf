locals {
  reachable_resolvers = {
    cluster = "10.43.64.53"
  }

  internal_name   = "bushi.desertbluffs.com"
  internal_answer = "10.43.64.10"
}

resource "datadog_synthetics_test" "internal_dns" {
  for_each = local.reachable_resolvers

  name      = "Internal DNS via ${each.key} answers ${local.internal_name}"
  type      = "api"
  subtype   = "dns"
  status    = "live"
  locations = [var.synthetics_location_id]
  tags      = ["service:dns", "resolver:${each.key}"]

  message = <<-EOT
    ${each.key} (${each.value}) did not answer ${local.internal_name} with ${local.internal_answer}.
  EOT

  request_definition {
    host            = local.internal_name
    dns_server      = each.value
    dns_server_port = "53"
  }

  assertion {
    type     = "responseTime"
    operator = "lessThan"
    target   = 2000
  }

  options_list {
    tick_every           = 300
    min_failure_duration = 600
    min_location_failed  = 1

    monitor_options {
      renotify_interval = 60
    }
  }
}

# ICMP from public locations to each site's WAN address. The hostnames are
# Cloudflare A records that ddclient on each gateway keeps pointed at the WAN.
locals {
  wan_ping_tests = {
    lga1 = { id = "awi-gfy-zah", host = "lga1.desertbluffs.com" }
    lga2 = { id = "usw-k9m-dxh", host = "lga2.desertbluffs.com" }
  }
}

import {
  for_each = local.wan_ping_tests
  to       = datadog_synthetics_test.wan_ping[each.key]
  id       = each.value.id
}

resource "datadog_synthetics_test" "wan_ping" {
  for_each = local.wan_ping_tests

  name    = "${each.key} WAN ping"
  type    = "api"
  subtype = "icmp"
  status  = "live"
  locations = [
    "aws:ap-northeast-1",
    "aws:eu-central-1",
    "aws:us-east-1",
    "aws:us-west-2",
    "gcp:asia-northeast1",
    "gcp:europe-west3",
    "gcp:us-east4",
    "gcp:us-west1",
  ]
  tags    = ["team:desert-bluffs"]
  message = "@oncall-desert-bluffs "

  request_definition {
    host              = each.value.host
    number_of_packets = 10
    should_track_hops = true
    timeout           = 5
  }

  assertion {
    type     = "latency"
    operator = "lessThan"
    property = "avg"
    target   = "250"
  }

  assertion {
    type     = "packetLossPercentage"
    operator = "is"
    target   = "0"
  }

  options_list {
    tick_every           = 60
    min_failure_duration = 0
    min_location_failed  = 3
    monitor_priority     = 1
    http_version         = "http1"

    retry {
      count    = 0
      interval = 300
    }

    monitor_options {
      notification_preset_name = "show_all"
    }
  }
}
