# OPNsense WebGUI sign-in through the os-sso plugin on each gateway. The
# plugin is installed and configured by hand in each gateway's GUI; authentik
# generates the client secret, which is copied from the provider into the
# plugin's server entry.
#
# Only gateway-admins and gateway-viewers may authorize. os-sso maps
# gateway-admins to the OPNsense admins group (firewall admin) and
# gateway-viewers to the viewers group (status and log pages only).

locals {
  opnsense_gateways = {
    lga2 = "gw.lga2.radoncanyon.com"
  }
}

resource "authentik_group" "gateway_admins" {
  name = "gateway-admins"
  users = [
    data.authentik_user.akadmin.id,
  ]
}

resource "authentik_group" "gateway_viewers" {
  name = "gateway-viewers"
  users = [
    authentik_user.nlopez.id,
  ]
}

resource "authentik_provider_oauth2" "opnsense" {
  for_each = local.opnsense_gateways

  name               = "opnsense-${each.key}"
  client_type        = "confidential"
  client_id          = "opnsense-${each.key}"
  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.default.id
  property_mappings = concat(
    data.authentik_property_mapping_provider_scope.oidc.ids,
    [authentik_property_mapping_provider_scope.groups.id],
  )
  grant_types = ["authorization_code"]

  allowed_redirect_uris = [{
    matching_mode     = "strict"
    redirect_uri_type = "authorization"
    url               = "https://${each.value}/api/sso/oidc/callback"
  }]
}

resource "authentik_application" "opnsense" {
  for_each = local.opnsense_gateways

  name              = "OPNsense ${each.key}"
  slug              = "opnsense-${each.key}"
  protocol_provider = authentik_provider_oauth2.opnsense[each.key].id
  meta_launch_url   = "https://${each.value}/"
}

resource "authentik_policy_binding" "opnsense_gateway_admins" {
  for_each = local.opnsense_gateways

  target = authentik_application.opnsense[each.key].uuid
  group  = authentik_group.gateway_admins.id
  order  = 0
}

resource "authentik_policy_binding" "opnsense_gateway_viewers" {
  for_each = local.opnsense_gateways

  target = authentik_application.opnsense[each.key].uuid
  group  = authentik_group.gateway_viewers.id
  order  = 0
}

output "opnsense_discovery_urls" {
  value = {
    for site, app in authentik_application.opnsense :
    site => "${local.public_url}/application/o/${app.slug}/.well-known/openid-configuration"
  }
}
