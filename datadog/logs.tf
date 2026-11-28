resource "datadog_logs_custom_pipeline" "envoy_client_geoip" {
  name       = "Envoy client GeoIP"
  is_enabled = true

  filter {
    query = "source:envoy @downstream_remote_address:*"
  }

  processor {
    grok_parser {
      name       = "Extract the peer IP from downstream_remote_address"
      is_enabled = true
      source     = "downstream_remote_address"
      samples    = ["74.76.39.147:25490", "[2001:db8::1]:443"]
      grok {
        support_rules = ""
        match_rules   = <<-EOT
          peer_ipv4 %%{ipv4:network.client.peer_ip}:%%{integer}
          peer_ipv6 \[%%{ipv6:network.client.peer_ip}\]:%%{integer}
        EOT
      }
    }
  }

  # Behind Cloudflare the peer is a Cloudflare edge address and the client is in
  # cf_connecting_ip. Neither remapper overrides, so the first one to set
  # network.client.ip wins.
  processor {
    attribute_remapper {
      name                 = "network.client.ip from cf_connecting_ip"
      is_enabled           = true
      sources              = ["cf_connecting_ip"]
      source_type          = "attribute"
      target               = "network.client.ip"
      target_type          = "attribute"
      preserve_source      = true
      override_on_conflict = false
    }
  }

  processor {
    attribute_remapper {
      name                 = "network.client.ip from the peer address"
      is_enabled           = true
      sources              = ["network.client.peer_ip"]
      source_type          = "attribute"
      target               = "network.client.ip"
      target_type          = "attribute"
      preserve_source      = true
      override_on_conflict = false
    }
  }

  processor {
    geo_ip_parser {
      name       = "GeoIP from network.client.ip"
      is_enabled = true
      sources    = ["network.client.ip"]
      target     = "network.client.geoip"
    }
  }
}
