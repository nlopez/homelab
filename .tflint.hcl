# tflint configuration for the homelab repo
# https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md

# Enable the terraform recommended ruleset
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# AWS ruleset - pinned version for reproducibility
plugin "aws" {
  enabled = true
  version = "0.50.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
