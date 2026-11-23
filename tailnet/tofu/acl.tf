# The policy file stays in HuJSON so comments and the `tests` block survive.
resource "tailscale_acl" "this" {
  acl = file("${path.module}/../policy.hujson")
}
