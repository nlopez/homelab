# Internet exposure

What each homelab service exposes, and where. Update this table when you add, remove, or move a
route between the `internet` and `private` gateways.

## Services

| Service | Namespace | Internet | Private (LAN + tailnet) | Notes |
| --- | --- | --- | --- | --- |
| Argo CD | `argocd` | `flopie.desertbluffs.com` | `argocd`, `flopie` | HTTP and gRPC routes on the private gateway; HTTP only on the internet gateway. |
| Atuin | `atuin` | `pyrin.desertbluffs.com` | `atuin`, `pyrin` | |
| Forgejo | `forgejo` | `dazzi.desertbluffs.com` | `git`, `dazzi`; SSH `git.desertbluffs.com:22` | Git SSH runs only on the private gateway's TCP listener; Cloudflare can't proxy it. HTTPS pushes over the internet are subject to Cloudflare's request body limit (100 MB on Free and Pro). |
| Immich | `immich` | `nox.desertbluffs.com` | `immich`, `nox` | |
| Jellyfin | `jellyfin` | `wixen.desertbluffs.com` | `jellyfin`, `wixen` | |
| Obsidian LiveSync | `obsidian-livesync` | `lifmunk.desertbluffs.com` | `livesync`, `lifmunk` | |
| Plex | `pms` | `vixy.desertbluffs.com` | `plex`, `vixy`; LoadBalancer `10.43.64.2:32400` | |
| Shaarli | `shaarli` | `gumoss.desertbluffs.com` | `shaarli`, `gumoss` | |
| Timekeeper (ash) | `timekeeper-ash` | `ash.kamotimestamps.com` | — | Internet only. |
| Timekeeper (oak) | `timekeeper-oak` | `oak.kamotimestamps.com` | — | Internet only. |
| Apex redirect | `envoy-gateway-system` | `desertbluffs.com`, `www` | `desertbluffs.com`, `www` | Redirect only; no backend. |
| Engram | `engram` | — | `engram`, `mau` | |
| Goldpinger | `goldpinger` | — | `goldpinger`, `fuack` | |
| Homepage | `homepage` | — | `home` | |
| httpbin | `httpbin` | — | `httpbin`, `swee` | |
| Palworld | `palworld` | — | Live map `palmap`, `rooby`; game UDP `10.43.64.10:8211` | |
| Palworld (modded) | `palworld-modded` | — | Game UDP `10.43.64.10:8311` | |
| Radarr | `radarr` | — | `radarr`, `dumud` | |
| Seafile | `seafile` | — | `seafile` | |
| Sonarr | `sonarr` | — | `sonarr`, `jolthog` | |
| Technitium | `technitium` | — | Web `balmy-cactus.desertbluffs.com`, `balmy-cactus.radoncanyon.com`; DNS `10.43.64.53`; tailnet `technitium` | |

Hostnames in the Private column are under `desertbluffs.com` unless written in full. A public
service's codename (pick new ones from [CODENAMES.md](CODENAMES.md)) is also on its private
route, so the same URL resolves to the private gateway from the LAN and the tailnet.

Unmatched hostnames under `*.desertbluffs.com` (both gateways) and `*.radoncanyon.com` (private
gateway) get a catch-all `418` route (`kubernetes/apps-helm/envoy-gateway/manifests/unmatched-teapot.yaml`).

## Paths

### Internet

1. Cloudflare serves the public DNS record, proxied (`external-dns.kubernetes.io/cloudflare-proxied: "true"`).
   The `external-dns` instance only publishes routes attached to the `internet` gateway.
2. Cloudflare connects to the origin at `lga1.desertbluffs.com`, the home WAN address (managed
   outside this repo; the `dns/` tofu config does not manage it).
3. The router sends that traffic to the `internet` gateway at `10.43.64.20`.
4. The gateway accepts only TLS clients that present a Cloudflare authenticated origin pull
   certificate (`tls-settings-internet` in `tls-settings-policy.yaml`), so connections that
   bypass Cloudflare fail the TLS handshake.

### Private

- The `private` gateway at `10.43.64.10` and `fd54:571b:560a:4364::10` is advertised to the LAN
  router (`192.168.222.1`) over BGP from Cilium.
- `external-dns-technitium` publishes its routes to Technitium for LAN DNS, as A and AAAA records.
- Technitium serves `desertbluffs.com` as a Conditional Forwarder zone: names it holds resolve to
  the private gateway, and every other name is forwarded to public DNS (mail records, `lga1`).
  Every name it holds needs both an A and an AAAA record; an AAAA query for a name with only an A
  record is forwarded and returns Cloudflare's public address. external-dns can't own the apex, so
  the apex AAAA is a static record in Technitium.
- The Tailscale operator exposes the private gateway and Technitium DNS on the tailnet through the
  `heimdall` proxy group.

## Not tracked here

- Router port forwards other than the one implied by the internet path, for example whether Plex's
  `32400` is forwarded from the WAN.
- Tailscale Funnel. `tailnet/policy.hujson` grants the `funnel` attribute to `autogroup:member`
  and `tag:admin`, but no Funnel configuration lives in this repo.
- Hosts outside the cluster, such as the Technitium proxy on `odroid.lga1.radoncanyon.com`.
