# Kubernetes: agent notes

Read the root [AGENTS.md](../AGENTS.md) first. This covers what is specific to the cluster.

## Where an app goes

- Every app is a directory `apps/<name>/` holding an `application.yaml`: an Argo CD Application
  named `<name>`, deployed to namespace `<name>` (or the namespace a chart needs). The root
  Application (`bootstrap/Application.yaml`) applies every `apps/*/application.yaml`. A directory
  without one is not deployed.
- Plain manifests: copy `_template/plain/` and put the manifests beside `application.yaml`; the
  Application deploys every file in the directory except itself, recursing into subdirectories.
- A Helm chart: copy `_template/helm/`, set the chart's `repoURL`, `chart`, and `targetRevision`,
  put its values in `values.yaml` and any extra manifests in `manifests/`.
- The chart versions the images it ships; Renovate updates the chart. Don't set the tag of one of
  those images in `values.yaml`: it outlives the next chart update. The `Helm pins` check fails a
  PR that does, unless the line says why, `# pin: <reason>` (Immich's chart lags its app, say).
  Images the chart doesn't ship (sidecars, plugins, our own builds) are yours to pin, and Renovate
  updates them.
- The `argocd.argoproj.io/sync-wave` annotation orders a fresh cluster's first sync: `0` networking
  and secrets, `1` storage, `2` everything else. New apps are almost always `2`.
- Deleting an app's directory deletes its Application and every resource it manages, PVCs and CRDs
  included. Deleting a CRD deletes every custom resource of that kind in the cluster. The 1Password
  item behind a `OnePasswordItem` stays; delete it by hand. Leave removing a wave `0` or `1` app,
  or `argocd`, to a human.
- Never delete the `bootstrap` Application by hand: that deletes every app under it.
  `bootstrap/delete-guard.yaml` refuses the delete unless the object carries
  `homelab/allow-delete: "true"`.

## Hostnames and exposure

- Every app has exactly one hostname, a codename from [CODENAMES.md](../CODENAMES.md). Delete the
  name from that list in the same PR; the `check-hostnames` hook fails otherwise, and also if
  another app already routes it.
- Route it with an `HTTPRoute` whose `parentRefs` names the `private` gateway in
  `envoy-gateway-system` (`apps/httpbin/httproute.yaml` is the smallest example). Add a second route
  on the `internet` gateway only if the app should be reachable from the internet.
- external-dns creates the DNS records from the routes. Don't add them in `dns/`.
- Update [EXPOSURE.md](../EXPOSURE.md) whenever you add, remove, or move a route between gateways. `check-hostnames` fails while its table and the routes disagree.

## Secrets and SSO

- Secrets come from 1Password Connect: a `OnePasswordItem` with
  `itemPath: vaults/<vault id>/items/<item>` creates a Secret of the same name. The vault is
  `Automation` (`evjh…`); see [SECRETS.md](../SECRETS.md). Never commit a Secret with data.
- Apps with no SSO of their own sit behind an Envoy Gateway `SecurityPolicy` that sends browsers to
  authentik (`apps/shaarli/gateway-oidc.yaml`). Each needs an OAuth client in
  `authentik/gateway.tf` and a `gateway-oidc-<app>` item in 1Password: a change in two stacks, so
  open the `authentik/` PR first.
- Reloader restarts a workload when its ConfigMaps or Secrets change only if it opts in: annotate the
  Deployment or StatefulSet with `reloader.stakater.com/auto: "true"`, as most apps here do.

## What the PR shows

- The hooks run yamlfmt, `check-yaml`, JSON-schema checks, and kubeconform on changed manifests.
  Add the `# yaml-language-server: $schema=…` line the other manifests carry, so the schema check
  covers yours.
- The `Manifest Diff` comment renders every Application on `main` and on the PR and diffs them.
  Compare it with what you meant to change, as you would a plan. "No changes found" on a PR that
  changes manifests means Argo CD won't see the change (a typo in a path, or an app directory
  with no `application.yaml`).
- A PR that removes an Application, or a PVC, PV, Namespace, CRD, or database (`Cluster`,
  `MariaDB`) from one, counts as a destroy: `Manifest Diff` lists them, and `ci-ok` fails until a
  code owner adds `destroy-approved` (root `AGENTS.md`). Renaming an app counts too.
- Argo CD syncs on merge. `prune` is on and `selfHeal` is off: deleting a manifest deletes the
  resource, and a hand edit in the cluster stays until the next change to that app.
- After a merge, the `Kubernetes sync check` workflow on `main` waits for the Applications the
  change touched to be Synced and Healthy at that commit, and fails with each one's state if they
  aren't within 15 minutes. Check it as you would an apply.

## Stateful apps

- A `PersistentVolumeClaim` binds a fresh volume if its name or namespace changes. Renaming or
  removing an app that has PVCs deletes its old PVCs; on a storage class with
  `reclaimPolicy: Delete` the data goes with them. Leave that to a human.
- `kubernetes/README.md` covers bootstrap order and Velero restores.
