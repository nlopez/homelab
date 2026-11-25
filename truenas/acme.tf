# DNS-01 authenticator for the ACME UI certificates. The Cloudflare token is
# scoped to DNS write on radoncanyon.com and sent write-only, so it never lands
# in state; bump acme_token_version after rotating it.
variable "acme_cloudflare_token" {
  type      = string
  sensitive = true
}

locals {
  acme_token_version = 1
}

resource "truenas_acme_dns_authenticator" "cloudflare_nas1" {
  provider                      = truenas.nas1
  name                          = "cloudflare"
  attributes                    = jsonencode({ authenticator = "cloudflare" })
  attributes_secrets_wo         = jsonencode({ api_token = var.acme_cloudflare_token })
  attributes_secrets_wo_version = local.acme_token_version
}

resource "truenas_acme_dns_authenticator" "cloudflare_nas2" {
  provider                      = truenas.nas2
  name                          = "cloudflare"
  attributes                    = jsonencode({ authenticator = "cloudflare" })
  attributes_secrets_wo         = jsonencode({ api_token = var.acme_cloudflare_token })
  attributes_secrets_wo_version = local.acme_token_version
}
