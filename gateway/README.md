# Site gateways

OPNsense configuration for `gw.lga1` and `gw.lga2`, managed with the
[`matthew-on-git/opnsense`](https://registry.terraform.io/providers/matthew-on-git/opnsense)
provider.

Managed here:

- Unbound query forwards and DNS-over-TLS forwards
- Unbound host overrides
- Custom gateways (the interface-generated `WAN_DHCP`/`WAN_DHCP6` ones are not)
- Static routes

Not covered by the provider, so left to the GUI and `config.xml` snapshots:
IDS, Squid, BIND, radvd, Tailscale, SNMP, captive portal, TAYGA, and the
system settings pages.

The `enabled` flag on routes and gateways is also left to the GUI: provider
`~> 0.30` never reads it back, so a route disabled here would show a permanent
diff and fail the apply that tries to write it.

## Running it

Credentials come from the two 1Password items that `ansible/scripts/device_inventory.py`
uses:

```sh
V=op://evjh25ux2mnoufaut6qhvm2pdi
export TF_VAR_lga1_api_key="$(op read $V/bf3fyn3ojaajnozdbobkhtboli/key --account my.1password.com)"
export TF_VAR_lga1_api_secret="$(op read $V/bf3fyn3ojaajnozdbobkhtboli/credential --account my.1password.com)"
export TF_VAR_lga2_api_key="$(op read $V/whuw4bp5c3lbzv2hmq4nja7qvq/key --account my.1password.com)"
export TF_VAR_lga2_api_secret="$(op read $V/whuw4bp5c3lbzv2hmq4nja7qvq/credential --account my.1password.com)"
tofu init && tofu plan
```

State is in the `homelab-tofu-state-546422192262` bucket under `gateway/terraform.tfstate`.

## Adding an object

Objects live in `lga1.tf` or `lga2.tf` as `for_each` maps keyed by something
stable (domain, `hostname-rr`, gateway name, network). Each entry carries the
`uuid` that its `import` block uses. To adopt an existing object, read its UUID
from the API, then add both the map entry and the resource attribute if it is a
new field.

Anything the GUI still owns is not imported, so it never shows up as drift.
