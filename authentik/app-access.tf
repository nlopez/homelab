# By default authentik lets any active user authorize into any application.
# Two groups flip that default:
#   users  - can sign in to every app, nothing more
#   admins - everything users can, plus admin carry-through where the app
#            supports it (Forgejo maps the admins group to site admin via
#            ADMIN_GROUP; Immich has no group claim support, so its admin is
#            set in its own UI).
# akadmin is an admins member but not a users member, so a future users-only
# addition (e.g. a household member) never picks up admin rights by accident.
# Argo CD keeps its own argocd-admins group for the rbac role mapping.

data "authentik_user" "akadmin" {
  username = "akadmin"
}

resource "authentik_group" "users" {
  name = "users"
  users = [
    authentik_user.nlopez.id,
  ]
}

resource "authentik_group" "admins" {
  name = "admins"
  users = [
    authentik_user.nlopez.id,
    data.authentik_user.akadmin.id,
  ]
}

# App access requires membership in either group; authentik ORs the bindings.
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

resource "authentik_policy_binding" "app_access_users" {
  for_each = local.all_applications

  target = each.value.uuid
  group  = authentik_group.users.id
  order  = 0
}

resource "authentik_policy_binding" "app_access_admins" {
  for_each = local.all_applications

  target = each.value.uuid
  group  = authentik_group.admins.id
  order  = 0
}
