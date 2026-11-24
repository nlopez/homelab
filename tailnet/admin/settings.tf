# Tailnet-wide settings, so a GUI change shows up as a plan diff. The policy
# file itself is managed in tailnet/tofu; the admin console's policy editor is
# locked and links there.
resource "tailscale_tailnet_settings" "this" {
  acls_external_link                          = "https://github.com/nlopez/homelab/blob/main/tailnet/policy.hujson"
  acls_externally_managed_on                  = true
  devices_approval_on                         = false
  devices_auto_updates_on                     = true
  devices_key_duration_days                   = 10
  https_enabled                               = true
  network_flow_logging_on                     = false
  posture_identity_collection_on              = false
  route_selection                             = "active-passive-failover"
  users_approval_on                           = true
  users_role_allowed_to_join_external_tailnet = "admin"
}

import {
  to = tailscale_tailnet_settings.this
  id = "macaroni-pirate.ts.net"
}
