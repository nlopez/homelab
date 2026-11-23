# Tailnet-wide DNS. Devices keep their own resolvers and MagicDNS answers
# *.macaroni-pirate.ts.net.
resource "tailscale_dns_configuration" "this" {
  magic_dns          = true
  override_local_dns = false
}

# Cluster services resolve through cluster PowerDNS (dnsdist), and site
# infrastructure resolves through the two gateways' Unbound resolvers.
resource "tailscale_dns_split_nameservers" "internal" {
  for_each = {
    "desertbluffs.com"     = ["100.95.107.254"]
    "lga1.radoncanyon.com" = ["100.83.144.88", "100.86.37.97"]
    "lga2.radoncanyon.com" = ["100.83.144.88", "100.86.37.97"]
  }

  domain      = each.key
  nameservers = each.value
}
