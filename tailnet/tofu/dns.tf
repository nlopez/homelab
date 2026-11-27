# Tailnet-wide DNS. Devices keep their own resolvers and MagicDNS answers
# *.macaroni-pirate.ts.net.
#
# This resource owns the whole DNS configuration, split DNS included. The
# provider documents it as conflicting with tailscale_dns_split_nameservers,
# which would otherwise fight it over the same entries on every apply.
#
# Private desertbluffs.com names are Unbound host overrides on the two
# gateways, so tailnet clients use the same resolvers as the sites' LANs.
# radoncanyon.com needs no entry: its site names are public records in dns/.
locals {
  split_dns = {
    "desertbluffs.com" = ["100.83.144.88", "100.86.37.97"]
  }
}

resource "tailscale_dns_configuration" "this" {
  magic_dns          = true
  override_local_dns = false

  dynamic "split_dns" {
    for_each = local.split_dns

    content {
      domain = split_dns.key

      dynamic "nameservers" {
        for_each = split_dns.value

        content {
          address = nameservers.value
        }
      }
    }
  }
}

# Forget the old per-domain resources without deleting the live entries.
removed {
  from = tailscale_dns_split_nameservers.internal

  lifecycle {
    destroy = false
  }
}
