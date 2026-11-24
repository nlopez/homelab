terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "tailnet/terraform.tfstate"
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

# Reads TAILSCALE_OAUTH_CLIENT_ID, TAILSCALE_OAUTH_CLIENT_SECRET and
# TAILSCALE_TAILNET from the environment. The scopes are listed explicitly so
# device writes (tags and subnet route approvals) are granted alongside the
# policy file and DNS. Pull-request plans pass the read-only equivalents.
variable "oauth_scopes" {
  type    = list(string)
  default = ["devices:core:write", "devices:routes:write", "policy_file:write", "dns:write"]
}

provider "tailscale" {
  scopes = var.oauth_scopes
}
