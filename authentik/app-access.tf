# By default authentik lets any active user authorize into any application.
# Binding the app-access group to every application flips the default: only
# group members can launch or authorize into the apps below. akadmin stays
# out of the group on purpose; it still has authentik admin without app
# access, so a compromised app session can't come from it.

resource "authentik_group" "app_access" {
  name  = "app-access"
  users = [authentik_user.nlopez.id]
}

locals {
  all_applications = merge(
    authentik_application.gateway,
    {
      karakeep = authentik_application.karakeep
      forgejo  = authentik_application.forgejo
      argocd   = authentik_application.argocd
      immich   = authentik_application.immich
    },
  )
}

resource "authentik_policy_binding" "app_access" {
  for_each = local.all_applications

  target = each.value.id
  group  = authentik_group.app_access.id
  order  = 0
}
