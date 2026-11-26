variable "seafile_client_secret" {
  type      = string
  sensitive = true
}

# Seafile maps the OIDC sub claim to its own user.
resource "authentik_provider_oauth2" "seafile" {
  name               = "seafile"
  client_type        = "confidential"
  client_id          = "seafile"
  client_secret      = var.seafile_client_secret
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.default.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc.ids
  grant_types        = ["authorization_code"]

  allowed_redirect_uris = [{
    matching_mode     = "strict"
    redirect_uri_type = "authorization"
    url               = "https://dogen.desertbluffs.com/oauth/callback/"
  }]
}

resource "authentik_application" "seafile" {
  name              = "Seafile"
  slug              = "seafile"
  protocol_provider = authentik_provider_oauth2.seafile.id
  # /oauth/login/ starts SSO directly, skipping Seafile's login page.
  meta_launch_url = "https://dogen.desertbluffs.com/oauth/login/"
}
