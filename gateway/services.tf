# Cron jobs, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

locals {
  lga1_cron_jobs = {
    "AcmeClient Cronjob for Certificate AutoRenewal" = {
      uuid        = "991e8fc5-7223-4dd9-8916-a30ec4e8b98d"
      command     = "acmeclient cron-auto-renew"
      minutes     = "0"
      hours       = "*/4"
      days        = "*"
      months      = "*"
      weekdays    = "*"
      who         = "root"
      description = "AcmeClient Cronjob for Certificate AutoRenewal"
      enabled     = true
    }
    "ids rule updates" = {
      uuid        = "4c37240e-f2db-41aa-944f-f0af296eff81"
      command     = "ids update"
      minutes     = "0"
      hours       = "0"
      days        = "*"
      months      = "*"
      weekdays    = "*"
      who         = "root"
      description = "ids rule updates"
      enabled     = false
    }
  }


  lga2_cron_jobs = {
    "AcmeClient Cronjob for Certificate AutoRenewal" = {
      uuid        = "73fa485e-ddd3-4938-b5fd-35d2f3aeff64"
      command     = "acmeclient cron-auto-renew"
      minutes     = "0"
      hours       = "*/4"
      days        = "*"
      months      = "*"
      weekdays    = "*"
      who         = "root"
      description = "AcmeClient Cronjob for Certificate AutoRenewal"
      enabled     = true
    }
    "Update Unbound DNSBLs" = {
      uuid        = "b5fd6e28-aa0c-440a-9e7f-693ad48c6b81"
      command     = "unbound dnsbl"
      minutes     = "0"
      hours       = "0"
      days        = "*"
      months      = "*"
      weekdays    = "*"
      who         = "root"
      description = "Update Unbound DNSBLs"
      enabled     = true
    }
    "Sunday reboot" = {
      uuid        = "b0f19cc9-b73b-4468-805f-e9d5a20dd486"
      command     = "system reboot"
      minutes     = "33"
      hours       = "4"
      days        = "*"
      months      = "*"
      weekdays    = "0"
      who         = "root"
      description = "Sunday reboot"
      enabled     = false
    }
  }


}

resource "opnsense_cron_job" "lga1_cron_jobs" {
  provider = opnsense.lga1
  for_each = local.lga1_cron_jobs

  command     = each.value.command
  minutes     = try(each.value.minutes, null)
  hours       = try(each.value.hours, null)
  days        = try(each.value.days, null)
  months      = try(each.value.months, null)
  weekdays    = try(each.value.weekdays, null)
  who         = try(each.value.who, null)
  parameters  = try(each.value.parameters, null)
  description = try(each.value.description, null)
  enabled     = each.value.enabled
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_cron_jobs
  to       = opnsense_cron_job.lga1_cron_jobs[each.key]
  id       = each.value.uuid
}

resource "opnsense_cron_job" "lga2_cron_jobs" {
  provider = opnsense.lga2
  for_each = local.lga2_cron_jobs

  command     = each.value.command
  minutes     = try(each.value.minutes, null)
  hours       = try(each.value.hours, null)
  days        = try(each.value.days, null)
  months      = try(each.value.months, null)
  weekdays    = try(each.value.weekdays, null)
  who         = try(each.value.who, null)
  parameters  = try(each.value.parameters, null)
  description = try(each.value.description, null)
  enabled     = each.value.enabled
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_cron_jobs
  to       = opnsense_cron_job.lga2_cron_jobs[each.key]
  id       = each.value.uuid
}

