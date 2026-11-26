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

The `Arr` workflow (`.github/workflows/arr.yaml`) plans on pull requests and applies on `main`,
from a runner on the tailnet (`tag:ci` reaches the private gateway on 443). The apply reads the
CI copies of the six secrets from the `ci` vault (`secrets.env`).

Break-glass, an operator applies from a machine on the LAN or tailnet, since the app hostnames
only resolve there. The API routes skip the gateway's OIDC policy, so the app API keys are enough.

```bash
cd arr
tofu init
tofu plan
AWS_PROFILE=admin tofu apply
```

`scripts/plan arr` plans as a pull request does, but it can't mint the OIDC token: set
`TF_VAR_sonarr_api_key` and `TF_VAR_radarr_api_key` to the real keys first.

The apps return secrets masked, so tofu cannot detect drift in them. Every secret comes from
1Password through `secrets.env`, and an apply writes those values to the apps.

## Pull-request plans

A pull-request plan holds no Sonarr or Radarr key. It passes the job's GitHub Actions OIDC token as
both API keys, with the app's hostname as the token's audience. The `sonarr-api-ci` and
`radarr-api-ci` routes (`kubernetes/apps/{sonarr,radarr}/httproute-ci.yaml`) accept only `GET`s
under `/api` carrying a valid token from this repository, and replace the token with the real key.
Any other request carrying the token reaches the app unchanged and fails its key check.

The other four secrets (qBittorrent password, SABnzbd and NZBgeek keys, Plex token) are compared
against state, so the plan passes placeholders and excludes the eight resources that use them:

```
-exclude=sonarr_download_client_qbittorrent.nas2
-exclude=sonarr_download_client_sabnzbd.sabnzbd
-exclude=sonarr_indexer_newznab.nzbgeek
-exclude=sonarr_notification_plex.plex
-exclude=radarr_download_client_qbittorrent.nas2
-exclude=radarr_download_client_sabnzbd.sabnzbd
-exclude=radarr_indexer_newznab.nzbgeek
-exclude=radarr_notification_plex.plex
```

A change to those resources is first planned by the apply on `main`.
