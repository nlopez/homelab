import {
  provider = truenas.nas1
  to       = truenas_acme_dns_authenticator.cloudflare_nas1
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_acme_dns_authenticator.cloudflare_nas2
  id       = "2"
}
