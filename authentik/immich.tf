# A public client: Immich uses PKCE instead of a client secret. The Immich
# side is set in its admin UI, because Immich keeps all system settings
# (including the SMTP password) in one config that a config file would
# replace.
resource "authentik_provider_oauth2" "immich" {
  name               = "immich"
  client_type        = "public"
  client_id          = "immich"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.default.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc.ids
  grant_types        = ["authorization_code", "refresh_token"]

  allowed_redirect_uris = [
    {
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "https://nox.desertbluffs.com/auth/login"
    },
    {
      # Linking an existing Immich account from its account settings.
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "https://nox.desertbluffs.com/user-settings"
    },
    {
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "app.immich:///oauth-callback"
    },
  ]
}

resource "authentik_application" "immich" {
  name              = "Immich"
  slug              = "immich"
  protocol_provider = authentik_provider_oauth2.immich.id
  # autoLaunch=1 starts SSO directly, skipping Immich's login page.
  meta_launch_url = "https://nox.desertbluffs.com/auth/login?autoLaunch=1"
}
