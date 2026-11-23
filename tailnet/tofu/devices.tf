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
