terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "gateway/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    opnsense = {
      source  = "matthew-on-git/opnsense"
      version = "~> 0.30"
    }
  }
}

variable "lga1_api_key" {
  type      = string
  sensitive = true
}

variable "lga1_api_secret" {
  type      = string
  sensitive = true
}

variable "lga2_api_key" {
  type      = string
  sensitive = true
}

variable "lga2_api_secret" {
  type      = string
  sensitive = true
}

provider "opnsense" {
  alias      = "lga1"
  uri        = "https://gw.lga1.radoncanyon.com"
  api_key    = var.lga1_api_key
  api_secret = var.lga1_api_secret
}

provider "opnsense" {
  alias      = "lga2"
  uri        = "https://gw.lga2.radoncanyon.com"
  api_key    = var.lga2_api_key
  api_secret = var.lga2_api_secret
}
