# Lets the Tailnet and DNS workflows on main write their state without
# long-lived AWS keys. If the account already has a GitHub OIDC provider, import
# it instead of creating a second one:
#   tofu import aws_iam_openid_connect_provider.github \
#     arn:aws:iam::546422192262:oidc-provider/token.actions.githubusercontent.com
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    # Only the production environment in this repository may assume the role.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # The repository uses immutable subject claims, so the sub carries the
    # owner and repository IDs instead of their names.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:nlopez@20211302/homelab@1466265485:environment:production"]
    }
  }
}

resource "aws_iam_role" "tailnet_apply" {
  name               = "homelab-tailnet-apply"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

data "aws_iam_policy_document" "tailnet_state" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.state.arn}/tailnet/*"]
  }
}

resource "aws_iam_role_policy" "tailnet_state" {
  role   = aws_iam_role.tailnet_apply.id
  policy = data.aws_iam_policy_document.tailnet_state.json
}

resource "aws_iam_role" "dns_apply" {
  name               = "homelab-dns-apply"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

data "aws_iam_policy_document" "dns_state" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.state.arn}/dns/*"]
  }
}

resource "aws_iam_role_policy" "dns_state" {
  role   = aws_iam_role.dns_apply.id
  policy = data.aws_iam_policy_document.dns_state.json
}
