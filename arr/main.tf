terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "arr/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    sonarr = {
      source  = "devopsarr/sonarr"
      version = "~> 3.6"
    }
    radarr = {
      source  = "devopsarr/radarr"
      version = "~> 2.5"
    }
  }
}

# The /api routes skip the gateway's OIDC SecurityPolicy, so the app API keys
# are enough. The hostnames resolve on the LAN and tailnet only.
provider "sonarr" {
  url     = "https://jolthog.desertbluffs.com"
  api_key = var.sonarr_api_key
}

provider "radarr" {
  url     = "https://dumud.desertbluffs.com"
  api_key = var.radarr_api_key
}
