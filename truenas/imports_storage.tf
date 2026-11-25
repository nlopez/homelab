import {
  provider = truenas.nas1
  to       = truenas_dataset.etank_logs_nas1
  id       = "etank/logs"
}

import {
  provider = truenas.nas1
  to       = truenas_dataset.etank_scratch_nas1
  id       = "etank/scratch"
}

import {
  provider = truenas.nas1
  to       = truenas_dataset.etank_scratch_downloads_nas1
  id       = "etank/scratch/downloads"
}

import {
  provider = truenas.nas1
  to       = truenas_dataset.etank_scratch_downloads_qbittorrent_nas1
  id       = "etank/scratch/downloads/qbittorrent"
}

import {
  provider = truenas.nas1
  to       = truenas_dataset.etank_k8s_nas1
  id       = "etank/k8s"
}

import {
  provider = truenas.nas1
  to       = truenas_dataset.etank_iscsi_nas1
  id       = "etank/iscsi"
}

import {
  provider = truenas.nas1
  to       = truenas_dataset.etank_iscsi_nextcloud_nas1
  id       = "etank/iscsi/nextcloud"
}

import {
  provider = truenas.nas1
  to       = truenas_dataset.mtank_k8s_nas1
  id       = "mtank/k8s"
}

import {
  provider = truenas.nas1
  to       = truenas_zvol.etank_iscsi_icloudpd_nas1
  id       = "etank/iscsi/icloudpd"
}

import {
  provider = truenas.nas1
  to       = truenas_zvol.etank_iscsi_shaarli_nas1
  id       = "etank/iscsi/shaarli"
}

import {
  provider = truenas.nas1
  to       = truenas_zvol.mtank_immich_ml_cache_nas1
  id       = "mtank/immich-ml-cache"
}

import {
  provider = truenas.nas1
  to       = truenas_zvol.mtank_jackett_nas1
  id       = "mtank/jackett"
}

import {
  provider = truenas.nas1
  to       = truenas_zvol.mtank_immich_redis_nas1
  id       = "mtank/immich-redis"
}

import {
  provider = truenas.nas1
  to       = truenas_zvol.mtank_jellyfin_nas1
  id       = "mtank/jellyfin"
}

import {
  provider = truenas.nas2
  to       = truenas_dataset.etank_floppypaws_nas2
  id       = "etank/floppypaws"
}

import {
  provider = truenas.nas2
  to       = truenas_dataset.etank_k8s_nas2
  id       = "etank/k8s"
}

import {
  provider = truenas.nas2
  to       = truenas_dataset.etank_nextcloud_nas2
  id       = "etank/nextcloud"
}

import {
  provider = truenas.nas2
  to       = truenas_dataset.etank_home_nas2
  id       = "etank/home"
}

import {
  provider = truenas.nas2
  to       = truenas_dataset.etank_media_nas2
  id       = "etank/media"
}

import {
  provider = truenas.nas1
  to       = truenas_smb_share.etank_scratch_nas1
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_smb_share.floppypaws_nas2
  id       = "6"
}

import {
  provider = truenas.nas2
  to       = truenas_smb_share.media_nas2
  id       = "7"
}

import {
  provider = truenas.nas1
  to       = truenas_nfs_share.etank_scratch_downloads_nas1
  id       = "6"
}

import {
  provider = truenas.nas1
  to       = truenas_nfs_share.etank_scratch_downloads_qbittorrent_nas1
  id       = "7"
}

import {
  provider = truenas.nas1
  to       = truenas_nfs_share.etank_scratch_nas1
  id       = "21"
}

import {
  provider = truenas.nas1
  to       = truenas_nfs_share.etank_logs_nas1
  id       = "22"
}

import {
  provider = truenas.nas2
  to       = truenas_nfs_share.etank_nextcloud_nas2
  id       = "7"
}

import {
  provider = truenas.nas2
  to       = truenas_nfs_share.etank_media_nas2
  id       = "8"
}
