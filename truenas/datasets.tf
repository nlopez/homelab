resource "truenas_zvol" "etank_iscsi_icloudpd_nas1" {
  provider       = truenas.nas1
  name           = "etank/iscsi/icloudpd"
  readonly       = "OFF"
  refreservation = 10907287552
  volblocksize   = 16384
  volsize        = 10737418240

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_zvol" "mtank_jellyfin_nas1" {
  provider       = truenas.nas1
  dedup          = "OFF"
  name           = "mtank/jellyfin"
  readonly       = "OFF"
  refreservation = 218109313024
  sync           = "DISABLED"
  volblocksize   = 16384
  volsize        = 214748364800

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_zvol" "mtank_immich_redis_nas1" {
  provider       = truenas.nas1
  name           = "mtank/immich-redis"
  readonly       = "OFF"
  refreservation = 5454692352
  volblocksize   = 16384
  volsize        = 5368709120

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_logs_nas1" {
  provider = truenas.nas1
  aclmode  = "PASSTHROUGH"
  copies   = 1
  name     = "etank/logs"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_zvol" "etank_iscsi_shaarli_nas1" {
  provider       = truenas.nas1
  name           = "etank/iscsi/shaarli"
  refreservation = 1092616192
  volblocksize   = 16384
  volsize        = 1073741824

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "mtank_k8s_nas1" {
  provider = truenas.nas1
  name     = "mtank/k8s"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_zvol" "mtank_immich_ml_cache_nas1" {
  provider       = truenas.nas1
  name           = "mtank/immich-ml-cache"
  readonly       = "OFF"
  refreservation = 54529097728
  volblocksize   = 16384
  volsize        = 53687091200

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_k8s_nas1" {
  provider = truenas.nas1
  copies   = 1
  name     = "etank/k8s"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_scratch_nas1" {
  provider   = truenas.nas1
  aclmode    = "PASSTHROUGH"
  name       = "etank/scratch"
  recordsize = "1M"
  type       = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_scratch_downloads_nas1" {
  provider = truenas.nas1
  aclmode  = "PASSTHROUGH"
  name     = "etank/scratch/downloads"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_scratch_downloads_qbittorrent_nas1" {
  provider = truenas.nas1
  aclmode  = "PASSTHROUGH"
  copies   = 1
  name     = "etank/scratch/downloads/qbittorrent"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_zvol" "mtank_jackett_nas1" {
  provider       = truenas.nas1
  name           = "mtank/jackett"
  readonly       = "OFF"
  refreservation = 1092894720
  volblocksize   = 16384
  volsize        = 1073758208

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_iscsi_nas1" {
  provider = truenas.nas1
  name     = "etank/iscsi"
  sync     = "DISABLED"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_home_nas2" {
  provider = truenas.nas2
  aclmode  = "PASSTHROUGH"
  copies   = 1
  name     = "etank/home"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_floppypaws_nas2" {
  provider = truenas.nas2
  aclmode  = "RESTRICTED"
  copies   = 1
  name     = "etank/floppypaws"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_media_nas2" {
  provider   = truenas.nas2
  aclmode    = "DISCARD"
  acltype    = "posix"
  copies     = 1
  name       = "etank/media"
  recordsize = "1M"
  snapdir    = "HIDDEN"
  type       = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_nextcloud_nas2" {
  provider = truenas.nas2
  aclmode  = "PASSTHROUGH"
  name     = "etank/nextcloud"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_dataset" "etank_k8s_nas2" {
  provider = truenas.nas2
  name     = "etank/k8s"
  type     = "filesystem"

  lifecycle {
    prevent_destroy = true
  }
}
