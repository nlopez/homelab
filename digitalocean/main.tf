terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "digitalocean/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.109"
    }
  }
}

# Reads DIGITALOCEAN_TOKEN from the environment.
provider "digitalocean" {}
