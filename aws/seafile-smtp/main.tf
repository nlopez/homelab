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

data "aws_caller_identity" "current" {}

locals {
  from_address = "seafile@desertbluffs.com"
}

resource "aws_iam_user" "seafile_smtp" {
  name = "seafile-smtp"
}

data "aws_iam_policy_document" "send_as_seafile" {
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

resource "aws_iam_user_policy" "send_as_seafile" {
  name   = "send-as-seafile"
  user   = aws_iam_user.seafile_smtp.name
  policy = data.aws_iam_policy_document.send_as_seafile.json
}

resource "aws_iam_access_key" "seafile_smtp" {
  user = aws_iam_user.seafile_smtp.name
}

output "smtp_username" {
  value = aws_iam_access_key.seafile_smtp.id
}

output "smtp_password" {
  value     = aws_iam_access_key.seafile_smtp.ses_smtp_password_v4
  sensitive = true
}
