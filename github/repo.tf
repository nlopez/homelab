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

# Rulesets are only available on public repositories or on a paid plan, so
# this is off until var.public or var.rulesets is set. Every change reaches
# main through a pull request whose ci-ok check passed
# (.github/workflows/ci-gate.yaml). Nobody bypasses it, admins included.
resource "github_repository_ruleset" "main" {
  count = var.public || var.rulesets ? 1 : 0

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

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true
    required_signatures     = true

    # No approval is required, so agents can merge their own PRs once ci-ok
    # passes. AGENTS.md says when a human must approve.
    pull_request {
      required_approving_review_count = 0
    }

    required_status_checks {
      # ci-ok as posted by the ci-gate app (ci-gate.tf), from main's copy of
      # the gate. A PR's own workflows can only post as GitHub Actions, so
      # they can't satisfy this.
      required_check {
        context        = "ci-ok"
        integration_id = var.ci_gate_app_id
      }

      # A PR must contain the latest main before it merges, so its plans
      # reflect every change merged before it.
      strict_required_status_checks_policy = true
    }
  }
}
