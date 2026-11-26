terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "github/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Locally the token comes from GITHUB_TOKEN (gh auth token; see README): with
# github_token unset, the provider reads that. A pull-request plan sets
# github_token to the read-only token in secrets.plan.env.
provider "github" {
  owner = "nlopez"
  token = var.github_token
}
