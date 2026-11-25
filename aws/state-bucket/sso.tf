# IAM Identity Center access for operators. Root is break-glass only: local
# applies use the AdministratorAccess permission set and everything else,
# including agents, uses ReadOnlyAccess.
data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  account_id        = "546422192262"
}

data "aws_identitystore_user" "nlopez" {
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = "nlopez"
    }
  }
}

resource "aws_identitystore_group" "administrators" {
  identity_store_id = local.identity_store_id
  display_name      = "Administrators"
}

resource "aws_identitystore_group_membership" "administrators_nlopez" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.administrators.group_id
  member_id         = data.aws_identitystore_user.nlopez.user_id
}

resource "aws_ssoadmin_permission_set" "administrator" {
  instance_arn     = local.sso_instance_arn
  name             = "AdministratorAccess"
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_ssoadmin_account_assignment" "administrators_admin" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.administrators.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = local.account_id
}

# ReadOnlyAccess includes s3:GetObject, so this can read tofu state, which
# holds the SES SMTP passwords. The inline policy lets it take and release the
# S3 native state locks so plans run with locking on. It can write only
# *.tflock objects, never state.
resource "aws_ssoadmin_permission_set" "read_only" {
  instance_arn     = local.sso_instance_arn
  name             = "ReadOnlyAccess"
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "read_only" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.read_only.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "read_only_state_lock" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.state.arn}/*.tflock"]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "read_only" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.read_only.arn
  inline_policy      = data.aws_iam_policy_document.read_only_state_lock.json
}

resource "aws_ssoadmin_account_assignment" "administrators_read_only" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.read_only.arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.administrators.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = local.account_id
}
