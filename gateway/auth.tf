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

# On lga2, os-sso adds and removes SSO accounts in admins and viewers from
# authentik's gateway-admins and gateway-viewers groups (authentik/opnsense.tf)
# at each login, so membership is not managed here. root (0) and nlopez-local
# (2000) are local break-glass members; os-sso's group sync never removes
# members it did not add.
resource "opnsense_auth_group" "lga2_admins" {
  provider    = opnsense.lga2
  name        = "admins"
  description = "System Administrators"
  privileges  = ["page-all"]
  members     = ["0", "2000"]

  lifecycle {
    ignore_changes = [members]
  }
}

# Read-only SSO access: os-sso maps authentik's gateway-viewers group here.
# OPNsense has no read-only role, and "Deny config write" alone still allows
# reboots, service restarts, and state flushes, so the group gets only status
# and log pages. Some of them keep small actions, such as clearing a log or
# flushing the ARP table.
resource "opnsense_auth_group" "lga2_viewers" {
  provider    = opnsense.lga2
  name        = "viewers"
  description = "Read-only access through SSO"
  privileges = [
    "user-config-readonly",
    "page-system-login-logout",
    "page-system-status",
    "page-status-interfaces",
    "page-status-dnsoverview",
    "page-status-ntp",
    "page-status-trafficgraph",
    "page-status-carp",
    "page-diagnostics-arptable",
    "page-diagnostics-ndptable",
    "page-diagnostics-routingtables",
    "page-diagnostics-health",
    "page-diagnostics-pf-info",
    "page-diagnostics-system-activity",
    "page-diagnostics-system-pftop",
    "page-diagnostics-netstat",
    "page-diagnostics-logs-system",
    "page-diagnostics-logs-gateways",
    "page-diagnostics-logs-firewall-dynamic",
    "page-diagnostics-logs-firewall-plain",
    "page-diagnostics-logs-firewall-summary",
    "page-diagnostics-logs-resolver",
    "page-diagnostics-logs-kea",
    "page-status-systemlogs-routing",
    "page-wireguard-diagnostics",
  ]

  lifecycle {
    ignore_changes = [members]
  }
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

