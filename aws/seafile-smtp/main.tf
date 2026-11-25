terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "seafile-smtp/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "smtp" {
  source         = "../modules/ses-smtp-user"
  name           = "seafile"
  from_addresses = ["seafile@desertbluffs.com"]
}

output "smtp_username" {
  value = module.smtp.smtp_username
}

output "smtp_password" {
  value     = module.smtp.smtp_password
  sensitive = true
}
