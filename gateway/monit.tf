# Monit tests and services, imported from the live gateways.
# Generated from config.xml; keep in sync with the appliance.

locals {
  lga1_monit_tests = {
    "Ping" = {
      uuid      = "f2d79755-5f36-4be3-80cc-2d39b0691f75"
      name      = "Ping"
      type      = "NetworkPing"
      condition = "failed ping"
      action    = "alert"
    }
    "NetworkLink" = {
      uuid      = "0fc568ea-3172-4003-9212-dc38807ac9be"
      name      = "NetworkLink"
      type      = "NetworkInterface"
      condition = "failed link"
      action    = "alert"
    }
    "NetworkSaturation" = {
      uuid      = "c94c3d38-9d53-4748-9570-0d229ac4a6c1"
      name      = "NetworkSaturation"
      type      = "NetworkInterface"
      condition = "saturation is greater than 75%"
      action    = "alert"
    }
    "MemoryUsage" = {
      uuid      = "c7428a9e-d543-4819-917e-def4a9cb2e30"
      name      = "MemoryUsage"
      type      = "SystemResource"
      condition = "memory usage is greater than 75%"
      action    = "alert"
    }
    "CPUUsage" = {
      uuid      = "7952751d-a757-477d-a8d3-352fba83bb6b"
      name      = "CPUUsage"
      type      = "SystemResource"
      condition = "cpu usage is greater than 75%"
      action    = "alert"
    }
    "LoadAvg1" = {
      uuid      = "7c1bf5a0-b690-4b2c-8d42-4203bf736cb4"
      name      = "LoadAvg1"
      type      = "SystemResource"
      condition = "loadavg (1min) is greater than 8"
      action    = "alert"
    }
    "LoadAvg5" = {
      uuid      = "5afd6b4c-125b-46ac-b999-7947c0fb25e9"
      name      = "LoadAvg5"
      type      = "SystemResource"
      condition = "loadavg (5min) is greater than 6"
      action    = "alert"
    }
    "LoadAvg15" = {
      uuid      = "faca6270-717c-420b-9e6e-48bb636b22ca"
      name      = "LoadAvg15"
      type      = "SystemResource"
      condition = "loadavg (15min) is greater than 4"
      action    = "alert"
    }
    "SpaceUsage" = {
      uuid      = "08d528bb-7e7c-4066-836c-7c131c5ba2e6"
      name      = "SpaceUsage"
      type      = "SpaceUsage"
      condition = "space usage is greater than 75%"
      action    = "alert"
    }
    "ChangedStatus" = {
      uuid      = "6807e83f-18fa-430b-9686-1255937b5009"
      name      = "ChangedStatus"
      type      = "ProgramStatus"
      condition = "changed status"
      action    = "alert"
    }
    "NonZeroStatus" = {
      uuid      = "fbe2d33b-ace8-49cf-9d72-2703197faad7"
      name      = "NonZeroStatus"
      type      = "ProgramStatus"
      condition = "status != 0"
      action    = "alert"
    }
  }

  lga1_monit_services = {
    "$HOST" = {
      uuid          = "4729abf9-338c-4825-b243-3e090740b2dc"
      name          = "$HOST"
      type          = "system"
      timeout       = 300
      start_timeout = 30
      tests         = ["c7428a9e-d543-4819-917e-def4a9cb2e30", "7952751d-a757-477d-a8d3-352fba83bb6b", "7c1bf5a0-b690-4b2c-8d42-4203bf736cb4", "5afd6b4c-125b-46ac-b999-7947c0fb25e9"]
      enabled       = true
    }
    "RootFs" = {
      uuid          = "636ed939-a1b5-43e3-8cfc-3adf0e20890f"
      name          = "RootFs"
      type          = "filesystem"
      path          = "/"
      timeout       = 300
      start_timeout = 30
      tests         = ["08d528bb-7e7c-4066-836c-7c131c5ba2e6"]
      enabled       = true
    }
    "carp_status_change" = {
      uuid          = "9500dc5f-274e-4c8f-9b32-dceddf52c115"
      name          = "carp_status_change"
      type          = "custom"
      path          = "/usr/local/opnsense/scripts/monit/carp_status.php"
      timeout       = 300
      start_timeout = 30
      tests         = ["6807e83f-18fa-430b-9686-1255937b5009"]
      enabled       = false
    }
    "gateway_alert" = {
      uuid          = "7c5c1e16-a4e5-4fd4-a3a2-cca2c7774a93"
      name          = "gateway_alert"
      type          = "custom"
      path          = "/usr/local/opnsense/scripts/monit/gateway_alert.php"
      timeout       = 300
      start_timeout = 30
      tests         = ["fbe2d33b-ace8-49cf-9d72-2703197faad7"]
      enabled       = false
    }
  }

  lga2_monit_tests = {
    "Ping" = {
      uuid      = "5d5527d8-92cc-4b2c-adf5-afca6d551c41"
      name      = "Ping"
      type      = "NetworkPing"
      condition = "failed ping"
      action    = "alert"
    }
    "NetworkLink" = {
      uuid      = "37f59959-e526-4234-b0e2-1d278fd03b9d"
      name      = "NetworkLink"
      type      = "NetworkInterface"
      condition = "failed link"
      action    = "alert"
    }
    "NetworkSaturation" = {
      uuid      = "72222b12-859d-475f-8f52-497e59b8d1c2"
      name      = "NetworkSaturation"
      type      = "NetworkInterface"
      condition = "saturation is greater than 75%"
      action    = "alert"
    }
    "MemoryUsage" = {
      uuid      = "cb16dcf7-df2a-4c53-8581-7a6dfcea57ce"
      name      = "MemoryUsage"
      type      = "SystemResource"
      condition = "memory usage is greater than 75%"
      action    = "alert"
    }
    "CPUUsage" = {
      uuid      = "ec6d24b6-244d-4111-8206-2485467cbfea"
      name      = "CPUUsage"
      type      = "SystemResource"
      condition = "cpu usage is greater than 75%"
      action    = "alert"
    }
    "LoadAvg1" = {
      uuid      = "d81e3016-f9f7-429b-8b85-03a09d6be6f2"
      name      = "LoadAvg1"
      type      = "SystemResource"
      condition = "loadavg (1min) is greater than 8"
      action    = "alert"
    }
    "LoadAvg5" = {
      uuid      = "cc782b23-a8da-43e4-a8a2-2898742f85ab"
      name      = "LoadAvg5"
      type      = "SystemResource"
      condition = "loadavg (5min) is greater than 6"
      action    = "alert"
    }
    "LoadAvg15" = {
      uuid      = "76db52bf-ad85-4e86-9ea7-92d519fc03cb"
      name      = "LoadAvg15"
      type      = "SystemResource"
      condition = "loadavg (15min) is greater than 4"
      action    = "alert"
    }
    "SpaceUsage" = {
      uuid      = "3ec05a0b-c4ff-40cc-bf56-9e60cde5d5d1"
      name      = "SpaceUsage"
      type      = "SpaceUsage"
      condition = "space usage is greater than 75%"
      action    = "alert"
    }
    "ChangedStatus" = {
      uuid      = "5d2772ac-fbb3-485c-a596-7f2cb1c2579c"
      name      = "ChangedStatus"
      type      = "ProgramStatus"
      condition = "changed status"
      action    = "alert"
    }
    "NonZeroStatus" = {
      uuid      = "f92e8b35-3a9d-4c80-b8fd-e7250d3199c7"
      name      = "NonZeroStatus"
      type      = "ProgramStatus"
      condition = "status != 0"
      action    = "alert"
    }
  }

  lga2_monit_services = {
    "$HOST" = {
      uuid          = "f289416f-0240-4a18-b506-1c327590b6e6"
      name          = "$HOST"
      type          = "system"
      timeout       = 300
      start_timeout = 30
      tests         = ["cb16dcf7-df2a-4c53-8581-7a6dfcea57ce", "ec6d24b6-244d-4111-8206-2485467cbfea", "d81e3016-f9f7-429b-8b85-03a09d6be6f2", "cc782b23-a8da-43e4-a8a2-2898742f85ab"]
      enabled       = true
    }
    "RootFs" = {
      uuid          = "d123b54e-643a-4f62-9502-17602b3e963d"
      name          = "RootFs"
      type          = "filesystem"
      path          = "/"
      timeout       = 300
      start_timeout = 30
      tests         = ["3ec05a0b-c4ff-40cc-bf56-9e60cde5d5d1"]
      enabled       = true
    }
    "carp_status_change" = {
      uuid          = "c82cb248-ee54-43b9-9a56-746484253543"
      name          = "carp_status_change"
      type          = "custom"
      path          = "/usr/local/opnsense/scripts/monit/carp_status.php"
      timeout       = 300
      start_timeout = 30
      tests         = ["5d2772ac-fbb3-485c-a596-7f2cb1c2579c"]
      enabled       = false
    }
    "gateway_alert" = {
      uuid          = "5041ee4c-4f84-4d81-aabb-009861fba758"
      name          = "gateway_alert"
      type          = "custom"
      path          = "/usr/local/opnsense/scripts/monit/gateway_alert.php"
      timeout       = 300
      start_timeout = 30
      tests         = ["f92e8b35-3a9d-4c80-b8fd-e7250d3199c7"]
      enabled       = false
    }
  }

}

resource "opnsense_monit_test" "lga1_monit_tests" {
  provider = opnsense.lga1
  for_each = local.lga1_monit_tests

  name      = each.value.name
  type      = each.value.type
  condition = each.value.condition
  action    = each.value.action
  path      = try(each.value.path, null)
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_monit_tests
  to       = opnsense_monit_test.lga1_monit_tests[each.key]
  id       = each.value.uuid
}

resource "opnsense_monit_service" "lga1_monit_services" {
  provider = opnsense.lga1
  for_each = local.lga1_monit_services

  name          = each.value.name
  type          = each.value.type
  description   = try(each.value.description, null)
  path          = try(each.value.path, null)
  address       = try(each.value.address, null)
  interface     = try(each.value.interface, null)
  start         = try(each.value.start, null)
  stop          = try(each.value.stop, null)
  timeout       = try(each.value.timeout, null)
  start_timeout = try(each.value.start_timeout, null)
  tests         = try(each.value.tests, null)
  enabled       = each.value.enabled
}

import {
  provider = opnsense.lga1
  for_each = local.lga1_monit_services
  to       = opnsense_monit_service.lga1_monit_services[each.key]
  id       = each.value.uuid
}

resource "opnsense_monit_test" "lga2_monit_tests" {
  provider = opnsense.lga2
  for_each = local.lga2_monit_tests

  name      = each.value.name
  type      = each.value.type
  condition = each.value.condition
  action    = each.value.action
  path      = try(each.value.path, null)
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_monit_tests
  to       = opnsense_monit_test.lga2_monit_tests[each.key]
  id       = each.value.uuid
}

resource "opnsense_monit_service" "lga2_monit_services" {
  provider = opnsense.lga2
  for_each = local.lga2_monit_services

  name          = each.value.name
  type          = each.value.type
  description   = try(each.value.description, null)
  path          = try(each.value.path, null)
  address       = try(each.value.address, null)
  interface     = try(each.value.interface, null)
  start         = try(each.value.start, null)
  stop          = try(each.value.stop, null)
  timeout       = try(each.value.timeout, null)
  start_timeout = try(each.value.start_timeout, null)
  tests         = try(each.value.tests, null)
  enabled       = each.value.enabled
}

import {
  provider = opnsense.lga2
  for_each = local.lga2_monit_services
  to       = opnsense_monit_service.lga2_monit_services[each.key]
  id       = each.value.uuid
}

