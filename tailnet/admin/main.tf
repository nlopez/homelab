terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "tailnet-admin/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.30"
    }
  }
}

# Reads TAILSCALE_API_KEY and TAILSCALE_TAILNET from the environment. These
# resources need admin scope, so this project is applied from a workstation
# with the superuser token and never from CI.
provider "tailscale" {}
