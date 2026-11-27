# seadexarr

[seadexarr](https://github.com/bbtufty/seadexarr) scans Sonarr for anime series, matches them against the
[SeaDex](https://releases.moe) database of best-known releases, and can automatically add missing or
upgraded torrents to a torrent client. It runs as a CronJob every 6 hours.

## How it works

On each run, the `config-init` init container renders `/config/config.yml` from the ConfigMap template,
injecting the Sonarr API key, the qBittorrent credentials, and the Discord webhook from their 1Password
Secrets. The `unmonitor-anime` init container then runs (see below), and the main container runs
`seadexarr run single --sonarr`. At startup seadexarr rewrites `config.yml` to the keys of its own sample
config, dropping keys it doesn't know and adding missing ones with their defaults, so a key in
`configmap.yaml` that the running version doesn't have is silently ignored.

The `/config` PVC keeps `cache.json` between runs. For each AniList entry it records the SeaDex update
time and the torrent hashes already added; seadexarr skips an entry until SeaDex updates it.

## Torrent hash filtering

`use_torrent_hash_to_filter: true` makes seadexarr decide by hash: it adds every SeaDex torrent whose hash
is not in `cache.json`, and never looks at the files Sonarr already has. Without it, seadexarr compares
release groups and file sizes against the Sonarr library, and re-adds the SeaDex torrent whenever Sonarr
upgrades or replaces a file, so the two flip-flop.

Hash filtering has its own costs:

- With `interactive: false`, an entry with several SeaDex releases that pass the filters gets all of
  them, and a release with no hash is added again each time SeaDex updates the entry.
- `max_torrents_to_add: 10` caps each 6-hourly run, so a backlog drains at up to 40 torrents a day.

### Keep `cache.json`

Losing `cache.json` makes seadexarr re-add the best release of every anime series in Sonarr, including
the ones already in the library. Sonarr then holds those downloads in its queue (most are "not a
Custom Format upgrade" or fail to match a series) and re-checks them every minute, which reads the
files over NFS continuously. The cache is lost by:

- `seadexarr cache remove`, which the upstream docs suggest after a config change; don't run it here.
- Recreating the `config` PVC, including moving it to another storage class. Copy `cache.json` to the
  new volume before the next run, or suspend the CronJob until it is in place.

If it happens anyway, remove the stuck downloads from Sonarr's queue with "Remove from client".

## Avoiding conflicts with Recyclarr/TRaSH

Sonarr upgrades files by TRaSH custom format score, which can replace a SeaDex release with one SeaDex
doesn't recommend. The `unmonitor-anime` init container (`unmonitor-anime.py` in `configmap.yaml`)
prevents this by unmonitoring every anime episode that already has a file on each run. Series stay
monitored, so Sonarr still grabs new episodes; they are unmonitored on the next run once they have a
file. Keep `sonarr_ignore_unmonitored: false`: with it on, seadexarr would skip series whose episodes
are all unmonitored.

## Running a one-off job

To trigger a run immediately without waiting for the next scheduled time:

```bash
kubectl create job seadexarr-manual --from=cronjob/seadexarr -n seadexarr
```

Watch it run:

```bash
kubectl logs -n seadexarr -l job-name=seadexarr-manual -f --prefix
```

Clean up when done:

```bash
kubectl delete job seadexarr-manual -n seadexarr
```

## Configuration

Non-secret config is in `configmap.yaml`. The full set of available options is documented in the
[seadexarr config docs](https://github.com/bbtufty/seadexarr?tab=readme-ov-file#config).

Notable settings:

| Setting | Value | Notes |
|---|---|---|
| `sonarr_url` | `http://sonarr.sonarr.svc.cluster.local` | In-cluster service |
| `sonarr_torrent_category` | `sonarr-anime` | qBittorrent category Sonarr imports from |
| `torrent_tags` | `seadexarr` | Marks the torrents seadexarr added |
| `use_torrent_hash_to_filter` | `true` | See [Torrent hash filtering](#torrent-hash-filtering) |
| `public_only` | `true` | Public trackers only (Nyaa, AnimeTosho, RuTracker) |
| `prefer_dual_audio` | `true` | Prefer dual-audio releases |
| `want_best` | `true` | Prefer SeaDex "best" tagged releases |
| `interactive` | `false` | Required for unattended CronJob use |

To add Radarr, set the `radarr_*` fields in `configmap.yaml`, add its API key to 1Password, and inject
it in `config-init` the way the Sonarr key is.

## Updating the image

```bash
IMAGE=ghcr.io/bbtufty/seadexarr
skopeo --override-os linux list-tags "docker://${IMAGE}" | jq -r '.Tags[]' | sort -V | tail -n5
```

Then update the `image:` tag in `cronjob.yaml` for the `config-init`, `unmonitor-anime`, and `seadexarr`
containers. Check the new version's `seadexarr/modules/config_sample.yml` for renamed or removed keys,
since unknown keys in `configmap.yaml` are dropped without a warning.
