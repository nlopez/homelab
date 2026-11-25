resource "truenas_ntp_server" "nas1" {
  for_each = toset(["time.google.com", "time2.google.com", "time3.google.com"])
  provider = truenas.nas1
  address  = each.key
  iburst   = true
  prefer   = each.key == "time.google.com"
}

resource "truenas_ntp_server" "nas2" {
  for_each = toset(["time.google.com", "time2.google.com", "time3.google.com"])
  provider = truenas.nas2
  address  = each.key
  iburst   = true
}

resource "truenas_twofactor_auth" "nas1" {
  provider = truenas.nas1
  enabled  = true
  services = { ssh = true }
}

resource "truenas_twofactor_auth" "nas2" {
  provider = truenas.nas2
  enabled  = true
  services = { ssh = true }
}

resource "truenas_ipmi_lan" "nas1" {
  provider  = truenas.nas1
  channel   = 1
  dhcp      = false
  ipaddress = "192.168.222.148"
  netmask   = "255.255.255.0"
  gateway   = "192.168.222.1"
}

resource "truenas_ipmi_lan" "nas2" {
  provider  = truenas.nas2
  channel   = 1
  dhcp      = false
  ipaddress = "192.168.222.113"
  netmask   = "255.255.255.0"
  gateway   = "192.168.222.1"
}

resource "truenas_system_dataset" "nas1" {
  provider = truenas.nas1
  pool     = "etank"
}

resource "truenas_system_dataset" "nas2" {
  provider = truenas.nas2
  pool     = "etank"
}

resource "truenas_catalog_config" "nas1" {
  provider         = truenas.nas1
  preferred_trains = ["community", "stable"]
}

resource "truenas_catalog_config" "nas2" {
  provider         = truenas.nas2
  preferred_trains = ["community", "stable"]
}

resource "truenas_resilver_config" "nas1" {
  provider = truenas.nas1
  enabled  = false
  begin    = "18:00"
  end      = "09:00"
  weekday  = [1, 2, 3, 4, 5, 6, 7]
}

resource "truenas_resilver_config" "nas2" {
  provider = truenas.nas2
  enabled  = false
  begin    = "18:00"
  end      = "09:00"
  weekday  = [1, 2, 3, 4, 5, 6, 7]
}

resource "truenas_replication_config" "nas1" {
  provider = truenas.nas1
}

resource "truenas_replication_config" "nas2" {
  provider = truenas.nas2
}
