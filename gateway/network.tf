# VLANs and virtual IPs, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

locals {
  lga1_vlans = {
    "vlan01" = {
      uuid             = "1eb2438e-4ba8-434e-a125-398f070952fd"
      device           = "vlan01"
      parent_interface = "igc0"
      tag              = "10"
      description      = "WLAN"
      priority         = "0"
    }
    "vlan02" = {
      uuid             = "06567aeb-bffa-4479-87c6-3f73aef278cc"
      device           = "vlan02"
      parent_interface = "igc0"
      tag              = "20"
      description      = "LAB"
      priority         = "0"
    }
    "vlan03" = {
      uuid             = "19d524e6-f5b2-4771-82cc-8d33b1b35e29"
      device           = "vlan03"
      parent_interface = "igc0"
      tag              = "30"
      description      = "K8S"
      priority         = "0"
    }
  }

  lga1_vips = {
    "lan-fd54:571b:560a:1::1" = {
      uuid        = "6f650cee-7476-4308-8aff-ee9e08a426f6"
      address     = "fd54:571b:560a:1::1"
      interface   = "lan"
      subnet_bits = "64"
      mode        = "ipalias"
      description = "ULA"
      adv_base    = "1"
      adv_skew    = "0"
    }
    "opt2-fd54:571b:560a:2::1" = {
      uuid        = "05c51e3a-3c65-4a5e-9144-5da7170bb625"
      address     = "fd54:571b:560a:2::1"
      interface   = "opt2"
      subnet_bits = "64"
      mode        = "ipalias"
      description = "ULA"
      adv_base    = "1"
      adv_skew    = "0"
    }
    "opt1-fd54:571b:560a:3::1" = {
      uuid        = "9a5afd45-a3b7-4d57-9893-6fd6ca239a79"
      address     = "fd54:571b:560a:3::1"
      interface   = "opt1"
      subnet_bits = "64"
      mode        = "ipalias"
      description = "ULA"
      adv_base    = "1"
      adv_skew    = "0"
    }
  }

  lga2_vlans = {
    "vlan0.3240" = {
      uuid             = "c1c5dc7a-164d-433e-997a-9860c4db6d23"
      device           = "vlan0.3240"
      parent_interface = "igc0"
      tag              = "3240"
      priority         = "0"
    }
    "vlan0.3241" = {
      uuid             = "3418485d-dfd6-4210-81fb-1c73eea68a96"
      device           = "vlan0.3241"
      parent_interface = "igc0"
      tag              = "3241"
      priority         = "0"
    }
    "vlan0.3239" = {
      uuid             = "7b35fa44-d0fa-48d1-875d-53c50e23c5e0"
      device           = "vlan0.3239"
      parent_interface = "igc0"
      tag              = "3239"
      priority         = "0"
    }
  }

  lga2_vips = {
    "lan-fd72:ce7b:d4a9:9511::254" = {
      uuid        = "fb191dfa-c441-475a-a751-3ecb9f670015"
      address     = "fd72:ce7b:d4a9:9511::254"
      interface   = "lan"
      subnet_bits = "64"
      mode        = "ipalias"
      description = "IPv6 ULA"
      adv_base    = "1"
      adv_skew    = "0"
    }
  }

}

resource "opnsense_system_vlan" "lga1_vlans" {
  provider = opnsense.lga1
  for_each = local.lga1_vlans

  device           = each.value.device
  parent_interface = each.value.parent_interface
  tag              = each.value.tag
  description      = try(each.value.description, null)
  priority         = try(each.value.priority, null)
  proto            = try(each.value.proto, null)
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_vlans
  to       = opnsense_system_vlan.lga1_vlans[each.key]
  id       = each.value.uuid
}

resource "opnsense_system_vip" "lga1_vips" {
  provider = opnsense.lga1
  for_each = local.lga1_vips

  address     = each.value.address
  interface   = each.value.interface
  subnet_bits = each.value.subnet_bits
  mode        = try(each.value.mode, null)
  description = try(each.value.description, null)
  adv_base    = try(each.value.adv_base, null)
  adv_skew    = try(each.value.adv_skew, null)
  vhid        = try(each.value.vhid, null)
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_vips
  to       = opnsense_system_vip.lga1_vips[each.key]
  id       = each.value.uuid
}

resource "opnsense_system_vlan" "lga2_vlans" {
  provider = opnsense.lga2
  for_each = local.lga2_vlans

  device           = each.value.device
  parent_interface = each.value.parent_interface
  tag              = each.value.tag
  description      = try(each.value.description, null)
  priority         = try(each.value.priority, null)
  proto            = try(each.value.proto, null)
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_vlans
  to       = opnsense_system_vlan.lga2_vlans[each.key]
  id       = each.value.uuid
}

resource "opnsense_system_vip" "lga2_vips" {
  provider = opnsense.lga2
  for_each = local.lga2_vips

  address     = each.value.address
  interface   = each.value.interface
  subnet_bits = each.value.subnet_bits
  mode        = try(each.value.mode, null)
  description = try(each.value.description, null)
  adv_base    = try(each.value.adv_base, null)
  adv_skew    = try(each.value.adv_skew, null)
  vhid        = try(each.value.vhid, null)
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_vips
  to       = opnsense_system_vip.lga2_vips[each.key]
  id       = each.value.uuid
}

