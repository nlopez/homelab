# Alert mail goes through SES using the IAM user from aws/nas-smtp, which may
# send only as these addresses. The password is write-only, so it never lands
# in this stack's state; bump pass_wo_version after rotating it.
variable "smtp_user" {
  type      = string
  sensitive = true
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

locals {
  pass_wo_version = 1
}

resource "truenas_mail" "nas1" {
  provider        = truenas.nas1
  fromemail       = "nas1@desertbluffs.com"
  outgoingserver  = "email-smtp.us-east-1.amazonaws.com"
  port            = 587
  security        = "TLS"
  smtp            = true
  user            = var.smtp_user
  pass            = var.smtp_password
  pass_wo_version = local.pass_wo_version
}

resource "truenas_mail" "nas2" {
  provider        = truenas.nas2
  fromemail       = "nas2@desertbluffs.com"
  outgoingserver  = "email-smtp.us-east-1.amazonaws.com"
  port            = 587
  security        = "TLS"
  smtp            = true
  user            = var.smtp_user
  pass            = var.smtp_password
  pass_wo_version = local.pass_wo_version
}
