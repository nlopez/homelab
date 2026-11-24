terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "authentik/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "~> 2026.8"
    }
  }
}

# Reads AUTHENTIK_TOKEN from the environment.
provider "authentik" {
  url = "https://auth.desertbluffs.com"
}

locals {
  # The internet hostname, so OIDC endpoints work for apps and browsers that
  # are not on the LAN or tailnet.
  public_url = "https://arsox.desertbluffs.com"
}

data "authentik_flow" "default_authorization" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

data "authentik_property_mapping_provider_scope" "oidc" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile",
  ]
}
