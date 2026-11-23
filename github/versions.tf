terraform {
  required_version = ">= 1.6"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Reads GITHUB_TOKEN from the environment.
provider "github" {
  owner = "nlopez"
}
