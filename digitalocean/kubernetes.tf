locals {
  region = "nyc3"
}

# Kept apart from the home networks (192.168.0.0/16, k3s on 10.42.0.0/16 and
# 10.43.0.0/16) and from the account's default VPCs, so the cluster can later
# be routed to home over the tailnet without overlaps.
resource "digitalocean_vpc" "kernel" {
  name     = "kernel-${local.region}"
  region   = local.region
  ip_range = "10.150.0.0/20"
}

data "digitalocean_kubernetes_versions" "kernel" {
  version_prefix = "1.37."
}

# Runs the services the home cluster can't host without depending on itself,
# starting with Forgejo.
resource "digitalocean_kubernetes_cluster" "kernel" {
  name     = "kernel"
  region   = local.region
  version  = data.digitalocean_kubernetes_versions.kernel.latest_version
  vpc_uuid = digitalocean_vpc.kernel.id

  cluster_subnet = "10.152.0.0/16"
  service_subnet = "10.153.0.0/16"

  # The HA control plane costs $40/month, which doesn't fit the $100/month
  # budget next to three nodes and a load balancer. It can be enabled later
  # but never disabled.
  ha = false

  # DigitalOcean applies patch releases in the maintenance window (03:00 New
  # York time on Sundays), and the version data source then matches the
  # cluster again. A new patch shows in a plan only until that window or the
  # next apply. A minor upgrade is a change to version_prefix.
  auto_upgrade  = true
  surge_upgrade = true
  maintenance_policy {
    day        = "sunday"
    start_time = "08:00"
  }

  node_pool {
    name       = "default"
    size       = "s-2vcpu-4gb"
    node_count = 3
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "cluster_id" {
  value = digitalocean_kubernetes_cluster.kernel.id
}

output "cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.kernel.endpoint
}
