resource "truenas_group" "dockerfs_nas1" {
  provider               = truenas.nas1
  gid                    = 1001
  name                   = "dockerfs"
  smb                    = true
  sudo_commands          = []
  sudo_commands_nopasswd = []
  users                  = []
}

resource "truenas_group" "ladmin_nas1" {
  provider               = truenas.nas1
  gid                    = 3001
  name                   = "ladmin"
  smb                    = false
  sudo_commands          = []
  sudo_commands_nopasswd = []
  users                  = []
}

resource "truenas_group" "luser_nas1" {
  provider               = truenas.nas1
  gid                    = 3000
  name                   = "luser"
  smb                    = false
  sudo_commands          = []
  sudo_commands_nopasswd = []
  users                  = []
}

resource "truenas_group" "dockerfs_nas2" {
  provider               = truenas.nas2
  gid                    = 1001
  name                   = "dockerfs"
  smb                    = false
  sudo_commands          = []
  sudo_commands_nopasswd = []
  users                  = []
}

resource "truenas_group" "floppypaws_nas2" {
  provider               = truenas.nas2
  gid                    = 1000
  name                   = "floppypaws"
  smb                    = true
  sudo_commands          = []
  sudo_commands_nopasswd = []
  users                  = []
}

resource "truenas_group" "ladmin_nas2" {
  provider               = truenas.nas2
  gid                    = 3000
  name                   = "ladmin"
  smb                    = false
  sudo_commands          = []
  sudo_commands_nopasswd = []
  users                  = []
}

resource "truenas_group" "repl_nas1_nas2" {
  provider               = truenas.nas2
  gid                    = 3001
  name                   = "repl-nas1"
  smb                    = false
  sudo_commands          = []
  sudo_commands_nopasswd = []
  users                  = []
}

resource "truenas_user" "dockerfs_nas1" {
  provider               = truenas.nas1
  email                  = ""
  full_name              = "dockerfs"
  group                  = 41
  group_create           = true
  groups                 = [41]
  home                   = "/var/empty"
  locked                 = false
  password_disabled      = false
  shell                  = "/usr/sbin/nologin"
  smb                    = true
  ssh_password_enabled   = false
  sshpubkey              = ""
  sudo_commands          = []
  sudo_commands_nopasswd = []
  uid                    = 1001
  username               = "dockerfs"
  webshare               = false
}

resource "truenas_user" "ladmin_nas1" {
  provider               = truenas.nas1
  email                  = "ladmin-nas1@aethertrail.com"
  full_name              = "Local Admin"
  group                  = 115
  group_create           = true
  groups                 = [47]
  home                   = "/var/empty"
  locked                 = false
  password_disabled      = false
  shell                  = "/usr/sbin/nologin"
  smb                    = true
  ssh_password_enabled   = false
  sshpubkey              = ""
  sudo_commands          = ["ALL"]
  sudo_commands_nopasswd = []
  uid                    = 3001
  username               = "ladmin"
  webshare               = false
}

resource "truenas_user" "luser_nas1" {
  provider               = truenas.nas1
  email                  = ""
  full_name              = "Local User"
  group                  = 114
  group_create           = true
  groups                 = [51]
  home                   = "/var/empty"
  locked                 = false
  password_disabled      = false
  shell                  = "/usr/sbin/nologin"
  smb                    = true
  ssh_password_enabled   = false
  sshpubkey              = ""
  sudo_commands          = []
  sudo_commands_nopasswd = ["ALL"]
  uid                    = 3000
  username               = "luser"
  webshare               = false
}

resource "truenas_user" "media_nas1" {
  provider               = truenas.nas1
  email                  = ""
  full_name              = "Media User"
  group                  = 28
  group_create           = false
  groups                 = []
  home                   = "/var/empty"
  locked                 = false
  password_disabled      = true
  shell                  = "/usr/sbin/nologin"
  smb                    = false
  ssh_password_enabled   = false
  sshpubkey              = ""
  sudo_commands          = []
  sudo_commands_nopasswd = []
  uid                    = 8675309
  username               = "media"
  webshare               = false
}

resource "truenas_user" "dockerfs_nas2" {
  provider               = truenas.nas2
  email                  = ""
  full_name              = "dockerfs"
  group                  = 39
  group_create           = true
  groups                 = [12]
  home                   = "/mnt/etank/home/dockerfs"
  home_mode              = "755"
  locked                 = false
  password_disabled      = false
  shell                  = "/usr/bin/bash"
  smb                    = true
  ssh_password_enabled   = true
  sshpubkey              = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6kTX4+xV3Xdo7QRHMIsZaZABV24Ini0/mcrGUfJeddpWzaD+63lI6h4Y9Pnrb1g/D5hvMUm/7AZ2BDiG+2/rJ3nTBdBqbNZXC5m9lLvn4G1uWDn7XmhBfZcXSv99vTHDzXSnHPLowkAT+CHBvT7ZEJZa5Xsmvtb1AQFZhw1U6DrahyXK09PDP41DImrb1Qb3yjSbyHLMzMZ0xroEVPqh3ncqLQH7+lXAxkt8Rn/GGUguhP71vPJgEOw3f81locrnhVERSErNC7BhxioQvPXQfjgK8ejx3YLo6pUYoELyAosekxeeWGR0ZZbWl6vBTB4rtea/N38HrWYfVTyMsF9u+7WTQoAAOhuQr7JUS+7ezBS+Elsva0rKmPdb5KMkHcEIKCEtxJC1V+gXY1g4Ij15k0/2dbnayn2oLboCI1jND945UEkgpajHMiLf1fgayocpyU8iREv5qFaztiTkCy11tv23W4tXDOESdtcHeTajKx8xj9WK+XzLnIu0A8DXWBCct7VGZEM8kRfa41OEIBQ7KFODpZgqMTGx3qC1gO+WZY3uKo6j/5GU/ZfCFs+6cMR60ctDVAholTCfhv2ihsyMfppm9vciwNw37wXrRT1UrM47pDgjPNJtMfchqzxf0zStIutuxfABzN6PLQGVkO6k2YXiFmzpHK4rr5JZl8RTQ9w=="
  sudo_commands          = []
  sudo_commands_nopasswd = []
  uid                    = 1001
  username               = "dockerfs"
  webshare               = false
}

resource "truenas_user" "floppypaws_nas2" {
  provider               = truenas.nas2
  email                  = ""
  full_name              = "floppypaws"
  group                  = 42
  group_create           = true
  groups                 = []
  home                   = "/var/empty"
  locked                 = false
  password_disabled      = false
  shell                  = "/usr/sbin/nologin"
  smb                    = true
  ssh_password_enabled   = true
  sshpubkey              = ""
  sudo_commands          = []
  sudo_commands_nopasswd = []
  uid                    = 1000
  username               = "floppypaws"
  webshare               = false
}

resource "truenas_user" "ladmin_nas2" {
  provider               = truenas.nas2
  email                  = "ladmin-nas2@aethertrail.com"
  full_name              = "Local Admin"
  group                  = 113
  group_create           = true
  groups                 = [44]
  home                   = "/var/empty"
  locked                 = false
  password_disabled      = false
  shell                  = "/usr/sbin/nologin"
  smb                    = false
  ssh_password_enabled   = false
  sshpubkey              = ""
  sudo_commands          = []
  sudo_commands_nopasswd = ["ALL"]
  uid                    = 3000
  username               = "ladmin"
  webshare               = false
}

resource "truenas_user" "media_nas2" {
  provider               = truenas.nas2
  email                  = ""
  full_name              = "Media User"
  group                  = 28
  group_create           = false
  groups                 = []
  home                   = "/var/empty"
  locked                 = false
  password_disabled      = true
  shell                  = "/usr/sbin/nologin"
  smb                    = false
  ssh_password_enabled   = true
  sshpubkey              = ""
  sudo_commands          = []
  sudo_commands_nopasswd = []
  uid                    = 8675309
  username               = "media"
  webshare               = false
}

resource "truenas_user" "repl_nas1_nas2" {
  provider               = truenas.nas2
  email                  = ""
  full_name              = "nas1 replication (receive only)"
  group                  = 116
  group_create           = true
  groups                 = []
  home                   = "/mnt/etank/backups/repl-nas1"
  home_mode              = "700"
  locked                 = false
  password_disabled      = true
  shell                  = "/usr/bin/bash"
  smb                    = false
  ssh_password_enabled   = false
  sshpubkey              = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5KW2PPDiz6IRT7UegiFzlfCaASpf4uAKYhafxmwEQk1Uhs9Sz8VHw+w5qp7kKzAZ9qlr2m4dLGTyNsCkGJVzRkPt5AbJtRTyVe19bnKQzqqB3D40H3SMeCvyQnc7Ux05CixtVH5Nqe/0uAbnXRRkNha0uJJDjtP/UlWtU6Qe+aMBav8tuB8xo0s6JJT76N8YzrZHO7sUgKP4oeBOOcUgWWBxk+8KIo6muNWVQFQGXnzpSZSmf9LrqAlUXiCwQSuxxXHgYs9itw58Mz4hlQgQikeTuVBuEsGYZYaMnX4hhC5BaST3/ARp8dxthZ+kYmwFKsm90OHrUDBU4QKCHF5GWqcMnS+5eCSi5Vbip/u44yOwgmKicqEv3dul6mY1WBWR5jcqgwL6YlwEAuLuG+KAj6L3m6HJ6vUr4DBA/WkYNidzU4963ga49zhh+cQLKqgEvfDU/8uSIRfQ2jndQkwfvOTIuny/8UjpF3CeEniIa/kmz/kb7UmqRXp2lAc+m6uk= root@nas1"
  sudo_commands          = []
  sudo_commands_nopasswd = []
  uid                    = 3001
  username               = "repl-nas1"
  webshare               = false
}
