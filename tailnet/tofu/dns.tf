# Tailnet-wide DNS. Devices keep their own resolvers and MagicDNS answers
# *.macaroni-pirate.ts.net. The two views of the site infrastructure are public
# records instead: radoncanyon.com for LAN and cluster addresses, nulogorsk.com
# for tailscale addresses.
resource "tailscale_dns_configuration" "this" {
  magic_dns          = true
  override_local_dns = false
}
