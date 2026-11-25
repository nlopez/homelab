variable "forgejo_client_id" {
  type      = string
  sensitive = true
}

variable "forgejo_client_secret" {
  type      = string
  sensitive = true
}

resource "authentik_provider_oauth2" "forgejo" {
  name               = "forgejo"
  client_type        = "confidential"
  client_id          = var.forgejo_client_id
  client_secret      = var.forgejo_client_secret
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.default.id
  property_mappings = concat(
    data.authentik_property_mapping_provider_scope.oidc.ids,
    [authentik_property_mapping_provider_scope.picture.id],
    # Carries group names to Forgejo; ADMIN_GROUP in its chart values maps
    # the admins group to site admin on each sign-in.
    [authentik_property_mapping_provider_scope.groups.id],
  )
  grant_types = ["authorization_code", "refresh_token"]

  # The source name in the forgejo chart values sets the callback path.
  allowed_redirect_uris = [{
    matching_mode     = "strict"
    redirect_uri_type = "authorization"
    url               = "https://dazzi.desertbluffs.com/user/oauth2/authentik/callback"
  }]
}

resource "authentik_application" "forgejo" {
  name              = "Forgejo"
  slug              = "forgejo"
  protocol_provider = authentik_provider_oauth2.forgejo.id
  meta_launch_url   = "https://dazzi.desertbluffs.com/"
  meta_icon         = "https://dazzi.desertbluffs.com/assets/img/logo.svg"
}

output "forgejo_discovery_url" {
  value = "${local.public_url}/application/o/${authentik_application.forgejo.slug}/.well-known/openid-configuration"
}
