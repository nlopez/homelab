terraform {
  required_version = ">= 1.11"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "truenas/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    truenas = {
      source  = "truenas/truenas"
      version = "~> 1.9"
    }
  }
}

variable "nas1_api_key" {
  type      = string
  sensitive = true
}

variable "nas2_api_key" {
  type      = string
  sensitive = true
}

provider "truenas" {
  alias    = "nas1"
  endpoint = "wss://nas1.lga1.radoncanyon.com/api/current"
  api_key  = var.nas1_api_key
}

provider "truenas" {
  alias    = "nas2"
  endpoint = "wss://nas2.lga1.radoncanyon.com/api/current"
  api_key  = var.nas2_api_key
}
