# The tamper-proof ci-ok gate. GitHub Actions can't stop a pull request's own
# workflows from posting a passing "ci-ok" as GitHub Actions, so the gate posts
# it as a GitHub App instead, and the main ruleset requires the app's ci-ok.
# The app's private key lives in the ci-gate environment, which only jobs
# running against main can read: the gate runs on pull_request_target (main's
# workflow and scripts, never the PR's code), so PR workflows never see it.
#
# GitHub Apps can't be created through the API or this provider, only by the
# manifest flow in a browser: scripts/create-ci-gate-app does that, stores the
# key in the environment secret (so it never enters this stack's state), and
# prints the ID to set here.

variable "ci_gate_app_id" {
  type        = number
  default     = null
  description = "ID of the GitHub App that posts the protected ci-ok check (scripts/create-ci-gate-app prints it)."
}

resource "github_repository_environment" "ci_gate" {
  repository        = github_repository.homelab.name
  environment       = "ci-gate"
  can_admins_bypass = false

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "ci_gate_main" {
  repository     = github_repository.homelab.name
  environment    = github_repository_environment.ci_gate.environment
  branch_pattern = "main"
}

resource "github_actions_variable" "ci_gate_app_id" {
  count = var.ci_gate_app_id == null ? 0 : 1

  repository    = github_repository.homelab.name
  variable_name = "CI_GATE_APP_ID"
  value         = tostring(var.ci_gate_app_id)
}
