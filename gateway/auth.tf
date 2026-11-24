# The admin group and the ACME account on both gateways.
#
# Not managed, and why:
# - Auth users. `password` is required on every write, so managing a user means
#   either committing a password or leaving an empty one that the provider would
#   push on an unrelated update.
# - Trust CAs and certificates. The ACME client owns them (all but one carry an
#   "(ACME Client)" description) and renews them, so an import churns on every
#   renewal. Their private keys are write-only.

resource "opnsense_auth_group" "lga1_admins" {
  provider    = opnsense.lga1
  name        = "admins"
  description = "System Administrators"
  privileges  = ["page-all"]
  members     = ["0", "2000"]
}

resource "opnsense_auth_group" "lga2_admins" {
  provider    = opnsense.lga2
  name        = "admins"
  description = "System Administrators"
  privileges  = ["page-all"]
  members     = ["0", "2000"]
}

resource "opnsense_acme_account" "lga1" {
  provider    = opnsense.lga1
  name        = "LE Aethertrail"
  description = ""
  email       = "letsencrypt@aethertrail.com"
  ca          = "letsencrypt"
  enabled     = true
}

resource "opnsense_acme_account" "lga2" {
  provider    = opnsense.lga2
  name        = "LE Aethertrail"
  description = ""
  email       = "letsencrypt@aethertrail.com"
  ca          = "letsencrypt"
  enabled     = true
}

import {
  provider = opnsense.lga1
  to       = opnsense_auth_group.lga1_admins
  id       = "6d49384f-8408-48ec-b419-bb7f6c29c793"
}

import {
  provider = opnsense.lga2
  to       = opnsense_auth_group.lga2_admins
  id       = "4dbef15e-f59d-4757-9a96-22e53b017f94"
}

import {
  provider = opnsense.lga1
  to       = opnsense_acme_account.lga1
  id       = "17b40743-f0ae-47c6-b2ab-93ebb7f7063a"
}

import {
  provider = opnsense.lga2
  to       = opnsense_acme_account.lga2
  id       = "6fdb3fc2-000f-475c-8672-e832893ea0a4"
}

