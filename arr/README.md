# Sonarr and Radarr

Sonarr (`jolthog`) and Radarr (`dumud`) settings, managed with the
[`devopsarr/sonarr`](https://registry.terraform.io/providers/devopsarr/sonarr) and
[`devopsarr/radarr`](https://registry.terraform.io/providers/devopsarr/radarr) providers.

## Managed here

- Download clients (qBittorrent, SABnzbd)
- Indexers (NZBgeek; AnimeTosho and Nyaa for series tagged `anime`)
- Root folders, tags, and the default delay profile
- Media management settings
- Sonarr episode naming
- Plex notifications

## Not managed here

- Quality profiles, custom formats, quality definitions, and Radarr movie naming: Recyclarr syncs
  these from TRaSH Guides (`kubernetes/apps/recyclarr`). Managing them here would fight it.
- Host settings (port, auth, API key): the Deployment sets them through environment variables.
- Metadata consumers: all are disabled, which is the default.
- Series and movies.

## Applying

Operators apply from a machine on the LAN or tailnet, since the app hostnames only resolve there.
The API routes skip the gateway's OIDC policy, so the app API keys are enough.

```bash
cd arr
tofu init
tofu plan
AWS_PROFILE=admin tofu apply
```

The apps return secrets masked, so tofu cannot detect drift in them. Every secret comes from
1Password through `secrets.env`, and an apply writes those values to the apps.
