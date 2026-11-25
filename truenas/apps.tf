resource "truenas_app" "netdata_nas1" {
  provider    = truenas.nas1
  catalog_app = "netdata"
  custom_app  = false
  name        = "netdata"
  running     = true
  train       = "stable"
  version     = "1.4.28"
}

resource "truenas_app" "tailscale_nas1" {
  provider    = truenas.nas1
  catalog_app = "tailscale"
  custom_app  = false
  name        = "tailscale"
  running     = false
  train       = "community"
  version     = "1.4.28"
}

resource "truenas_app" "backrest_nas2" {
  provider    = truenas.nas2
  catalog_app = "backrest"
  custom_app  = false
  name        = "backrest"
  running     = true
  train       = "community"
  version     = "1.1.20"
}

resource "truenas_app" "media_toolbox_nas2" {
  provider    = truenas.nas2
  catalog_app = "ix-app"
  custom_app  = false
  name        = "media-toolbox"
  running     = true
  train       = "stable"
  version     = "1.4.9"
}

resource "truenas_app" "netdata_nas2" {
  provider    = truenas.nas2
  catalog_app = "netdata"
  custom_app  = false
  name        = "netdata"
  running     = true
  train       = "stable"
  version     = "1.4.28"
}

resource "truenas_app" "qbittorrent_nas2" {
  provider    = truenas.nas2
  catalog_app = "qbittorrent"
  custom_app  = false
  name        = "qbittorrent"
  running     = true
  train       = "community"
  version     = "1.4.22"
}

resource "truenas_app" "sabnzbd_nas2" {
  provider    = truenas.nas2
  catalog_app = "sabnzbd"
  custom_app  = false
  name        = "sabnzbd"
  running     = true
  train       = "community"
  version     = "1.3.24"
}

resource "truenas_app" "tailscale_nas2" {
  provider    = truenas.nas2
  catalog_app = "tailscale"
  custom_app  = false
  name        = "tailscale"
  running     = false
  train       = "community"
  version     = "1.4.28"
}
