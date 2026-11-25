import {
  provider = truenas.nas1
  to       = truenas_iscsi_target.nas1["shaarli"]
  id       = "21"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_extent.nas1["shaarli"]
  id       = "21"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_targetextent.nas1["shaarli"]
  id       = "21"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_target.nas1["jellyfin"]
  id       = "63"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_extent.nas1["jellyfin"]
  id       = "63"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_targetextent.nas1["jellyfin"]
  id       = "73"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_target.nas1["jackett"]
  id       = "65"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_extent.nas1["jackett"]
  id       = "65"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_targetextent.nas1["jackett"]
  id       = "76"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_target.nas1["immich-ml-cache"]
  id       = "69"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_extent.nas1["immich-ml-cache"]
  id       = "69"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_targetextent.nas1["immich-ml-cache"]
  id       = "84"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_target.nas1["immich-redis"]
  id       = "70"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_extent.nas1["immich-redis"]
  id       = "70"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_targetextent.nas1["immich-redis"]
  id       = "85"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_target.nas1["icloudpd"]
  id       = "72"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_extent.nas1["icloudpd"]
  id       = "72"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_targetextent.nas1["icloudpd"]
  id       = "87"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_portal.nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_initiator.nas1["knodes"]
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_initiator.nas1["immich-ml-cache"]
  id       = "8"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_initiator.nas1["immich-redis"]
  id       = "9"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_initiator.nas1["icloudpd"]
  id       = "11"
}

import {
  provider = truenas.nas1
  to       = truenas_iscsi_global.nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_catalog_config.nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_system_dataset.nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_resilver_config.nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_replication_config.nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_twofactor_auth.nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_ipmi_lan.nas1
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_iscsi_global.nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_catalog_config.nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_system_dataset.nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_resilver_config.nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_replication_config.nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_twofactor_auth.nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_ipmi_lan.nas2
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_ntp_server.nas1["time.google.com"]
  id       = "4"
}

import {
  provider = truenas.nas2
  to       = truenas_ntp_server.nas2["time.google.com"]
  id       = "1"
}
