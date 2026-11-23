locals {
  reachable_resolvers = {
    cluster = "10.43.64.53"
  }

  internal_name   = "home.desertbluffs.com"
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
