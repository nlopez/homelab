# Workload identity for the apply-on-main workflows: no stored secret, and the
# token exchange only happens from the production environment of this
# repository. Devices the runners join carry tag:ci, so the grants they get
# are the ones tag:ci gets in the policy. The runners drop off the tailnet
# when the job ends (the action stops tailscaled in post) and join again as
# fresh nodes on the next run.
resource "tailscale_federated_identity" "github_actions" {
  description = "homelab apply-on-main workflows"
  issuer      = "https://token.actions.githubusercontent.com"
  subject     = "repo:nlopez@20211302/homelab@1466265485:environment:production"
  scopes      = ["auth_keys", "devices:core"]
  tags        = ["tag:ci"]
}

output "ci_federated_identity_id" {
  value = tailscale_federated_identity.github_actions.id
}

output "ci_federated_identity_audience" {
  value = tailscale_federated_identity.github_actions.audience
}

# Workload identity for the pull-request plan jobs. Runners join with tag:ci
# too: the gateway plans need the same gateway API reach as the applies, and
# the Ansible check-mode run needs the same SSH access.
resource "tailscale_federated_identity" "github_actions_pull_request" {
  description = "homelab pull-request plan workflows"
  issuer      = "https://token.actions.githubusercontent.com"
  subject     = "repo:nlopez@20211302/homelab@1466265485:pull_request"
  scopes      = ["auth_keys", "devices:core"]
  tags        = ["tag:ci"]
}

output "ci_pull_request_federated_identity_id" {
  value = tailscale_federated_identity.github_actions_pull_request.id
}

output "ci_pull_request_federated_identity_audience" {
  value = tailscale_federated_identity.github_actions_pull_request.audience
}
