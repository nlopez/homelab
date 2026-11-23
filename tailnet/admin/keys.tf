# The auth key the gateway workflows join the tailnet with: ephemeral, so each
# run's node disappears when it disconnects, and preauthorized so the run needs
# no approval. Rotate with
#
#   tofu apply -replace=tailscale_tailnet_key.github_actions
#   tofu output -raw github_actions_key | gh secret set TS_AUTHKEY --env production
resource "tailscale_tailnet_key" "github_actions" {
  description   = "GitHub Actions gateway workflows"
  ephemeral     = true
  preauthorized = true
  reusable      = false
  tags          = ["tag:ci"]
  expiry        = 7776000

  lifecycle {
    create_before_destroy = true
  }
}

output "github_actions_key" {
  value     = tailscale_tailnet_key.github_actions.key
  sensitive = true
}

import {
  to = tailscale_tailnet_key.github_actions
  id = "kDmD2f41SJ11"
}
