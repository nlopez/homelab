# Devices that register with a preauth key or interactive login start untagged,
# which puts them outside every tag-based rule. Tag them here.
data "tailscale_device" "gw_lga2" {
  hostname = "gw-lga2"
}

resource "tailscale_device_tags" "gw_lga2" {
  device_id = data.tailscale_device.gw_lga2.node_id
  tags      = ["tag:lga2"]
}

# The gateway is reached over Tailscale only, so an expired node key would cut
# off access to the box that renews it.
resource "tailscale_device_key" "gw_lga2" {
  device_id           = data.tailscale_device.gw_lga2.node_id
  key_expiry_disabled = true
}

data "tailscale_device" "gw_lga1" {
  hostname = "gw-lga1"
}

resource "tailscale_device_tags" "gw_lga1" {
  device_id = data.tailscale_device.gw_lga1.node_id
  tags      = ["tag:lga1"]
}

resource "tailscale_device_key" "gw_lga1" {
  device_id           = data.tailscale_device.gw_lga1.node_id
  key_expiry_disabled = true
}

data "tailscale_device" "odroid_lga1" {
  hostname = "odroid-lga1"
}

data "tailscale_device" "odroid_lga2" {
  hostname = "odroid-lga2"
}

# Both nodes at a site advertise that site's ranges. Approving the full set on
# each one means either node can serve the routes, and the IPv6 half does not
# stay pending when a node re-advertises.
resource "tailscale_device_subnet_routes" "gw_lga1" {
  device_id = data.tailscale_device.gw_lga1.node_id

  routes = [
  ]
}

resource "tailscale_device_subnet_routes" "odroid_lga1" {
  device_id = data.tailscale_device.odroid_lga1.node_id

  routes = [
    "10.43.64.0/24",
    "192.168.221.0/24",
    "192.168.222.0/24",
    "192.168.223.0/24",
    "fd54:571b:560a:1::/64",
    "fd54:571b:560a:2::/64",
    "fd54:571b:560a:3::/64",
    "fd54:571b:560a:4364::/64",
  ]
}

resource "tailscale_device_subnet_routes" "gw_lga2" {
  device_id = data.tailscale_device.gw_lga2.node_id

  routes = [
  ]
}

resource "tailscale_device_subnet_routes" "odroid_lga2" {
  device_id = data.tailscale_device.odroid_lga2.node_id

  routes = [
    "10.43.64.0/24",
    "192.168.239.0/24",
    "fd72:ce7b:d4a9:9511::/64",
  ]
}

# The Ansible workflow reaches these four hosts over Tailscale SSH. Their
# login advertises tag:home plus a site tag, which every other device at that
# site also carries, so an SSH rule scoped to those tags would reach nas1,
# nas2 and the k8s nodes' neighbours as well. tag:ansible names the hosts the
# playbooks configure and nothing else.
#
# shortcut: creating this for a device that does not already carry the tag
# fails with "cannot remove current tags", although the same request through
# the API succeeds. Set the tag once from the admin console or the API, then
# apply; upgrade when the provider's create path handles a new tag.
data "tailscale_device" "knode1" {
  hostname = "knode1"
}

resource "tailscale_device_tags" "knode1" {
  device_id = data.tailscale_device.knode1.node_id
  tags      = ["tag:home", "tag:lga1", "tag:ansible"]
}

data "tailscale_device" "knode2" {
  hostname = "knode2"
}

resource "tailscale_device_tags" "knode2" {
  device_id = data.tailscale_device.knode2.node_id
  tags      = ["tag:home", "tag:lga1", "tag:ansible"]
}

data "tailscale_device" "odroid_lga1_ansible" {
  hostname = "odroid-lga1"
}

resource "tailscale_device_tags" "odroid_lga1_ansible" {
  device_id = data.tailscale_device.odroid_lga1_ansible.node_id
  tags      = ["tag:exit", "tag:home", "tag:lga1", "tag:ansible"]
}

data "tailscale_device" "odroid_lga2_ansible" {
  hostname = "odroid-lga2"
}

resource "tailscale_device_tags" "odroid_lga2_ansible" {
  device_id = data.tailscale_device.odroid_lga2_ansible.node_id
  tags      = ["tag:exit", "tag:home", "tag:lga2", "tag:ansible"]
}
