# Lets the apply-on-main workflows on main write their state without
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

    # Only the production environment in this repository may assume these roles.
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

# Pull requests plan tailnet/tofu with read-only access to its state. Plans run
# with -lock=false, so no write to the lock file is needed.
data "aws_iam_policy_document" "github_actions_pull_request_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:nlopez@20211302/homelab@1466265485:pull_request"]
    }
  }
}

resource "aws_iam_role" "tailnet_plan" {
  name               = "homelab-tailnet-plan"
  assume_role_policy = data.aws_iam_policy_document.github_actions_pull_request_assume.json
}

data "aws_iam_policy_document" "tailnet_state_read" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.state.arn}/tailnet/*"]
  }
}

resource "aws_iam_role_policy" "tailnet_state_read" {
  role   = aws_iam_role.tailnet_plan.id
  policy = data.aws_iam_policy_document.tailnet_state_read.json
}

resource "aws_iam_role" "datadog_apply" {
  name               = "homelab-datadog-apply"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

data "aws_iam_policy_document" "datadog_state" {
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
    resources = ["${aws_s3_bucket.state.arn}/datadog/*"]
  }
}

resource "aws_iam_role_policy" "datadog_state" {
  role   = aws_iam_role.datadog_apply.id
  policy = data.aws_iam_policy_document.datadog_state.json
}

resource "aws_iam_role" "gateway_apply" {
  name               = "homelab-gateway-apply"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

data "aws_iam_policy_document" "gateway_state" {
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
    resources = ["${aws_s3_bucket.state.arn}/gateway/*"]
  }
}

resource "aws_iam_role_policy" "gateway_state" {
  role   = aws_iam_role.gateway_apply.id
  policy = data.aws_iam_policy_document.gateway_state.json
}

resource "aws_iam_role" "authentik_apply" {
  name               = "homelab-authentik-apply"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

data "aws_iam_policy_document" "authentik_state" {
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
    resources = ["${aws_s3_bucket.state.arn}/authentik/*"]
  }
}

resource "aws_iam_role_policy" "authentik_state" {
  role   = aws_iam_role.authentik_apply.id
  policy = data.aws_iam_policy_document.authentik_state.json
}

resource "aws_iam_role" "aws_apply" {
  name               = "homelab-aws-apply"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

# State access for the apply-on-push AWS stacks plus the SES and SMTP
# IAM resources each one manages.
data "aws_iam_policy_document" "aws_state" {
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
    resources = [
      "${aws_s3_bucket.state.arn}/ses/*",
      "${aws_s3_bucket.state.arn}/authentik-smtp/*",
      "${aws_s3_bucket.state.arn}/forgejo-smtp/*",
      "${aws_s3_bucket.state.arn}/seafile-smtp/*",
      "${aws_s3_bucket.state.arn}/nas-smtp/*",
      "${aws_s3_bucket.state.arn}/immich-smtp/*",
    ]
  }

  statement {
    actions = [
      "ses:CreateEmailIdentity",
      "ses:GetEmailIdentity",
      "ses:ListTagsForResource",
      "ses:DeleteEmailIdentity",
      "ses:PutEmailIdentityMailFromAttributes",
      "ses:GetEmailIdentityMailFromAttributes",
      "ses:DeleteEmailIdentity",
    ]
    resources = ["arn:aws:ses:us-east-1:546422192262:identity/desertbluffs.com"]
  }

  statement {
    actions = [
      "iam:CreateUser",
      "iam:GetUser",
      "iam:DeleteUser",
      "iam:PutUserPolicy",
      "iam:GetUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
    ]
    resources = [
      "arn:aws:iam::546422192262:user/authentik-smtp",
      "arn:aws:iam::546422192262:user/forgejo-smtp",
      "arn:aws:iam::546422192262:user/seafile-smtp",
      "arn:aws:iam::546422192262:user/nas-smtp",
      "arn:aws:iam::546422192262:user/immich-smtp",
    ]
  }
}

resource "aws_iam_role_policy" "aws_state" {
  role   = aws_iam_role.aws_apply.id
  policy = data.aws_iam_policy_document.aws_state.json
}

# Pull requests plan every apply-on-push stack with read-only access to its
# state. Each role is named homelab-<stack>-plan and reads only its own state
# prefixes.
locals {
  plan_state_prefixes = {
    authentik = ["authentik"]
    aws       = ["ses", "authentik-smtp", "forgejo-smtp", "seafile-smtp", "nas-smtp", "immich-smtp"]
    datadog   = ["datadog"]
    dns       = ["dns"]
    gateway   = ["gateway"]
    # The plan for tailnet/admin reads the tailnet with its own all:read
    # OAuth client, so the role only needs the state.
    tailnet-admin = ["tailnet-admin"]
  }
}

resource "aws_iam_role" "plan" {
  for_each = local.plan_state_prefixes

  name               = "homelab-${each.key}-plan"
  assume_role_policy = data.aws_iam_policy_document.github_actions_pull_request_assume.json
}

data "aws_iam_policy_document" "plan_state_read" {
  for_each = local.plan_state_prefixes

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = [for prefix in each.value : "${aws_s3_bucket.state.arn}/${prefix}/*"]
  }
}

resource "aws_iam_role_policy" "plan_state_read" {
  for_each = local.plan_state_prefixes

  role   = aws_iam_role.plan[each.key].id
  policy = data.aws_iam_policy_document.plan_state_read[each.key].json
}

# Refreshing the SES and SMTP stacks reads the resources they manage.
data "aws_iam_policy_document" "aws_plan_refresh" {
  statement {
    actions = [
      "ses:GetEmailIdentity",
      "ses:GetEmailIdentityMailFromAttributes",
      "ses:ListTagsForResource",
    ]
    resources = ["arn:aws:ses:us-east-1:546422192262:identity/desertbluffs.com"]
  }

  statement {
    actions = [
      "iam:GetUser",
      "iam:GetUserPolicy",
      "iam:ListAccessKeys",
    ]
    resources = [
      "arn:aws:iam::546422192262:user/authentik-smtp",
      "arn:aws:iam::546422192262:user/forgejo-smtp",
      "arn:aws:iam::546422192262:user/seafile-smtp",
      "arn:aws:iam::546422192262:user/nas-smtp",
      "arn:aws:iam::546422192262:user/immich-smtp",
    ]
  }
}

resource "aws_iam_role_policy" "aws_plan_refresh" {
  role   = aws_iam_role.plan["aws"].id
  policy = data.aws_iam_policy_document.aws_plan_refresh.json
}

# tailnet/admin applies on push with a CI copy of the admin API key.
resource "aws_iam_role" "tailnet_admin_apply" {
  name               = "homelab-tailnet-admin-apply"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

data "aws_iam_policy_document" "tailnet_admin_state" {
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
    resources = ["${aws_s3_bucket.state.arn}/tailnet-admin/*"]
  }
}

resource "aws_iam_role_policy" "tailnet_admin_state" {
  role   = aws_iam_role.tailnet_admin_apply.id
  policy = data.aws_iam_policy_document.tailnet_admin_state.json
}

# This stack applies itself on push. A role that can edit IAM roles can grant
# itself anything, so a narrower policy would not limit it; it gets
# AdministratorAccess. If an apply locks the role out (a broken trust policy or
# OIDC provider), a local apply with the AdministratorAccess permission set
# repairs it.
resource "aws_iam_role" "state_bucket_apply" {
  name               = "homelab-state-bucket-apply"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

resource "aws_iam_role_policy_attachment" "state_bucket_apply" {
  role       = aws_iam_role.state_bucket_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# The plan refreshes IAM, S3, and IAM Identity Center configuration across the
# account, so it gets ReadOnlyAccess. The deny keeps it from reading any state
# but its own, since other stacks' state holds SMTP passwords.
resource "aws_iam_role" "state_bucket_plan" {
  name               = "homelab-state-bucket-plan"
  assume_role_policy = data.aws_iam_policy_document.github_actions_pull_request_assume.json
}

resource "aws_iam_role_policy_attachment" "state_bucket_plan" {
  role       = aws_iam_role.state_bucket_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "state_bucket_plan_deny" {
  statement {
    effect        = "Deny"
    actions       = ["s3:GetObject", "s3:GetObjectVersion"]
    not_resources = ["${aws_s3_bucket.state.arn}/state-bucket/*"]
  }
}

resource "aws_iam_role_policy" "state_bucket_plan_deny" {
  role   = aws_iam_role.state_bucket_plan.id
  policy = data.aws_iam_policy_document.state_bucket_plan_deny.json
}
