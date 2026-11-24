# Read-only client for the pull-request ACL test in the Tailnet workflow. Its
# ID and key live in the 1Password vault ci-pr, item "Tailscale ACL test":
#   tofu output -raw ci_pr_oauth_client_key
resource "tailscale_oauth_client" "ci_pr" {
  description = "homelab-ci-pr-acl-test"
  scopes      = ["policy_file:read"]
}

output "ci_pr_oauth_client_id" {
  value = tailscale_oauth_client.ci_pr.id
}

output "ci_pr_oauth_client_key" {
  value     = tailscale_oauth_client.ci_pr.key
  sensitive = true
}
