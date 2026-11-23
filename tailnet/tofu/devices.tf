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
