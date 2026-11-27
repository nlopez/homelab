variable "netbox_client_secret" {
  type      = string
  sensitive = true
}

resource "authentik_provider_oauth2" "netbox" {
  name               = "netbox"
  client_type        = "confidential"
  client_id          = "netbox"
  client_secret      = var.netbox_client_secret
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.default.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc.ids
  grant_types        = ["authorization_code"]

  allowed_redirect_uris = [{
    matching_mode     = "strict"
    redirect_uri_type = "authorization"
    url               = "https://kikit.desertbluffs.com/oauth/complete/oidc/"
  }]
}

resource "authentik_application" "netbox" {
  name              = "NetBox"
  slug              = "netbox"
  protocol_provider = authentik_provider_oauth2.netbox.id
  # /oauth/login/oidc/ starts SSO directly, skipping NetBox's login page.
  meta_launch_url = "https://kikit.desertbluffs.com/oauth/login/oidc/"
}
