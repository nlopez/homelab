# Apps with no SSO of their own. An Envoy Gateway SecurityPolicy in each
# app's namespace sends browsers here before the request reaches the app.
# Envoy's OIDC filter requires a client secret; the Kubernetes copy of each
# is the gateway-oidc-<app> item in the Automation vault.

variable "sonarr_client_secret" {
  type      = string
  sensitive = true
}

variable "radarr_client_secret" {
  type      = string
  sensitive = true
}

variable "homepage_client_secret" {
  type      = string
  sensitive = true
}

variable "shaarli_client_secret" {
  type      = string
  sensitive = true
}

variable "karakeep_client_secret" {
  type      = string
  sensitive = true
}

locals {
  gateway_apps = {
    sonarr = {
      name   = "Sonarr"
      host   = "jolthog.desertbluffs.com"
      secret = var.sonarr_client_secret
    }
    radarr = {
      name   = "Radarr"
      host   = "dumud.desertbluffs.com"
      secret = var.radarr_client_secret
    }
    homepage = {
      name   = "Homepage"
      host   = "bushi.desertbluffs.com"
      secret = var.homepage_client_secret
    }
    shaarli = {
      name   = "Shaarli"
      host   = "gumoss.desertbluffs.com"
      secret = var.shaarli_client_secret
    }
  }
}

resource "authentik_provider_oauth2" "gateway" {
  for_each = local.gateway_apps

  name               = each.key
  client_type        = "confidential"
  client_id          = each.key
  client_secret      = each.value.secret
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.default.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc.ids
  grant_types        = ["authorization_code", "refresh_token"]

  allowed_redirect_uris = [{
    matching_mode     = "strict"
    redirect_uri_type = "authorization"
    url               = "https://${each.value.host}/oauth2/callback"
  }]
}

resource "authentik_application" "gateway" {
  for_each = local.gateway_apps

  name              = each.value.name
  slug              = each.key
  protocol_provider = authentik_provider_oauth2.gateway[each.key].id
  meta_launch_url   = "https://${each.value.host}/"
}

resource "authentik_provider_oauth2" "karakeep" {
  name               = "Karakeep"
  client_type        = "confidential"
  client_id          = "karakeep"
  client_secret      = var.karakeep_client_secret
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.default.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc.ids
  grant_types        = ["authorization_code"]

  allowed_redirect_uris = [{
    matching_mode     = "strict"
    redirect_uri_type = "authorization"
    url               = "https://spheal.desertbluffs.com/api/auth/callback/custom"
  }]
}

resource "authentik_application" "karakeep" {
  name              = "Karakeep"
  slug              = "karakeep"
  protocol_provider = authentik_provider_oauth2.karakeep.id
  meta_launch_url   = "https://spheal.desertbluffs.com/"
}
