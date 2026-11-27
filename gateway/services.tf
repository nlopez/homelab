# Cron jobs and traffic shaper pipes, imported from the live gateways.
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

  lga1_trafficshaper_pipes = {
    "10000-Download Pipe" = {
      uuid             = "2f69c891-fdf6-4e7b-be98-b23ab2123157"
      bandwidth        = "950"
      bandwidth_metric = "Mbit"
      number           = "10000"
      mask             = "none"
      scheduler        = "fq_codel"
      description      = "Download Pipe"
      enabled          = true
    }
    "10001-Upload Pipe" = {
      uuid             = "100e3cfc-c890-4a23-a36a-4526b76e834b"
      bandwidth        = "900"
      bandwidth_metric = "Mbit"
      number           = "10001"
      mask             = "none"
      scheduler        = "fq_codel"
      description      = "Upload Pipe"
      enabled          = true
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

  lga2_trafficshaper_pipes = {
    "10000-Upload Pipe" = {
      uuid             = "70dd3a11-4f72-411a-bf32-e3ee138d3fe3"
      bandwidth        = "900"
      bandwidth_metric = "Mbit"
      number           = "10000"
      mask             = "none"
      scheduler        = "fq_codel"
      description      = "Upload Pipe"
      enabled          = true
    }
    "10001-Download Pipe" = {
      uuid             = "045a61d2-4630-40c5-8260-8e260500b39c"
      bandwidth        = "950"
      bandwidth_metric = "Mbit"
      number           = "10001"
      mask             = "none"
      scheduler        = "fq_codel"
      description      = "Download Pipe"
      enabled          = true
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

resource "opnsense_trafficshaper_pipe" "lga1_trafficshaper_pipes" {
  provider = opnsense.lga1
  for_each = local.lga1_trafficshaper_pipes

  bandwidth        = each.value.bandwidth
  bandwidth_metric = each.value.bandwidth_metric
  number           = try(each.value.number, null)
  mask             = try(each.value.mask, null)
  scheduler        = try(each.value.scheduler, null)
  description      = try(each.value.description, null)
  enabled          = each.value.enabled
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_trafficshaper_pipes
  to       = opnsense_trafficshaper_pipe.lga1_trafficshaper_pipes[each.key]
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

resource "opnsense_trafficshaper_pipe" "lga2_trafficshaper_pipes" {
  provider = opnsense.lga2
  for_each = local.lga2_trafficshaper_pipes

  bandwidth        = each.value.bandwidth
  bandwidth_metric = each.value.bandwidth_metric
  number           = try(each.value.number, null)
  mask             = try(each.value.mask, null)
  scheduler        = try(each.value.scheduler, null)
  description      = try(each.value.description, null)
  enabled          = each.value.enabled
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_trafficshaper_pipes
  to       = opnsense_trafficshaper_pipe.lga2_trafficshaper_pipes[each.key]
  id       = each.value.uuid
}

