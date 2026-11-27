# Module-specific tflint configuration
# Disable rules not applicable to modules; stacks that use them have the constraints

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}
