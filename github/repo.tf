resource "github_repository" "homelab" {
  name        = "homelab"
  description = "Homelab monorepo: k8s, ansible, tailnet, dns, media-toolbox"
  visibility  = var.public ? "public" : "private"

  has_issues      = true
  has_wiki        = false
  has_projects    = false
  has_discussions = false

  allow_squash_merge          = true
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_auto_merge            = true
  allow_update_branch         = false
  delete_branch_on_merge      = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"

  archive_on_destroy = true

  # Secret scanning is free on public repositories only.
  dynamic "security_and_analysis" {
    for_each = var.public ? [1] : []
    content {
      secret_scanning {
        status = "enabled"
      }
      secret_scanning_push_protection {
        status = "enabled"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository_vulnerability_alerts" "homelab" {
  repository = github_repository.homelab.name
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "homelab" {
  repository = github_repository.homelab.name
  enabled    = true

  depends_on = [github_repository_vulnerability_alerts.homelab]
}

resource "github_actions_repository_permissions" "homelab" {
  repository           = github_repository.homelab.name
  enabled              = true
  allowed_actions      = "all"
  sha_pinning_required = true
}

resource "github_workflow_repository_permissions" "homelab" {
  repository                       = github_repository.homelab.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}

# The dns and tailnet apply jobs run in this environment, and their AWS role
# trust policies match its OIDC subject. Only main can deploy to it.
resource "github_repository_environment" "production" {
  repository        = github_repository.homelab.name
  environment       = "production"
  can_admins_bypass = true

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "production_main" {
  repository     = github_repository.homelab.name
  environment    = github_repository_environment.production.environment
  branch_pattern = "main"
}

# Rulesets are only available on public repositories (or a paid plan), so this
# is off until var.public is set. Repository admins bypass, which keeps the
# `wt merge` flow of pushing straight to main working.
resource "github_repository_ruleset" "main" {
  count = var.public ? 1 : 0

  name        = "main"
  repository  = github_repository.homelab.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 5 # Repository admin role
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true
    required_signatures     = true
  }
}
