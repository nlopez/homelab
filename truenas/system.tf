resource "truenas_alert_service" "aws_ses_nas1" {
  provider   = truenas.nas1
  attributes = jsonencode({ type = "Mail", email = "" })
  enabled    = true
  level      = "WARNING"
  name       = "AWS SES"
}

resource "truenas_alert_service" "aws_ses_nas2" {
  provider   = truenas.nas2
  attributes = jsonencode({ type = "Mail", email = "" })
  enabled    = true
  level      = "WARNING"
  name       = "AWS SES"
}

resource "truenas_alert_service" "snmp_trap_nas1" {
  provider   = truenas.nas1
  attributes = jsonencode({ type = "SNMPTrap", host = "localhost", port = 162, v3 = false, community = "public" })
  enabled    = false
  level      = "WARNING"
  name       = "SNMP Trap"
}

resource "truenas_alert_service" "snmp_trap_nas2" {
  provider   = truenas.nas2
  attributes = jsonencode({ type = "SNMPTrap", host = "localhost", port = 162, v3 = false, community = "public" })
  enabled    = false
  level      = "WARNING"
  name       = "SNMP Trap"
}

resource "truenas_docker_config" "docker_nas1" {
  provider = truenas.nas1
  address_pools = [
    {
      base = "172.17.0.0/12"
      size = 24
    },
    {
      base = "fdd0::/48"
      size = 64
    },
  ]
  cidr_v6              = "fdd0::/64"
  enable_image_updates = true
  nvidia               = false
  pool                 = "mtank"
  registry_mirrors = [
  ]
}

resource "truenas_docker_config" "docker_nas2" {
  provider = truenas.nas2
  address_pools = [
    {
      base = "172.17.0.0/12"
      size = 24
    },
    {
      base = "fdd0::/48"
      size = 64
    },
  ]
  cidr_v6              = "fdd0::/64"
  enable_image_updates = true
  nvidia               = false
  pool                 = "etank"
  registry_mirrors = [
  ]
}

resource "truenas_network_config" "network_nas1" {
  provider    = truenas.nas1
  domain      = "lga1.radoncanyon.com"
  domains     = []
  hostname    = "nas1"
  hosts       = []
  httpproxy   = ""
  ipv4gateway = "192.168.222.1"
  ipv6gateway = "fe80::2e2:69ff:fe5c:5d91"
  nameserver1 = "192.168.222.1"
  nameserver2 = ""
  nameserver3 = ""
  service_announcement = {
    mdns    = false
    netbios = false
    wsd     = false
  }
}

resource "truenas_network_config" "network_nas2" {
  provider    = truenas.nas2
  domain      = "lga1.radoncanyon.com"
  domains     = []
  hostname    = "nas2"
  hosts       = []
  httpproxy   = ""
  ipv4gateway = "192.168.222.1"
  ipv6gateway = ""
  nameserver1 = "192.168.222.1"
  nameserver2 = ""
  nameserver3 = ""
  service_announcement = {
    mdns    = false
    netbios = false
    wsd     = false
  }
}

resource "truenas_nfs_config" "nfs_nas1" {
  provider          = truenas.nas1
  allow_nonroot     = true
  bindip            = []
  mountd_log        = false
  mountd_port       = 0
  protocols         = ["NFSV3", "NFSV4"]
  rdma              = false
  rpclockd_port     = 0
  rpcstatd_port     = 0
  servers           = 8
  statd_lockd_log   = false
  userd_manage_gids = false
  v4_domain         = ""
  v4_krb            = false
}

resource "truenas_nfs_config" "nfs_nas2" {
  provider          = truenas.nas2
  allow_nonroot     = true
  bindip            = []
  mountd_log        = false
  mountd_port       = 0
  protocols         = ["NFSV3", "NFSV4"]
  rdma              = false
  rpclockd_port     = 0
  rpcstatd_port     = 0
  servers           = 0
  statd_lockd_log   = false
  userd_manage_gids = false
  v4_domain         = ""
  v4_krb            = false
}

resource "truenas_service" "cifs_nas1" {
  provider = truenas.nas1
  enabled  = true
  name     = "cifs"
  running  = true
}

resource "truenas_service" "cifs_nas2" {
  provider = truenas.nas2
  enabled  = true
  name     = "cifs"
  running  = true
}

resource "truenas_service" "iscsitarget_nas1" {
  provider = truenas.nas1
  enabled  = true
  name     = "iscsitarget"
  running  = true
}

resource "truenas_service" "iscsitarget_nas2" {
  provider = truenas.nas2
  enabled  = true
  name     = "iscsitarget"
  running  = true
}

resource "truenas_service" "nfs_nas1" {
  provider = truenas.nas1
  enabled  = true
  name     = "nfs"
  running  = true
}

resource "truenas_service" "nfs_nas2" {
  provider = truenas.nas2
  enabled  = true
  name     = "nfs"
  running  = true
}

resource "truenas_service" "ssh_nas1" {
  provider = truenas.nas1
  enabled  = true
  name     = "ssh"
  running  = true
}

resource "truenas_service" "ssh_nas2" {
  provider = truenas.nas2
  enabled  = true
  name     = "ssh"
  running  = true
}

resource "truenas_smb_config" "smb_nas1" {
  provider          = truenas.nas1
  aapl_extensions   = false
  admin_group       = ""
  bindip            = []
  debug             = false
  description       = ""
  dirmask           = "DEFAULT"
  encryption        = "DEFAULT"
  filemask          = "DEFAULT"
  guest             = "dockerfs"
  localmaster       = false
  minimum_protocol  = ""
  multichannel      = false
  netbiosalias      = ["nas1"]
  netbiosname       = "nas1"
  ntlmv1_auth       = false
  search_protocols  = []
  smb_options       = ""
  stateful_failover = false
  syslog            = false
  unixcharset       = "UTF-8"
  workgroup         = "WORKGROUP"
}

resource "truenas_smb_config" "smb_nas2" {
  provider          = truenas.nas2
  aapl_extensions   = true
  admin_group       = ""
  bindip            = []
  debug             = false
  description       = "nas2"
  dirmask           = "DEFAULT"
  encryption        = "DEFAULT"
  filemask          = "DEFAULT"
  guest             = "nobody"
  localmaster       = true
  minimum_protocol  = ""
  multichannel      = false
  netbiosalias      = ["nas2"]
  netbiosname       = "nas2"
  ntlmv1_auth       = false
  search_protocols  = []
  smb_options       = ""
  stateful_failover = false
  syslog            = false
  unixcharset       = "UTF-8"
  workgroup         = "WORKGROUP"
}

resource "truenas_ssh_config" "ssh_nas1" {
  provider              = truenas.nas1
  bindiface             = []
  compression           = false
  kerberosauth          = false
  options               = "PubkeyAcceptedAlgorithms +ssh-rsa"
  password_login_groups = []
  passwordauth          = false
  sftp_log_facility     = ""
  sftp_log_level        = ""
  tcpfwd                = false
  tcpport               = 22
  weak_ciphers          = ["AES128-CBC", "NONE"]
}

resource "truenas_ssh_config" "ssh_nas2" {
  provider              = truenas.nas2
  bindiface             = ["lagg0"]
  compression           = false
  kerberosauth          = false
  options               = ""
  password_login_groups = []
  passwordauth          = true
  sftp_log_facility     = ""
  sftp_log_level        = ""
  tcpfwd                = false
  tcpport               = 22
  weak_ciphers          = ["AES128-CBC", "NONE"]
}

resource "truenas_system_advanced" "system_advanced_nas1" {
  provider             = truenas.nas1
  advancedmode         = false
  anonstats            = true
  autotune             = false
  boot_scrub           = 7
  consolemenu          = true
  consolemsg           = true
  debugkernel          = false
  fqdn_syslog          = false
  kdump_enabled        = false
  kernel_extra_options = ""
  login_banner         = ""
  motd                 = "Welcome to FreeNAS (nas1)"
  nvidia               = false
  powerdaemon          = false
  sed_user             = "USER"
  serialconsole        = false
  serialport           = "ttyS1"
  serialspeed          = "9600"
  syslog_audit         = false
  sysloglevel          = "F_INFO"
  syslogservers = [
  ]
  traceback   = true
  uploadcrash = true
}

resource "truenas_system_advanced" "system_advanced_nas2" {
  provider             = truenas.nas2
  advancedmode         = false
  anonstats            = true
  autotune             = false
  boot_scrub           = 7
  consolemenu          = true
  consolemsg           = true
  debugkernel          = false
  fqdn_syslog          = false
  kdump_enabled        = false
  kernel_extra_options = ""
  login_banner         = ""
  motd                 = "Welcome to FreeNAS (nas2)"
  nvidia               = false
  powerdaemon          = false
  sed_user             = "USER"
  serialconsole        = true
  serialport           = "ttyS0"
  serialspeed          = "115200"
  syslog_audit         = false
  sysloglevel          = "F_INFO"
  syslogservers = [
  ]
  traceback   = true
  uploadcrash = true
}

resource "truenas_system_general" "system_general_nas1" {
  provider           = truenas.nas1
  ds_auth            = false
  kbdmap             = "us"
  timezone           = "UTC"
  ui_address         = ["0.0.0.0"]
  ui_allowlist       = []
  ui_certificate     = 21
  ui_consolemsg      = true
  ui_httpsport       = 443
  ui_httpsprotocols  = ["TLSv1.2", "TLSv1.3"]
  ui_httpsredirect   = true
  ui_port            = 80
  ui_v6address       = ["::"]
  ui_x_frame_options = "SAMEORIGIN"
  usage_collection   = false
}

resource "truenas_system_general" "system_general_nas2" {
  provider           = truenas.nas2
  ds_auth            = false
  kbdmap             = "us"
  timezone           = "UTC"
  ui_address         = ["0.0.0.0"]
  ui_allowlist       = []
  ui_certificate     = 16
  ui_consolemsg      = true
  ui_httpsport       = 443
  ui_httpsprotocols  = ["TLSv1.2", "TLSv1.3"]
  ui_httpsredirect   = false
  ui_port            = 80
  ui_v6address       = ["::"]
  ui_x_frame_options = "SAMEORIGIN"
  usage_collection   = false
}
