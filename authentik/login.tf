data "authentik_stage" "default_mfa_validation" {
  name = "default-authentication-mfa-validation"
}

import {
  to = authentik_stage_identification.default
  id = "1d283674-02f5-4693-82f3-455da955c518"
}

# The first stage of default-authentication-flow. The webauthn stage offers
# passkey autofill in the username field; that flow's bound policies skip the
# password and MFA stages after a passkey login.
resource "authentik_stage_identification" "default" {
  name                      = "default-authentication-identification"
  user_fields               = ["email", "username"]
  case_insensitive_matching = true
  show_matched_user         = true
  pretend_user_exists       = true
  enable_remember_me        = false
  show_source_labels        = false
  webauthn_stage            = data.authentik_stage.default_mfa_validation.id
}
