# Kubernetes: agent notes

Read the root [AGENTS.md](../AGENTS.md) first. This covers what is specific to the cluster.

## Where an app goes

- `apps/<name>/`: plain manifests. The `apps` ApplicationSet (`bootstrap/apps.yaml`) turns every
  directory here into an Application named `<name>`, deployed to namespace `<name>`, recursing into
  subdirectories. Adding the directory is all it takes. `apps/<name>/overlays/<o>/` becomes
  Application `<name>-<o>`, also in namespace `<name>`. Deleting the directory deletes the
  Application and every resource it manages, PVCs included. The 1Password item behind a
  `OnePasswordItem` stays; delete it by hand.
- `apps-helm/<name>/`: a Helm chart. Add an entry to the `list` generator in
  `bootstrap/apps-helm.yaml` (`name`, `tier`, `repoURL`, `chart`, `targetRevision`, `namespace`),
  then put the chart's values in `apps-helm/<name>/values.yaml` and any extra manifests in
  `apps-helm/<name>/manifests/`. Start from `apps-helm/_template/`. `tier` is one of
  `network-and-secrets`, `storage`, or `platform`; new apps are almost always `platform`.
- A directory under `apps-helm/` with no `bootstrap/apps-helm.yaml` entry is not deployed.
- Removing an entry from `bootstrap/apps-helm.yaml` deletes its Application and every resource it
  manages, PVCs and CRDs included. Deleting a CRD deletes every custom resource of that kind in the
  cluster. Leave removing a `network-and-secrets` or `storage` entry, or `argocd`, to a human.

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
  changes manifests means Argo CD won't see the change (a typo in a path, or an `apps-helm`
  directory with no ApplicationSet entry).
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
  removing an app that has PVCs, or moving it between `apps/` and `apps-helm/`,
  deletes its old PVCs; on a storage class with `reclaimPolicy: Delete` the data goes with them.
  Leave that to a human.
- `kubernetes/README.md` covers bootstrap order and Velero restores.
