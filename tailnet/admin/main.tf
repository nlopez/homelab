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

# Reads its credentials from the environment. Applies use an admin API key
# (secrets.env); pull-request plans use a read-only OAuth client
# (secrets.pr.env).
provider "tailscale" {}
