# Recyclarr owns quality profiles, custom formats, and quality definitions
# (kubernetes/apps/recyclarr), so they stay out of this stack.

resource "sonarr_tag" "anime" {
  label = "anime"
}

resource "sonarr_root_folder" "anime" {
  path = "/media/anime"
}

resource "sonarr_root_folder" "tv" {
  path = "/media/tv"
}

resource "sonarr_delay_profile" "default" {
  bypass_if_above_custom_format_score = false
  bypass_if_highest_quality           = true
  enable_torrent                      = true
  enable_usenet                       = true
  minimum_custom_format_score         = 0
  order                               = 2147483647
  preferred_protocol                  = "usenet"
  tags                                = []
  torrent_delay                       = 0
  usenet_delay                        = 0
}

resource "sonarr_naming" "naming" {
  anime_episode_format       = "{Series TitleYear} - S{season:00}E{episode:00} - {absolute:000} - {Episode CleanTitle:90} {[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{MediaInfo AudioLanguages}{[MediaInfo VideoDynamicRangeType]}[{Mediainfo VideoCodec }{MediaInfo VideoBitDepth}bit]{-Release Group}"
  colon_replacement_format   = 4
  daily_episode_format       = "{Series TitleYear} - {Air-Date} - {Episode CleanTitle:90} {[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo VideoCodec]}{-Release Group}"
  multi_episode_style        = 5
  rename_episodes            = true
  replace_illegal_characters = true
  season_folder_format       = "Season {season:00}"
  series_folder_format       = "{Series TitleYear}"
  specials_folder_format     = "Specials"
  standard_episode_format    = "{Series TitleYear} - S{season:00}E{episode:00} - {Episode CleanTitle:90} {[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo VideoCodec]}{-Release Group}"
}

resource "sonarr_media_management" "media_management" {
  chmod_folder                = "755"
  chown_group                 = ""
  create_empty_folders        = false
  delete_empty_folders        = true
  download_propers_repacks    = "doNotPrefer"
  enable_media_info           = true
  episode_title_required      = "always"
  extra_file_extensions       = "srt,ass,nfo"
  file_date                   = "none"
  hardlinks_copy              = true
  import_extra_files          = true
  minimum_free_space          = 100
  recycle_bin_days            = 7
  recycle_bin_path            = ""
  rescan_after_refresh        = "always"
  set_permissions             = false
  skip_free_space_check       = false
  unmonitor_previous_episodes = true
}

# Download clients

resource "sonarr_download_client_qbittorrent" "nas2" {
  enable                     = true
  first_and_last             = false
  host                       = "nas2.lga1.radoncanyon.com"
  initial_state              = 0
  name                       = "qBittorrent - nas2"
  older_tv_priority          = 0
  password                   = var.qbittorrent_password
  port                       = 30024
  priority                   = 1
  recent_tv_priority         = 0
  remove_completed_downloads = true
  remove_failed_downloads    = true
  sequential_order           = false
  tags                       = []
  tv_category                = "sonarr-anime"
  use_ssl                    = false
  username                   = "admin"
}

resource "sonarr_download_client_sabnzbd" "sabnzbd" {
  api_key                    = var.sabnzbd_api_key
  enable                     = true
  host                       = "nas2.lga1.radoncanyon.com"
  name                       = "SABnzbd"
  older_tv_priority          = -100
  port                       = 30055
  priority                   = 1
  recent_tv_priority         = -100
  remove_completed_downloads = true
  remove_failed_downloads    = true
  tags                       = []
  tv_category                = "majestic-fear"
  use_ssl                    = false
}

# Indexers. The anime indexers only serve series tagged anime.

resource "sonarr_indexer_newznab" "nzbgeek" {
  anime_categories             = [5070]
  anime_standard_format_search = true
  api_key                      = var.nzbgeek_api_key
  api_path                     = "/api"
  base_url                     = "https://api.nzbgeek.info"
  categories                   = [5030, 5040]
  download_client_id           = 0
  enable_automatic_search      = true
  enable_interactive_search    = true
  enable_rss                   = true
  name                         = "NZBgeek"
  priority                     = 25
  tags                         = []
}

resource "sonarr_indexer_newznab" "animetosho" {
  anime_categories             = [5070]
  anime_standard_format_search = false
  # AnimeTosho has no accounts; its feed takes 0 as the API key.
  api_key                   = "0"
  api_path                  = "/nabapi"
  base_url                  = "https://feed.animetosho.xyz/api"
  categories                = []
  download_client_id        = 0
  enable_automatic_search   = true
  enable_interactive_search = true
  enable_rss                = true
  name                      = "AnimeTosho Usenet"
  priority                  = 25
  tags                      = [sonarr_tag.anime.id]
}

resource "sonarr_indexer_torznab" "animetosho" {
  anime_categories             = [5070]
  anime_standard_format_search = false
  api_path                     = "/nabapi"
  base_url                     = "https://feed.animetosho.org"
  categories                   = []
  download_client_id           = 0
  enable_automatic_search      = false
  enable_interactive_search    = false
  enable_rss                   = false
  minimum_seeders              = 1
  name                         = "AnimeTosho Torrents"
  priority                     = 25
  tags                         = [sonarr_tag.anime.id]
}

resource "sonarr_indexer_nyaa" "nyaa" {
  additional_parameters        = "&cats=1_0&filter=1"
  anime_standard_format_search = false
  base_url                     = "https://nyaa.si"
  download_client_id           = 0
  enable_automatic_search      = false
  enable_interactive_search    = false
  enable_rss                   = false
  minimum_seeders              = 1
  name                         = "Nyaa"
  priority                     = 25
  seed_ratio                   = 2
  tags                         = [sonarr_tag.anime.id]
}

resource "sonarr_notification_plex" "plex" {
  auth_token                         = var.plex_token
  host                               = "pms.pms.svc.cluster.local"
  include_health_warnings            = false
  name                               = "Plex Media Server"
  on_download                        = true
  on_episode_file_delete             = true
  on_episode_file_delete_for_upgrade = true
  on_import_complete                 = true
  on_rename                          = true
  on_series_add                      = true
  on_series_delete                   = true
  on_upgrade                         = true
  port                               = 32400
  tags                               = []
  update_library                     = true
  use_ssl                            = false
}
