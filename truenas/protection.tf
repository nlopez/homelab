resource "truenas_keychain_ssh_connection" "repl_nas1_at_nas2_nas1" {
  provider        = truenas.nas1
  connect_timeout = 20
  host            = "nas2.lga1.radoncanyon.com"
  name            = "repl-nas1@nas2.lga1"
  port            = 22
  private_key_id  = 6
  remote_host_key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPv0vgsp0hj2i3XqCb49c184T660pMeOXD1UHMxp32viungV+p3HfAOj42GFEGIwKYmU1xm3cLjJT/t5cxYguLA=\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDacWHSi5adPCF0yf83SYJSgpHgcQjkPXT9Cu09/d84Azt70+q7ObMZckUjoKn8aHRd2zqrCxGzgMjxgT1ihpJwGOOATQFIyrbP7OTqIfZ9rawjuna6Ja1t1aE19f76CI+lUJVsCE3tGaxyYN3hdxT7xxY+pbgppTslTMYU8zl/Q4RHDKuGn4IvPbFGWyoIdjbzXRXwbvD8mFjlyf5kqXtGRweWQ96E/dBJsoa41eZ2x4xTE/BaktJB8EQ1HJXayvF4ZSlr3QrSw/LnnMip8nclA4WzuqfempwpFaMpz4l8ThThwP8LteqiLEJPSu2tFxV0ZTuaKN/DB8caXryzC/Jh\nssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxbH/0S5CqCXAalqisCAW9Qt53PkBDmavGcG/ed630r"
  username        = "repl-nas1"
}

resource "truenas_keychain_ssh_keypair" "nas1_to_nas2_replication_nas1" {
  provider = truenas.nas1
  name     = "nas1-to-nas2-replication"

  # The key is imported from the NAS; keeping it out of config avoids
  # committing it.
  lifecycle {
    ignore_changes = [private_key]
  }
}

resource "truenas_periodic_snapshot_task" "etank_daily_nas1" {
  provider       = truenas.nas1
  allow_empty    = true
  dataset        = "etank"
  enabled        = true
  exclude        = ["etank/scratch", "etank/logs"]
  lifetime_unit  = "DAY"
  lifetime_value = 30
  naming_schema  = "auto-%Y%m%d.%H%M-30d-d"
  recursive      = true
  schedule = {
    begin  = "00:00"
    dom    = "*"
    dow    = "*"
    end    = "23:59"
    hour   = "3"
    minute = "15"
    month  = "*"
  }
}

resource "truenas_periodic_snapshot_task" "etank_iscsi_nas1" {
  provider       = truenas.nas1
  allow_empty    = true
  dataset        = "etank/iscsi"
  enabled        = false
  exclude        = []
  lifetime_unit  = "WEEK"
  lifetime_value = 2
  naming_schema  = "auto-%Y%m%d.%H%M-2w"
  recursive      = true
  schedule = {
    begin  = "00:00"
    dom    = "*"
    dow    = "1,2,3,4,5,6,7"
    end    = "23:45"
    hour   = "0"
    minute = "0"
    month  = "*"
  }
}

resource "truenas_periodic_snapshot_task" "etank_media_daily_nas2" {
  provider       = truenas.nas2
  allow_empty    = true
  dataset        = "etank/media"
  enabled        = true
  exclude        = []
  lifetime_unit  = "DAY"
  lifetime_value = 30
  naming_schema  = "auto-%Y%m%d.%H%M-30d"
  recursive      = true
  schedule = {
    begin  = "10:00"
    dom    = "*"
    dow    = "1,2,3,4,5,6,7"
    end    = "10:15"
    hour   = "10"
    minute = "0"
    month  = "*"
  }
}

resource "truenas_periodic_snapshot_task" "etank_weekly_nas1" {
  provider       = truenas.nas1
  allow_empty    = true
  dataset        = "etank"
  enabled        = true
  exclude        = ["etank/scratch", "etank/logs"]
  lifetime_unit  = "WEEK"
  lifetime_value = 8
  naming_schema  = "auto-%Y%m%d.%H%M-8w-w"
  recursive      = true
  schedule = {
    begin  = "00:00"
    dom    = "*"
    dow    = "7"
    end    = "23:59"
    hour   = "3"
    minute = "30"
    month  = "*"
  }
}

resource "truenas_periodic_snapshot_task" "mtank_daily_nas1" {
  provider       = truenas.nas1
  allow_empty    = true
  dataset        = "mtank"
  enabled        = true
  exclude        = ["mtank/immich-ml-cache", "mtank/ix-apps"]
  lifetime_unit  = "DAY"
  lifetime_value = 30
  naming_schema  = "auto-%Y%m%d.%H%M-30d-d"
  recursive      = true
  schedule = {
    begin  = "00:00"
    dom    = "*"
    dow    = "*"
    end    = "23:59"
    hour   = "3"
    minute = "15"
    month  = "*"
  }
}

resource "truenas_periodic_snapshot_task" "mtank_hourly_nas1" {
  provider       = truenas.nas1
  allow_empty    = true
  dataset        = "mtank"
  enabled        = true
  exclude        = ["mtank/immich-ml-cache", "mtank/ix-apps"]
  lifetime_unit  = "DAY"
  lifetime_value = 2
  naming_schema  = "auto-%Y%m%d.%H%M-2d-h"
  recursive      = true
  schedule = {
    begin  = "00:00"
    dom    = "*"
    dow    = "*"
    end    = "23:59"
    hour   = "*"
    minute = "0"
    month  = "*"
  }
}

resource "truenas_periodic_snapshot_task" "mtank_weekly_nas1" {
  provider       = truenas.nas1
  allow_empty    = true
  dataset        = "mtank"
  enabled        = true
  exclude        = ["mtank/immich-ml-cache", "mtank/ix-apps"]
  lifetime_unit  = "WEEK"
  lifetime_value = 8
  naming_schema  = "auto-%Y%m%d.%H%M-8w-w"
  recursive      = true
  schedule = {
    begin  = "00:00"
    dom    = "*"
    dow    = "7"
    end    = "23:59"
    hour   = "3"
    minute = "30"
    month  = "*"
  }
}

resource "truenas_replication_task" "etank_to_nas2_nas1" {
  provider                   = truenas.nas1
  allow_from_scratch         = true
  also_include_naming_schema = ["auto-%Y%m%d.%H%M-30d-d", "auto-%Y%m%d.%H%M-8w-w"]
  auto                       = true
  compressed                 = true
  direction                  = "PUSH"
  embed                      = true
  enabled                    = true
  encryption                 = false
  exclude                    = ["etank/scratch", "etank/logs", "etank/.system"]
  hold_pending_snapshots     = false
  large_block                = true
  lifetime_unit              = "DAY"
  lifetime_value             = 90
  name                       = "etank to nas2"
  name_regex                 = ""
  naming_schema              = []
  only_matching_schedule     = false
  periodic_snapshot_tasks    = []
  properties                 = false
  properties_exclude         = []
  readonly                   = "IGNORE"
  recursive                  = true
  replicate                  = false
  retention_policy           = "CUSTOM"
  retries                    = 5
  schedule = {
    begin  = "00:00"
    dom    = "*"
    dow    = "*"
    end    = "23:59"
    hour   = "6"
    minute = "0"
    month  = "*"
  }
  source_datasets = ["etank"]
  ssh_credentials = 7
  sudo            = false
  target_dataset  = "etank/backups/nas1/etank"
  transport       = "SSH"
}

resource "truenas_replication_task" "mtank_to_nas2_nas1" {
  provider                   = truenas.nas1
  allow_from_scratch         = true
  also_include_naming_schema = ["auto-%Y%m%d.%H%M-30d-d", "auto-%Y%m%d.%H%M-8w-w"]
  auto                       = true
  compressed                 = true
  direction                  = "PUSH"
  embed                      = true
  enabled                    = true
  encryption                 = false
  exclude                    = ["mtank/immich-ml-cache", "mtank/ix-apps"]
  hold_pending_snapshots     = false
  large_block                = true
  lifetime_unit              = "DAY"
  lifetime_value             = 90
  name                       = "mtank to nas2"
  name_regex                 = ""
  naming_schema              = []
  only_matching_schedule     = false
  periodic_snapshot_tasks    = []
  properties                 = false
  properties_exclude         = []
  readonly                   = "IGNORE"
  recursive                  = true
  replicate                  = false
  retention_policy           = "CUSTOM"
  retries                    = 5
  schedule = {
    begin  = "00:00"
    dom    = "*"
    dow    = "*"
    end    = "23:59"
    hour   = "5"
    minute = "0"
    month  = "*"
  }
  source_datasets = ["mtank"]
  ssh_credentials = 7
  sudo            = false
  target_dataset  = "etank/backups/nas1/mtank"
  transport       = "SSH"
}

resource "truenas_scrub_task" "scrub_1_nas1" {
  provider    = truenas.nas1
  description = ""
  enabled     = true
  pool        = 4
  schedule = {
    dom    = "*"
    dow    = "7"
    hour   = "00"
    minute = "00"
    month  = "*"
  }
  threshold = 35
}

resource "truenas_scrub_task" "scrub_1_nas2" {
  provider    = truenas.nas2
  description = ""
  enabled     = true
  pool        = 1
  schedule = {
    dom    = "05,25"
    dow    = "*"
    hour   = "07"
    minute = "33"
    month  = "*"
  }
  threshold = 10
}

resource "truenas_scrub_task" "scrub_3_nas1" {
  provider    = truenas.nas1
  description = ""
  enabled     = true
  pool        = 6
  schedule = {
    dom    = "*"
    dow    = "7"
    hour   = "00"
    minute = "00"
    month  = "*"
  }
  threshold = 35
}
