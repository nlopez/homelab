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
      # 2026.8.2 adds flow_request et al. to authentik_brand's update, so
      # taking over the default brand stops dropping its system-set flows.
      source  = "goauthentik/authentik"
      version = "2026.8.2"
    }
  }
}

# Reads AUTHENTIK_TOKEN from the environment.
provider "authentik" {
  url = "https://arsox.desertbluffs.com"
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

  # Only the ID is used, and pull-request plans can't read private keys.
  fetch_key         = false
  fetch_certificate = false
}

data "authentik_property_mapping_provider_scope" "oidc" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile",
  ]
}

# Adds the standard OIDC picture claim to the profile scope, alongside the
# managed profile mapping.
resource "authentik_property_mapping_provider_scope" "picture" {
  name       = "OIDC picture claim"
  scope_name = "profile"
  expression = "return {\"picture\": request.user.avatar}"
}

# Emits the user's authentik group names as the OIDC groups claim.
resource "authentik_property_mapping_provider_scope" "groups" {
  name       = "OIDC groups claim"
  scope_name = "groups"
  expression = "return {\"groups\": [group.name for group in request.user.ak_groups]}"
}
