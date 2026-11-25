# A public client: Argo CD and its CLI use PKCE instead of a client secret.
resource "authentik_provider_oauth2" "argocd" {
  name               = "argocd"
  client_type        = "public"
  client_id          = "argocd"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.default.id
  # The groups claim feeds Argo CD's RBAC policy.csv.
  property_mappings = concat(
    data.authentik_property_mapping_provider_scope.oidc.ids,
    [authentik_property_mapping_provider_scope.groups.id],
  )
  grant_types = ["authorization_code", "refresh_token"]

  allowed_redirect_uris = [
    {
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "https://flopie.desertbluffs.com/auth/callback"
    },
    {
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "https://flopie.desertbluffs.com/pkce/verify"
    },
    {
      # argocd login --sso
      matching_mode     = "strict"
      redirect_uri_type = "authorization"
      url               = "http://localhost:8085/auth/callback"
    },
  ]
}

resource "authentik_application" "argocd" {
  name              = "Argo CD"
  slug              = "argocd"
  protocol_provider = authentik_provider_oauth2.argocd.id
  meta_launch_url   = "https://flopie.desertbluffs.com/"
}
