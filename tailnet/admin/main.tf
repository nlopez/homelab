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

# Reads its credentials from the environment. Applies use the ci_admin OAuth
# client (secrets.env); pull-request plans use the read-only ci_pr_admin
# client.
provider "tailscale" {}
