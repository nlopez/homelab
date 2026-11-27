mock_provider "cloudflare" {
  alias = "mock"

  mock_resource "cloudflare_zone" {
    defaults = {
      id = "mock-zone-id"
    }
  }

  mock_data "cloudflare_zone" {
    defaults = {
      id = "mock-zone-id"
    }
  }
}

run "merge_applies_ttl_default_and_zone_field" {
  providers = {
    cloudflare = cloudflare.mock
  }

  variables {
    cloudflare_account_id = "123456789"
  }

  assert {
    # Test merge({ ttl = 1 }, r, { zone = zone }) at dns/main.tf:40
    # A record without explicit ttl (a-unifi has no ttl field) gets ttl = 1
    condition     = local.records["desertbluffs.com/a-unifi"].ttl == 1
    error_message = "Records without explicit ttl should get default ttl = 1 from merge"
  }

  assert {
    # An explicit ttl (cname-apex sets ttl = 60) is preserved by merge
    # merge(defaults, record, zone) gives precedence to record and zone
    condition     = local.records["desertbluffs.com/cname-apex"].ttl == 60
    error_message = "Records with explicit ttl should keep it (merge wins over default)"
  }

  assert {
    # The zone field is merged in for all records
    condition     = local.records["desertbluffs.com/a-unifi"].zone == "desertbluffs.com"
    error_message = "Merge should add zone field to every record"
  }
}
