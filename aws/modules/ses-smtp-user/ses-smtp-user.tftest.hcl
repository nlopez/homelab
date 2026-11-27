mock_provider "aws" {
  alias = "mock"

  mock_resource "aws_iam_user" {
    defaults = {
      id        = "mock-user-id"
      unique_id = "AIDACKCEVSQ6C2EXAMPLE"
    }
  }

  mock_resource "aws_iam_user_policy" {
    defaults = {
      id = "mock-policy-id"
    }
  }

  mock_resource "aws_iam_access_key" {
    defaults = {
      id                   = "AKIAIOSFODNN7EXAMPLE"
      secret               = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      ses_smtp_password_v4 = "mock-smtp-password-v4"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"ses:SendRawEmail\"],\"Resource\":[\"arn:aws:ses:us-east-1:123456789012:identity/desertbluffs.com\"],\"Condition\":{\"StringEquals\":{\"ses:FromAddress\":[\"test@desertbluffs.com\"]}}}]}"
    }
  }
}

override_data {
  target = data.aws_caller_identity.current
  values = {
    account_id = "123456789012"
  }
}

override_resource {
  target = aws_iam_user.this
}

override_resource {
  target = aws_iam_user_policy.send_as
}

override_resource {
  target = aws_iam_access_key.this
}

run "iam_user_name_built_from_variable" {
  providers = {
    aws = aws.mock
  }

  variables {
    name           = "myapp"
    from_addresses = ["noreply@desertbluffs.com"]
  }

  assert {
    condition     = aws_iam_user.this.name == "myapp-smtp"
    error_message = "IAM user name should be {var.name}-smtp"
  }

  assert {
    condition     = aws_iam_user_policy.send_as.name == "send-as-myapp"
    error_message = "IAM user policy name should be send-as-{var.name}"
  }
}

run "policy_allows_ses_send_raw_email" {
  providers = {
    aws = aws.mock
  }

  variables {
    name           = "app1"
    from_addresses = ["sender@desertbluffs.com"]
  }

  assert {
    condition = contains(
      data.aws_iam_policy_document.send_as.statement[0].actions,
      "ses:SendRawEmail"
    )
    error_message = "Policy should allow ses:SendRawEmail action"
  }
}

run "policy_restricts_resource_to_desertbluffs_identity" {
  providers = {
    aws = aws.mock
  }

  variables {
    name           = "app2"
    from_addresses = ["noreply@desertbluffs.com"]
  }

  assert {
    condition = contains(
      data.aws_iam_policy_document.send_as.statement[0].resources,
      "arn:aws:ses:us-east-1:123456789012:identity/desertbluffs.com"
    )
    error_message = "Policy should restrict to desertbluffs.com SES identity"
  }
}

run "policy_condition_restricts_from_addresses" {
  providers = {
    aws = aws.mock
  }

  variables {
    name           = "app3"
    from_addresses = ["sender1@desertbluffs.com", "sender2@desertbluffs.com"]
  }

  # Test that the policy condition restricts to exactly var.from_addresses
  assert {
    condition = anytrue([
      for c in data.aws_iam_policy_document.send_as.statement[0].condition :
      c.test == "StringEquals" && c.variable == "ses:FromAddress" && toset(c.values) == toset(var.from_addresses)
    ])
    error_message = "Policy must allow only var.from_addresses as ses:FromAddress"
  }
}

run "outputs_reference_access_key_id_and_ses_password" {
  providers = {
    aws = aws.mock
  }

  variables {
    name           = "output-test"
    from_addresses = ["test@desertbluffs.com"]
  }

  override_resource {
    target = aws_iam_access_key.this
    values = {
      id                   = "AKIAIOSFODNN7EXAMPLE"
      ses_smtp_password_v4 = "mock-smtp-password"
    }
  }

  assert {
    condition     = output.smtp_username == "AKIAIOSFODNN7EXAMPLE"
    error_message = "smtp_username output should be the access key ID"
  }

  assert {
    condition     = issensitive(output.smtp_password)
    error_message = "smtp_password output should be marked sensitive"
  }
}
