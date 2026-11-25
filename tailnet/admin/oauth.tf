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
# live in the 1Password vault ci-pr, item "tailnet-admin-read-only".
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
