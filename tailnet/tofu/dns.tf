# Tailnet-wide DNS. No nameservers are set, so devices keep their local
# resolvers and only the split-DNS domains below are answered by the tailnet.
resource "tailscale_dns_configuration" "this" {
  magic_dns          = true
  override_local_dns = false

  split_dns {
    domain = "desertbluffs.com"
    nameservers {
      address            = "fd54:571b:560a:2::1"
      use_with_exit_node = true
    }
  }

  split_dns {
    domain = "radoncanyon.com"
    nameservers {
      address            = "fd54:571b:560a:2::1"
      use_with_exit_node = true
    }
  }
}
