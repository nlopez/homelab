# An email change in the user settings flow requires a fresh MFA check and a
# link sent to the new address before the user write stage saves it. The
# address is the login identifier and the OIDC email claim, so an unverified
# change could hand the account, or an app account linked by email, to an
# address the user does not control.
#
# The link continues the flow in the browser that opens it, which must be
# signed in to authentik because the flow requires an authenticated user.

data "authentik_flow" "default_user_settings" {
  slug = "default-user-settings-flow"
}

resource "authentik_policy_expression" "email_changed" {
  name       = "user-settings-email-changed"
  expression = <<-EOT
    user = request.context.get("pending_user") or request.user
    new = request.context.get("prompt_data", {}).get("email", "").strip()
    if not new or new.lower() == (user.email or "").strip().lower():
        return False
    # The email stage sends to this address instead of the current one.
    request.context["flow_plan"].context["email"] = new
    return True
  EOT
}

resource "authentik_stage_authenticator_validate" "email_change" {
  name                       = "user-settings-email-change-mfa"
  device_classes             = ["webauthn", "totp", "static"]
  not_configured_action      = "deny"
  last_auth_threshold        = "seconds=0"
  webauthn_user_verification = "required"
}

resource "authentik_stage_email" "email_change" {
  name                     = "user-settings-email-change-verify"
  use_global_settings      = true
  template                 = "email/account_confirmation.html"
  subject                  = "Confirm your new authentik email address"
  token_expiry             = "minutes=30"
  activate_user_on_success = false
}

# The prompt stage is at order 20 and the user write stage at 100, both from
# the default blueprint.
resource "authentik_flow_stage_binding" "email_change_mfa" {
  target               = data.authentik_flow.default_user_settings.id
  stage                = authentik_stage_authenticator_validate.email_change.id
  order                = 30
  evaluate_on_plan     = false
  re_evaluate_policies = true
}

resource "authentik_flow_stage_binding" "email_change_verify" {
  target               = data.authentik_flow.default_user_settings.id
  stage                = authentik_stage_email.email_change.id
  order                = 40
  evaluate_on_plan     = false
  re_evaluate_policies = true
}

resource "authentik_policy_binding" "email_change_mfa" {
  target = authentik_flow_stage_binding.email_change_mfa.id
  policy = authentik_policy_expression.email_changed.id
  order  = 0
}

resource "authentik_policy_binding" "email_change_verify" {
  target = authentik_flow_stage_binding.email_change_verify.id
  policy = authentik_policy_expression.email_changed.id
  order  = 0
}

# A singleton; every field is set because the provider sends its own default
# for any that are left out. Email changes are allowed because the bindings
# above gate them.
resource "authentik_system_settings" "this" {
  avatars                      = "gravatar,initials"
  default_user_change_name     = true
  default_user_change_email    = true
  default_user_change_username = false
  event_retention              = "days=365"
  reputation_lower_limit       = -5
  reputation_upper_limit       = 5
  footer_links                 = []
  gdpr_compliance              = true
  impersonation                = true
  default_token_duration       = "days=1"
  default_token_length         = 60
  pagination_default_page_size = 20
  pagination_max_page_size     = 100
  flags = jsonencode({
    flows_refresh_others                   = false
    flows_continuous_login                 = false
    core_default_app_access                = true
    enterprise_audit_include_expanded_diff = false
  })
}
