terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "ses/terraform.tfstate"
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

# The DKIM CNAMEs, MAIL FROM MX/SPF and _amazonses TXT records live in
# dns/desertbluffs.com.tf. The per-app senders live in aws/<app>-smtp.

import {
  to = aws_sesv2_email_identity.desertbluffs_com
  id = "desertbluffs.com"
}

resource "aws_sesv2_email_identity" "desertbluffs_com" {
  email_identity = "desertbluffs.com"
}

import {
  to = aws_sesv2_email_identity_mail_from_attributes.desertbluffs_com
  id = "desertbluffs.com"
}

resource "aws_sesv2_email_identity_mail_from_attributes" "desertbluffs_com" {
  email_identity         = aws_sesv2_email_identity.desertbluffs_com.email_identity
  mail_from_domain       = "ses.desertbluffs.com"
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
}

output "dkim_tokens" {
  value = aws_sesv2_email_identity.desertbluffs_com.dkim_signing_attributes[0].tokens
}
