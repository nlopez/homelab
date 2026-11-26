# Desert Bluffs branding. The asset files live in the repo at
# kubernetes/apps-helm/authentik/branding/ and are served by the authentik
# server pod from the authentik-branding ConfigMap (mounted into
# /web/dist/assets/desert-bluffs/, see the Helm values), so the brand can
# reference them as built-in static assets.

data "authentik_flow" "default_authentication" {
  slug = "default-authentication-flow"
}

resource "authentik_brand" "desert_bluffs" {
  domain = "authentik-default"
  # The default brand cannot be deleted, so take it over instead of
  # creating a second brand that would shadow it.
  default                          = true
  branding_title                   = "Desert Bluffs"
  branding_logo                    = "/static/dist/assets/desert-bluffs/logo-%(theme)s.svg"
  branding_favicon                 = "/static/dist/assets/desert-bluffs/favicon.svg"
  branding_default_flow_background = "/static/dist/assets/desert-bluffs/background.png"

  # Warm night-desert palette; CSS parts are the stable theming API.
  branding_custom_css = <<-EOT
    ak-flow-card::part(card) {
      --ak-dark-theme-background: #2E1A47;
      --ak-dark-theme-surface: #3B2258;
      --ak-dark-theme-border: #FFC72C55;
      --ak-dark-theme-text: #FFF4E0;
      --ak-dark-theme-link: #FFC72C;
      --pf-c-button--m-primary--BackgroundColor: #B3261E;
    }
  EOT

  flow_authentication = data.authentik_flow.default_authentication.id
  flow_invalidation   = data.authentik_flow.default_logout.id
  flow_user_settings  = data.authentik_flow.default_user_settings.id
}

# The default brand exists outside of Tofu; card.id becomes the resource id.
import {
  to = authentik_brand.desert_bluffs
  id = "fdde4285-e2a6-486e-96d3-771a7e5c138a"
}
