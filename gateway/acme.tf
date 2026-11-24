# ACME certificate definitions and their DNS-01 validations. These are the
# config that makes the certificates: the issued certificates themselves are
# the ACME client's output and are left in the trust store.

locals {
  lga1_acme_challenges = {
    "Cloudflare" = {
      uuid        = "9f6711ca-64d4-4866-8fe9-ecde1069cf18"
      description = "Cloudflare"
      method      = "dns01"
      dns_service = "dns_cf"
      dns_sleep   = 120
    }
  }
  lga2_acme_challenges = {
    "Cloudflare" = {
      uuid        = "7675a335-2d56-47d0-8d70-6c7766e209e0"
      description = "radoncanyon.com"
      method      = "dns01"
      dns_service = "dns_cf"
      dns_sleep   = 120
    }
  }

  lga1_acme_certificates = {
    "gw.lga1.radoncanyon.com" = {
      uuid              = "d9dbafd4-3b20-4289-ac6b-b52f9585e22f"
      description       = "gw.lga1"
      alt_names         = jsonencode({ "gw.lga1.radoncanyon.com" = { selected = 1, value = "gw.lga1.radoncanyon.com" } })
      account           = "17b40743-f0ae-47c6-b2ab-93ebb7f7063a"
      validation_method = "9f6711ca-64d4-4866-8fe9-ecde1069cf18"
      key_length        = "key_ec256"
    }
  }
  lga2_acme_certificates = {
    "gw.lga2.radoncanyon.com" = {
      uuid              = "35009dab-e455-4f0e-a67d-590611b976ce"
      description       = "gw"
      alt_names         = jsonencode({ "gw.lga2.radoncanyon.com" = { selected = 1, value = "gw.lga2.radoncanyon.com" } })
      account           = "6fdb3fc2-000f-475c-8672-e832893ea0a4"
      validation_method = "7675a335-2d56-47d0-8d70-6c7766e209e0"
      key_length        = "key_ec256"
    }
  }
}

resource "opnsense_acme_challenge" "lga1" {
  provider = opnsense.lga1
  for_each = local.lga1_acme_challenges

  name        = each.key
  description = each.value.description
  method      = each.value.method
  dns_service = each.value.dns_service
  dns_sleep   = each.value.dns_sleep
  enabled     = true
}

resource "opnsense_acme_challenge" "lga2" {
  provider = opnsense.lga2
  for_each = local.lga2_acme_challenges

  name        = each.key
  description = each.value.description
  method      = each.value.method
  dns_service = each.value.dns_service
  dns_sleep   = each.value.dns_sleep
  enabled     = true
}

resource "opnsense_acme_certificate" "lga1" {
  provider = opnsense.lga1
  for_each = local.lga1_acme_certificates

  name              = each.key
  description       = each.value.description
  alt_names         = each.value.alt_names
  account           = each.value.account
  validation_method = opnsense_acme_challenge.lga1["Cloudflare"].id
  key_length        = each.value.key_length
  auto_renewal      = true
  enabled           = true
}

resource "opnsense_acme_certificate" "lga2" {
  provider = opnsense.lga2
  for_each = local.lga2_acme_certificates

  name              = each.key
  description       = each.value.description
  alt_names         = each.value.alt_names
  account           = each.value.account
  validation_method = opnsense_acme_challenge.lga2["Cloudflare"].id
  key_length        = each.value.key_length
  auto_renewal      = true
  enabled           = true
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_acme_challenges
  to       = opnsense_acme_challenge.lga1[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_acme_challenges
  to       = opnsense_acme_challenge.lga2[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_acme_certificates
  to       = opnsense_acme_certificate.lga1[each.key]
  id       = each.value.uuid
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_acme_certificates
  to       = opnsense_acme_certificate.lga2[each.key]
  id       = each.value.uuid
}
