# Recyclarr owns quality profiles, custom formats, quality definitions, and
# movie naming (kubernetes/apps/recyclarr), so they stay out of this stack.

resource "radarr_root_folder" "movies" {
  path = "/media/movies"
}

resource "radarr_delay_profile" "default" {
  bypass_if_highest_quality = true
  enable_torrent            = true
  enable_usenet             = true
  order                     = 2147483647
  preferred_protocol        = "usenet"
  tags                      = []
  torrent_delay             = 0
  usenet_delay              = 0
}

resource "radarr_media_management" "media_management" {
  auto_rename_folders                         = false
  auto_unmonitor_previously_downloaded_movies = false
  chmod_folder                                = "755"
  chown_group                                 = ""
  copy_using_hardlinks                        = true
  create_empty_movie_folders                  = false
  delete_empty_folders                        = false
  download_propers_and_repacks                = "doNotPrefer"
  enable_media_info                           = true
  extra_file_extensions                       = "srt"
  file_date                                   = "none"
  import_extra_files                          = false
  minimum_free_space_when_importing           = 100
  paths_default_static                        = false
  recycle_bin                                 = ""
  recycle_bin_cleanup_days                    = 7
  rescan_after_refresh                        = "always"
  set_permissions_linux                       = false
  skip_free_space_check_when_importing        = false
}

resource "radarr_download_client_qbittorrent" "nas2" {
  enable                     = true
  first_and_last             = false
  host                       = "nas2.lga1.radoncanyon.com"
  initial_state              = 0
  movie_category             = "radarr"
  name                       = "qBittorrent - nas2"
  older_movie_priority       = 0
  password                   = var.qbittorrent_password
  port                       = 30024
  priority                   = 1
  recent_movie_priority      = 0
  remove_completed_downloads = true
  remove_failed_downloads    = true
  sequential_order           = false
  tags                       = []
  use_ssl                    = false
  username                   = "admin"
}

resource "radarr_download_client_sabnzbd" "sabnzbd" {
  api_key                    = var.sabnzbd_api_key
  enable                     = true
  host                       = "nas2.lga1.radoncanyon.com"
  movie_category             = "contagious-blues"
  name                       = "SABnzbd"
  older_movie_priority       = -100
  port                       = 30055
  priority                   = 1
  recent_movie_priority      = -100
  remove_completed_downloads = true
  remove_failed_downloads    = true
  tags                       = []
  use_ssl                    = false
}

resource "radarr_indexer_newznab" "nzbgeek" {
  api_key                   = var.nzbgeek_api_key
  api_path                  = "/api"
  base_url                  = "https://api.nzbgeek.info"
  categories                = [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060]
  download_client_id        = 0
  enable_automatic_search   = true
  enable_interactive_search = true
  enable_rss                = true
  multi_languages           = []
  name                      = "NZBgeek"
  priority                  = 25
  remove_year               = false
  tags                      = []
}

resource "radarr_notification_plex" "plex" {
  auth_token                       = var.plex_token
  host                             = "pms.pms.svc.cluster.local"
  include_health_warnings          = false
  name                             = "Plex Media Server"
  on_download                      = true
  on_movie_added                   = false
  on_movie_delete                  = true
  on_movie_file_delete             = true
  on_movie_file_delete_for_upgrade = true
  on_rename                        = true
  on_upgrade                       = true
  port                             = 32400
  tags                             = []
  update_library                   = true
  use_ssl                          = false
}
