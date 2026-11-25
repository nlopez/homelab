# iSCSI on nas1 for the static PersistentVolumes in kubernetes/apps*/. The
# truenas-csi driver creates and owns every csi-* target, extent and initiator
# group itself; it shares only the portal and the global settings with these.
locals {
  k8s_initiators = [
    "iqn.2014-09.com.radoncanyon:knode1",
    "iqn.2014-09.com.radoncanyon:knode2",
  ]

  # Target and extent names match the iqn suffix in each PV.
  static_luns = {
    shaarli         = { zvol = "etank/iscsi/shaarli", blocksize = 4096, pblocksize = false, lunid = 1, initiator = "knodes" }
    jellyfin        = { zvol = "mtank/jellyfin", blocksize = 512, pblocksize = true, lunid = 0, initiator = "knodes" }
    jackett         = { zvol = "mtank/jackett", blocksize = 512, pblocksize = true, lunid = 1, initiator = "knodes" }
    immich-ml-cache = { zvol = "mtank/immich-ml-cache", blocksize = 4096, pblocksize = false, lunid = 0, initiator = "immich-ml-cache" }
    immich-redis    = { zvol = "mtank/immich-redis", blocksize = 4096, pblocksize = false, lunid = 0, initiator = "immich-redis" }
    icloudpd        = { zvol = "etank/iscsi/icloudpd", blocksize = 4096, pblocksize = false, lunid = 0, initiator = "icloudpd" }
  }

  initiator_groups = {
    knodes          = "k8s nodes"
    immich-ml-cache = "immich-ml-cache"
    immich-redis    = "immich-redis"
    icloudpd        = "icloudpd"
  }
}

resource "truenas_iscsi_global" "nas1" {
  provider             = truenas.nas1
  basename             = "iqn.2014-09.com.radoncanyon:nas1"
  listen_port          = 3260
  pool_avail_threshold = 50
}

resource "truenas_iscsi_global" "nas2" {
  provider             = truenas.nas2
  basename             = "iqn.2005-10.org.freenas.ctl"
  listen_port          = 3260
  pool_avail_threshold = 0
}

resource "truenas_iscsi_portal" "nas1" {
  provider = truenas.nas1
  comment  = ""
  listen   = [{ ip = "192.168.222.149" }]
}

resource "truenas_iscsi_initiator" "nas1" {
  for_each   = local.initiator_groups
  provider   = truenas.nas1
  comment    = each.value
  initiators = local.k8s_initiators
}

resource "truenas_iscsi_extent" "nas1" {
  for_each     = local.static_luns
  provider     = truenas.nas1
  name         = each.key
  type         = "DISK"
  disk         = "zvol/${each.value.zvol}"
  blocksize    = each.value.blocksize
  pblocksize   = each.value.pblocksize
  insecure_tpc = true
  rpm          = "SSD"

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_iscsi_target" "nas1" {
  for_each = local.static_luns
  provider = truenas.nas1
  name     = each.key
  alias    = ""
  mode     = "ISCSI"
  groups = [{
    portal     = truenas_iscsi_portal.nas1.id
    initiator  = truenas_iscsi_initiator.nas1[each.value.initiator].id
    authmethod = "NONE"
    auth       = 0
  }]

  lifecycle {
    prevent_destroy = true
  }
}

resource "truenas_iscsi_targetextent" "nas1" {
  for_each = local.static_luns
  provider = truenas.nas1
  target   = truenas_iscsi_target.nas1[each.key].id
  extent   = truenas_iscsi_extent.nas1[each.key].id
  lunid    = each.value.lunid
}
