import {
  provider = truenas.nas1
  to       = truenas_service.cifs_nas1
  id       = "cifs"
}

import {
  provider = truenas.nas1
  to       = truenas_service.iscsitarget_nas1
  id       = "iscsitarget"
}

import {
  provider = truenas.nas1
  to       = truenas_service.nfs_nas1
  id       = "nfs"
}

import {
  provider = truenas.nas1
  to       = truenas_service.ssh_nas1
  id       = "ssh"
}

import {
  provider = truenas.nas1
  to       = truenas_ssh_config.ssh_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_smb_config.smb_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_nfs_config.nfs_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_system_general.system_general_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_system_advanced.system_advanced_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_docker_config.docker_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_network_config.network_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_alert_service.aws_ses_nas1
  id       = "2"
}

import {
  provider = truenas.nas1
  to       = truenas_alert_service.snmp_trap_nas1
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_service.cifs_nas2
  id       = "cifs"
}

import {
  provider = truenas.nas2
  to       = truenas_service.iscsitarget_nas2
  id       = "iscsitarget"
}

import {
  provider = truenas.nas2
  to       = truenas_service.nfs_nas2
  id       = "nfs"
}

import {
  provider = truenas.nas2
  to       = truenas_service.ssh_nas2
  id       = "ssh"
}

import {
  provider = truenas.nas2
  to       = truenas_ssh_config.ssh_nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_smb_config.smb_nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_nfs_config.nfs_nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_system_general.system_general_nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_system_advanced.system_advanced_nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_docker_config.docker_nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_network_config.network_nas2
  id       = "1"
}

import {
  provider = truenas.nas2
  to       = truenas_alert_service.aws_ses_nas2
  id       = "2"
}

import {
  provider = truenas.nas2
  to       = truenas_alert_service.snmp_trap_nas2
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_periodic_snapshot_task.etank_iscsi_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_periodic_snapshot_task.mtank_hourly_nas1
  id       = "2"
}

import {
  provider = truenas.nas1
  to       = truenas_periodic_snapshot_task.mtank_daily_nas1
  id       = "3"
}

import {
  provider = truenas.nas1
  to       = truenas_periodic_snapshot_task.mtank_weekly_nas1
  id       = "4"
}

import {
  provider = truenas.nas1
  to       = truenas_periodic_snapshot_task.etank_daily_nas1
  id       = "5"
}

import {
  provider = truenas.nas1
  to       = truenas_periodic_snapshot_task.etank_weekly_nas1
  id       = "6"
}

import {
  provider = truenas.nas2
  to       = truenas_periodic_snapshot_task.etank_media_daily_nas2
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_scrub_task.scrub_1_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_scrub_task.scrub_3_nas1
  id       = "3"
}

import {
  provider = truenas.nas2
  to       = truenas_scrub_task.scrub_1_nas2
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_replication_task.mtank_to_nas2_nas1
  id       = "1"
}

import {
  provider = truenas.nas1
  to       = truenas_replication_task.etank_to_nas2_nas1
  id       = "2"
}

import {
  provider = truenas.nas1
  to       = truenas_keychain_ssh_keypair.nas1_to_nas2_replication_nas1
  id       = "6"
}

import {
  provider = truenas.nas1
  to       = truenas_keychain_ssh_connection.repl_nas1_at_nas2_nas1
  id       = "7"
}
