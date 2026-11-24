terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "authentik-smtp/terraform.tfstate"
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

data "aws_caller_identity" "current" {}

locals {
  from_address = "authentik@desertbluffs.com"
}

resource "aws_iam_user" "authentik_smtp" {
  name = "authentik-smtp"
}

data "aws_iam_policy_document" "send_as_authentik" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["arn:aws:ses:us-east-1:${data.aws_caller_identity.current.account_id}:identity/desertbluffs.com"]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = [local.from_address]
    }
  }
}

resource "aws_iam_user_policy" "send_as_authentik" {
  name   = "send-as-authentik"
  user   = aws_iam_user.authentik_smtp.name
  policy = data.aws_iam_policy_document.send_as_authentik.json
}

resource "aws_iam_access_key" "authentik_smtp" {
  user = aws_iam_user.authentik_smtp.name
}

output "smtp_username" {
  value = aws_iam_access_key.authentik_smtp.id
}

output "smtp_password" {
  value     = aws_iam_access_key.authentik_smtp.ses_smtp_password_v4
  sensitive = true
}
