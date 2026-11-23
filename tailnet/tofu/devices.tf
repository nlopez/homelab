# Devices that register with a preauth key or interactive login start untagged,
# which puts them outside every tag-based rule. Tag them here.
data "tailscale_device" "gw_lga2" {
  hostname = "gw-lga2"
}

resource "tailscale_device_tags" "gw_lga2" {
  device_id = data.tailscale_device.gw_lga2.node_id
  tags      = ["tag:lga2"]
}
