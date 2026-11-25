# An IAM user whose SES SMTP credentials may send only as the given addresses
# in the desertbluffs.com identity.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "name" {
  description = "Short app name. The IAM user is <name>-smtp."
  type        = string
}

variable "from_addresses" {
  description = "Addresses this user may send as."
  type        = list(string)
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "this" {
  name = "${var.name}-smtp"
}

data "aws_iam_policy_document" "send_as" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["arn:aws:ses:us-east-1:${data.aws_caller_identity.current.account_id}:identity/desertbluffs.com"]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = var.from_addresses
    }
  }
}

resource "aws_iam_user_policy" "send_as" {
  name   = "send-as-${var.name}"
  user   = aws_iam_user.this.name
  policy = data.aws_iam_policy_document.send_as.json
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

output "smtp_username" {
  value = aws_iam_access_key.this.id
}

output "smtp_password" {
  value     = aws_iam_access_key.this.ses_smtp_password_v4
  sensitive = true
}
