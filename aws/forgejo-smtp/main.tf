terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "forgejo-smtp/terraform.tfstate"
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
  from_address = "forgejo@desertbluffs.com"
}

resource "aws_iam_user" "forgejo_smtp" {
  name = "forgejo-smtp"
}

data "aws_iam_policy_document" "send_as_forgejo" {
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

resource "aws_iam_user_policy" "send_as_forgejo" {
  name   = "send-as-forgejo"
  user   = aws_iam_user.forgejo_smtp.name
  policy = data.aws_iam_policy_document.send_as_forgejo.json
}

resource "aws_iam_access_key" "forgejo_smtp" {
  user = aws_iam_user.forgejo_smtp.name
}

output "smtp_username" {
  value = aws_iam_access_key.forgejo_smtp.id
}

output "smtp_password" {
  value     = aws_iam_access_key.forgejo_smtp.ses_smtp_password_v4
  sensitive = true
}
