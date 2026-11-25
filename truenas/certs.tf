resource "truenas_certificate" "ui_nas1" {
  provider             = truenas.nas1
  add_to_trusted_store = false
  create_type          = "CERTIFICATE_CREATE_ACME"
  key_type             = "EC"
  name                 = "nas1-acme"
}

resource "truenas_certificate" "ui_nas2" {
  provider             = truenas.nas2
  add_to_trusted_store = false
  create_type          = "CERTIFICATE_CREATE_ACME"
  key_type             = "EC"
  name                 = "nas2-acme"
}
