# TrueNAS records no last-used time on API keys, so the audit log is the only
# way to tell whether a key is still in use. 30 days covers monthly jobs.
resource "truenas_audit_config" "nas1" {
  provider  = truenas.nas1
  retention = 30
}

resource "truenas_audit_config" "nas2" {
  provider  = truenas.nas2
  retention = 30
}
