# Tailnet-wide DNS. Devices keep their own resolvers and MagicDNS answers
# *.macaroni-pirate.ts.net. The two views of the site infrastructure are public
# records instead: radoncanyon.com for LAN and cluster addresses, nulogorsk.com
# for tailscale addresses.
resource "tailscale_dns_configuration" "this" {
  magic_dns          = true
  override_local_dns = false
}

# Clients resolve the cluster's zone through Technitium wherever they are, so a
# device off the site LAN gets the internal answers instead of the public ones.
resource "tailscale_dns_split_nameservers" "internal" {
  for_each = toset(["desertbluffs.com", "nulogorsk.com"])

  domain      = each.value
  nameservers = ["100.95.107.254", "100.127.60.59", "100.110.65.2"]
}
