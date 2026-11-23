# Tailnet-wide DNS. No nameservers are set, so devices keep their local
# resolvers and only the split-DNS domains below are answered by the tailnet.
#
# The site gateways' Unbound owns the private names and stays up when the
# cluster is down. Unbound on either gateway answers every name in these
# domains, so both are listed and a dead gateway costs one timeout, not the
# lookup.
locals {
  gateway_dns = [
    data.tailscale_device.gw_lga1.addresses[0],
    data.tailscale_device.gw_lga2.addresses[0],
  ]
}

resource "tailscale_dns_configuration" "this" {
  magic_dns          = true
  override_local_dns = false

  split_dns {
    domain = "desertbluffs.com"
    nameservers {
      address            = local.gateway_dns[0]
      use_with_exit_node = true
    }
    nameservers {
      address            = local.gateway_dns[1]
      use_with_exit_node = true
    }
  }

  # Site infrastructure. These names exist only in the gateways' Unbound
  # overrides and in public DNS not at all, so they resolve on the tailnet and
  # the LAN and nowhere else.
  split_dns {
    domain = "lga1.radoncanyon.com"
    nameservers {
      address            = local.gateway_dns[0]
      use_with_exit_node = true
    }
    nameservers {
      address            = local.gateway_dns[1]
      use_with_exit_node = true
    }
  }

  split_dns {
    domain = "lga2.radoncanyon.com"
    nameservers {
      address            = local.gateway_dns[0]
      use_with_exit_node = true
    }
    nameservers {
      address            = local.gateway_dns[1]
      use_with_exit_node = true
    }
  }
}
