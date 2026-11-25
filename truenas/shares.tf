resource "truenas_nfs_share" "etank_scratch_downloads_qbittorrent_nas1" {
  provider     = truenas.nas1
  comment      = "qbittorrent"
  enabled      = true
  mapall_group = "dockerfs"
  mapall_user  = "dockerfs"
  path         = "/mnt/etank/scratch/downloads/qbittorrent"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_nfs_share" "etank_scratch_downloads_nas1" {
  provider     = truenas.nas1
  comment      = "downloads"
  enabled      = true
  mapall_group = "dockerfs"
  mapall_user  = "dockerfs"
  path         = "/mnt/etank/scratch/downloads"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_nfs_share" "etank_logs_nas1" {
  provider     = truenas.nas1
  comment      = "logs"
  enabled      = true
  mapall_group = "dockerfs"
  mapall_user  = "dockerfs"
  path         = "/mnt/etank/logs"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_nfs_share" "etank_scratch_nas1" {
  provider     = truenas.nas1
  comment      = "scratch"
  enabled      = true
  mapall_group = "dockerfs"
  mapall_user  = "dockerfs"
  path         = "/mnt/etank/scratch"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_smb_share" "etank_scratch_nas1" {
  provider  = truenas.nas1
  browsable = true
  enabled   = true
  name      = "scratch"
  options = {
  }
  path    = "/mnt/etank/scratch"
  purpose = "DEFAULT_SHARE"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_nfs_share" "etank_media_nas2" {
  provider     = truenas.nas2
  comment      = "media"
  enabled      = true
  mapall_group = "dockerfs"
  mapall_user  = "dockerfs"
  path         = "/mnt/etank/media"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_nfs_share" "etank_nextcloud_nas2" {
  provider     = truenas.nas2
  comment      = "nextcloud"
  enabled      = false
  mapall_group = "dockerfs"
  mapall_user  = "dockerfs"
  path         = "/mnt/etank/nextcloud"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_smb_share" "media_nas2" {
  provider  = truenas.nas2
  browsable = true
  enabled   = true
  name      = "media"
  options = {
  }
  path    = "/mnt/etank/media"
  purpose = "DEFAULT_SHARE"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_smb_share" "floppypaws_nas2" {
  provider  = truenas.nas2
  acl       = true
  browsable = true
  enabled   = false
  name      = "floppypaws"
  path      = "/mnt/etank/floppypaws"
  purpose   = "LEGACY_SHARE"
  streams   = true

  lifecycle {
    prevent_destroy = true
  }
}
