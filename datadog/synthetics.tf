locals {
  # Resolvers the private location reaches on the cluster network.
  reachable_resolvers = {
    cluster = "10.43.64.53"
    lga1    = "192.168.222.2"
  }

  # The addresses every tailnet client is handed. A private location in the
  # cluster cannot reach these, so they are watched from the odroids instead.
  tailnet_resolvers = {
    cluster = "100.95.107.254"
    lga1    = "100.127.60.59"
    lga2    = "100.110.65.2"
  }

  internal_name   = "dns.desertbluffs.com"
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
    Clients using it fall through to the next resolver or resolve the public address instead.
  EOT

  request_definition {
    host            = local.internal_name
    dns_server      = each.value
    dns_server_port = "53"
  }

  # The API rejects record-value assertions, so this only proves the resolver
  # answers. The odroid check compares the answer itself.
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

resource "datadog_monitor" "tailnet_resolver" {
  for_each = local.tailnet_resolvers

  name    = "Tailnet DNS resolver down: ${each.key}"
  type    = "metric alert"
  query   = "min(last_15m):min:custom.dns.resolver.up{resolver:${each.value}} < 1"
  message = <<-EOT
    ${each.key} (${each.value}) stopped answering ${local.internal_name} with ${local.internal_answer}.
    Both odroids report this metric every five minutes; the tailnet has two other nameservers
    to fall back on, but every lost one shortens the odds.

    Check the resolver, then whether `tofu plan` in `tailnet/` still shows the split-DNS entry.
  EOT
  tags    = ["service:dns", "resolver:${each.key}"]

  renotify_interval   = 60
  require_full_window = false
  on_missing_data     = "show_no_data"
  priority            = "3"
}
