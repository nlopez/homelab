locals {
  internal_zones = ["desertbluffs.com"]
}

resource "opnsense_unbound_general" "lga1" {
  provider = opnsense.lga1

  acl_default_action  = "refuse"
  active_interface    = []
  aggressive_nsec     = true
  cache_flush         = true
  dns64               = false
  dns64_prefix        = "64:ff9b::/96"
  dnssec              = true
  dnssec_stripped     = true
  enable_prefetch     = true
  enable_prefetch_key = true
  enable_wpad         = false
  enabled             = true
  extended_statistics = true
  forwarding_enabled  = false
  hide_identity       = true
  hide_version        = true
  insecure_domains    = local.internal_zones
  keep_probing_hosts  = false
  log_local_actions   = false
  log_queries         = false
  log_replies         = false
  log_servfail        = false
  # typetransparent: names with local data still NODATA-fall through the
  # authoritative view for other types (MX, TXT), like a split-horizon zone.
  local_zone_type                       = "typetransparent"
  max_ttl                               = 300
  msg_cache_size                        = ""
  no_aaaa_records                       = false
  no_register_link_local6               = true
  no_register_records                   = true
  outgoing_interface                    = []
  port                                  = "53"
  private_addresses                     = ["0.0.0.0/8", "10.0.0.0/8", "100.64.0.0/10", "169.254.0.0/16", "172.16.0.0/12", "192.0.2.0/24", "192.168.0.0/16", "198.18.0.0/15", "198.51.100.0/24", "2001:db8::/32", "203.0.113.0/24", "233.252.0.0/24", "::1/128", "fc00::/8", "fd00::/8", "fe80::/10"]
  private_domains                       = [""]
  qname_min_strict                      = false
  register_dhcp                         = false
  register_dhcp_domain                  = ""
  register_dhcp_static                  = false
  rrset_cache_size                      = ""
  serve_expired_client_response_timeout = "1800"
  serve_expired_enabled                 = false
  serve_expired_record_reply_ttl        = "30"
  serve_expired_reset_ttl               = true
  serve_expired_ttl                     = "86400"
  stats                                 = true
  tag_query_reply                       = false
  txt_support                           = true
  validation_level                      = 0
  verbosity_level                       = 1
}

import {
  provider = opnsense.lga1
  to       = opnsense_unbound_general.lga1
  id       = "unbound-general"
}

resource "opnsense_unbound_general" "lga2" {
  provider = opnsense.lga2

  acl_default_action  = "refuse"
  active_interface    = []
  aggressive_nsec     = true
  cache_flush         = true
  dns64               = false
  dns64_prefix        = "64:ff9b::/96"
  dnssec              = true
  dnssec_stripped     = true
  enable_prefetch     = true
  enable_prefetch_key = true
  enable_wpad         = false
  enabled             = true
  extended_statistics = true
  forwarding_enabled  = false
  hide_identity       = true
  hide_version        = true
  insecure_domains    = local.internal_zones
  keep_probing_hosts  = false
  log_local_actions   = false
  log_queries         = false
  log_replies         = false
  log_servfail        = false
  # typetransparent: names with local data still NODATA-fall through the
  # authoritative view for other types (MX, TXT), like a split-horizon zone.
  local_zone_type                       = "typetransparent"
  min_ttl                               = 0
  msg_cache_size                        = ""
  no_aaaa_records                       = false
  no_register_link_local6               = false
  no_register_records                   = true
  outgoing_interface                    = []
  port                                  = "53"
  private_addresses                     = ["0.0.0.0/8", "10.0.0.0/8", "100.64.0.0/10", "169.254.0.0/16", "172.16.0.0/12", "192.0.2.0/24", "192.168.0.0/16", "198.18.0.0/15", "198.51.100.0/24", "2001:db8::/32", "203.0.113.0/24", "233.252.0.0/24", "::1/128", "fc00::/8", "fd00::/8", "fe80::/10"]
  private_domains                       = [""]
  qname_min_strict                      = false
  register_dhcp                         = false
  register_dhcp_domain                  = ""
  register_dhcp_static                  = false
  rrset_cache_size                      = ""
  serve_expired_client_response_timeout = "1800"
  serve_expired_enabled                 = false
  serve_expired_record_reply_ttl        = "30"
  serve_expired_reset_ttl               = true
  serve_expired_ttl                     = "86400"
  stats                                 = true
  tag_query_reply                       = false
  txt_support                           = true
  validation_level                      = 0
  verbosity_level                       = 1
}

import {
  provider = opnsense.lga2
  to       = opnsense_unbound_general.lga2
  id       = "unbound-general"
}

# acl_default_action refuses anything outside the interface subnets Unbound
# auto-allows. Cross-site queries arrive over WireGuard without SNAT, so the
# other site's LAN, the tailnet and the ULA ranges need an explicit allow.
# One ACL per network: the provider reads a multi-network ACL back as only its
# first network.
locals {
  unbound_private_networks = [
    "10.0.0.0/8",
    "100.64.0.0/10",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "fc00::/7",
  ]
}

resource "opnsense_unbound_acl" "lga1_private" {
  provider = opnsense.lga1
  for_each = toset(local.unbound_private_networks)

  name        = "private-${replace(replace(each.key, "/", "-"), ":", "")}"
  action      = "allow"
  networks    = each.key
  description = "Private-range clients"
}

resource "opnsense_unbound_acl" "lga2_private" {
  provider = opnsense.lga2
  for_each = toset(local.unbound_private_networks)

  name        = "private-${replace(replace(each.key, "/", "-"), ":", "")}"
  action      = "allow"
  networks    = each.key
  description = "Private-range clients"
}

# hgz003 is the HaGeZi Multi PRO feed. Empty list attributes read back as [""].
resource "opnsense_unbound_dnsbl" "lga1" {
  provider = opnsense.lga1

  blocklists  = [""]
  enabled     = true
  lists       = [""]
  nxdomain    = true
  safe_search = false
  type        = ["hgz003"]
  whitelists  = [""]
  wildcards   = [""]
}

import {
  provider = opnsense.lga1
  to       = opnsense_unbound_dnsbl.lga1
  id       = "unbound-dnsbl"
}

resource "opnsense_unbound_dnsbl" "lga2" {
  provider = opnsense.lga2

  blocklists  = [""]
  enabled     = true
  lists       = [""]
  nxdomain    = true
  safe_search = false
  type        = ["hgz003"]
  whitelists  = [""]
  wildcards   = [""]
}

import {
  provider = opnsense.lga2
  to       = opnsense_unbound_dnsbl.lga2
  id       = "unbound-dnsbl"
}
