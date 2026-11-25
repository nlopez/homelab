# Read-only client for the pull-request ACL test and plan in the Tailnet
# workflow. Its
# ID and key live in the 1Password vault ci-pr, item "Tailscale ACL test":
#   tofu output -raw ci_pr_oauth_client_key
resource "tailscale_oauth_client" "ci_pr" {
  description = "homelab-ci-pr-acl-test"
  scopes      = ["devices:core:read", "devices:routes:read", "policy_file:read", "dns:read"]
}

output "ci_pr_oauth_client_id" {
  value = tailscale_oauth_client.ci_pr.id
}

output "ci_pr_oauth_client_key" {
  value     = tailscale_oauth_client.ci_pr.key
  sensitive = true
}

# Read-only client for the pull-request plan of this project. Its ID and key
# live in the 1Password vault ci-pr, item "tailnet-admin-api-key".
resource "tailscale_oauth_client" "ci_pr_admin" {
  description = "homelab-ci-pr-tailnet-admin-plan"
  scopes      = ["all:read"]
}

output "ci_pr_admin_oauth_client_id" {
  value = tailscale_oauth_client.ci_pr_admin.id
}

output "ci_pr_admin_oauth_client_key" {
  value     = tailscale_oauth_client.ci_pr_admin.key
  sensitive = true
}

# Write client for the Tailnet admin apply workflow and local applies. This
# project manages trust credentials, which can mint other credentials, so a
# narrower scope would not limit it; it gets all. Its ID and key live in the
# 1Password vault ci, item "tailnet-admin-api-key". The admin console's API
# access token stays the way back in if this client is revoked.
resource "tailscale_oauth_client" "ci_admin" {
  description = "homelab-ci-tailnet-admin-apply"
  scopes      = ["all"]
}

output "ci_admin_oauth_client_id" {
  value = tailscale_oauth_client.ci_admin.id
}

output "ci_admin_oauth_client_key" {
  value     = tailscale_oauth_client.ci_admin.key
  sensitive = true
}
