# TrueNAS issues and renews the ACME UI certificates itself. Tofu tracking
# them only copied their private keys into state, so they are left unmanaged.
removed {
  from = truenas_certificate.ui_nas1
  lifecycle {
    destroy = false
  }
}

removed {
  from = truenas_certificate.ui_nas2
  lifecycle {
    destroy = false
  }
}
