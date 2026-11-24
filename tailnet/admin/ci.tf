# Workload identity for the apply-on-main workflows: no stored secret, and the
# token exchange only happens from the production environment of this
# repository. Devices the runners join carry tag:ci, so the grants they get
# are the ones tag:ci gets in the policy. The runners drop off the tailnet
# when the job ends (the action stops tailscaled in post) and join again as
# fresh nodes on the next run.
resource "tailscale_federated_identity" "github_actions" {
  description = "homelab apply-on-main workflows"
  issuer      = "https://token.actions.githubusercontent.com"
  subject     = "repo:nlopez/homelab:environment:production"
  scopes      = ["devices:core"]
  tags        = ["tag:ci"]
}

output "ci_federated_identity_id" {
  value = tailscale_federated_identity.github_actions.id
}

output "ci_federated_identity_audience" {
  value = tailscale_federated_identity.github_actions.audience
}
