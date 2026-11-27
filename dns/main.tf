terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "dns/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# Reads CLOUDFLARE_API_TOKEN from the environment.
provider "cloudflare" {}

variable "cloudflare_account_id" {
  type = string
}

locals {
  # Records not declared in a zone's map are left alone, so records owned by
  # other systems (external-dns, cert-manager, DDNS) never show up in a plan.
  zones = {
    "desertbluffs.com" = local.desertbluffs_com_records
    "radoncanyon.com"  = local.radoncanyon_com_records
    "aethertrail.com"  = local.aethertrail_com_records
    "nulogorsk.com"    = local.nulogorsk_com_records
  }

  # TTL 1 is Cloudflare's automatic TTL; a record may set its own.
  records = merge([
    for zone, records in local.zones : {
      for key, r in records : "${zone}/${key}" => merge({ ttl = 1 }, r, { zone = zone })
    }
  ]...)
}

resource "cloudflare_zone" "this" {
  for_each = local.zones

  account = { id = var.cloudflare_account_id }
  name    = each.key
  type    = "full"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = local.records

  zone_id = cloudflare_zone.this[each.value.zone].id
  name    = each.value.name == "@" ? each.value.zone : "${each.value.name}.${each.value.zone}"
  type    = each.value.type
  ttl     = each.value.ttl
  proxied = try(each.value.proxied, false)

  # Cloudflare stores TXT content wrapped in double quotes.
  content  = each.value.type == "TXT" ? "\"${each.value.content}\"" : try(each.value.content, null)
  priority = try(each.value.priority, null)
  data     = try(each.value.data, null)
}
