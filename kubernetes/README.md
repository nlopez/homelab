# k8s
Kubernetes gitops for my personal infra

## Notes
### kubeadm

```bash
sudo kubeadm init --config kubeadm-init.conf --upload-certs
```

Run the control plane join command on additional nodes.

### Untaint master/control-plane
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### Approve CSRs
This is [necessary](https://github.com/kubernetes/kubeadm/issues/591#issuecomment-1257061416) because we're using `serverTLSBootstrap: true` in kubeadm.

```bash
for csr in $(kubectl get csr --sort-by=.metadata.creationTimestamp -o name); do kubectl certificate approve $csr; done
```

### CNI: Cilium
```bash
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.19.2 --namespace kube-system --values apps/cilium/values.yaml
cilium status --wait
kubectl apply --server-side -Rf apps/cilium/manifests
```

### Wait for coredns/control plane running
```bash
kubectl get pod --all-namespaces -owide --watch
```

### ArgoCD
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install --create-namespace --namespace argocd --version 9.0.1 argocd argo/argo-cd --values apps/argocd/values.yaml
argocd login --core
argocd admin initial-password -n argocd
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
export ARGOCD_SVC_IP="$(kubectl get svc -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[*].spec.clusterIP}')"
argocd login "$ARGOCD_SVC_IP" --insecure --username admin
argocd account update-password
```

### 1Password Connect
```bash
kubectl create namespace 1password --dry-run=client -o yaml | kubectl apply -f -
op read 'op://bamv726zv6zbcfke3cnbwjtnuu/lkbaozihk6xqhrtlcq6vycu2ua/1password-credentials.json' --no-newline > 1password-credentials.json
kubectl create secret generic op-credentials -n 1password --from-file=1password-credentials.json --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic onepassword-token -n 1password --from-literal=token="$(op read op://bamv726zv6zbcfke3cnbwjtnuu/lshy7xejhopza2xq6qpjqlcw5y/credential --no-newline)" --dry-run=client -o yaml | kubectl apply -f -
```

### Disaster recovery: restoring PV/PVC data after a re-init

`kubeadm init` wipes etcd, so every `PersistentVolume`/`PersistentVolumeClaim` object is lost —
but the underlying data on TrueNAS (`nas1.lga1.radoncanyon.com`) is untouched, since it's external
to the cluster. Velero (`apps/velero`) tracks CSI snapshots of the stateful namespaces in
DigitalOcean Spaces, which also survives a re-init, so restoring is normally just `velero restore
create` rather than hand-reconstructing PV/PVC manifests from TrueNAS.

**Before a planned re-init**, take a fresh on-demand backup so restore doesn't depend on schedule
timing:
```bash
velero backup create cluster-pre-reinit-$(date +%Y%m%d) \
  --include-namespaces atuin,harbor,jellyfin,obsidian-livesync,palworld,palworld-modded,pms,radarr,seadexarr,seafile,sonarr,warp
```
For CNPG-managed namespaces (`atuin`, `harbor`), hibernate the `Cluster` first
(`cnpg.io/hibernation: "on"` annotation) so the snapshot is transactionally consistent rather than
crash-consistent — see commit `4bd437f7` for the full hibernate/restore dance.

**After re-init**, restore *before* the stateful apps sync — if Argo CD syncs a stateful app's
PVC manifest first, that PVC binds to a brand-new empty volume and permanently orphans the real
data. So apply the infrastructure Applications by hand and hold the root back:
1. Apply the sync-wave 0 and 1 Applications (networking, secrets, storage, Velero, CloudNativePG)
   and `external-snapshotter`, and wait for them to sync healthy — CSI snapshot restore and CNPG
   `Cluster` restore depend on them:
   ```bash
   for f in $(grep -l "sync-wave: '[01]'" apps/*/application.yaml) apps/external-snapshotter/application.yaml; do
     kubectl apply --server-side -f "$f"
   done
   ```
2. Wait for the `BackupStorageLocation` to report `Available`: `velero backup-location get`.
3. `velero restore create --from-backup <name>` for each namespace that needs its data back.
4. Only then `kubectl apply --server-side -f bootstrap/Application.yaml`. The root adopts the
   Applications already applied and creates the rest, which adopt the already-restored PVCs
   instead of creating fresh ones.

If a namespace isn't covered by any Velero backup (new app, or backup window missed), fall back
to a manual recovery: reclaim the orphaned
TrueNAS volume as a static PV/PVC, snapshot it, then re-expose that snapshot as the app's PVC
`dataSource`.

### Bootstrap the root Application

Apply the root Application. It manages itself, the delete guard in `bootstrap/`, and one
Application per `apps/<name>/application.yaml`:
```bash
kubectl apply --server-side -f bootstrap/Application.yaml
```
Each child Application's `argocd.argoproj.io/sync-wave` annotation orders the first sync, and the
root waits for each wave to be Healthy before the next: networking and secrets (`0`), then storage
(`1`), then everything else (`2`). So workloads (CNPG `Cluster`s, PVCs) don't race against
storage, secrets, or networking still coming up.

### Renovate

Run renovate locally against the working tree (no GitHub token required):

```bash
docker run --rm \
  -v $(pwd):/usr/src/app \
  -e RENOVATE_PLATFORM=local \
  -e LOG_LEVEL=debug \
  ghcr.io/renovatebot/renovate \
  --dry-run=full
```

To open actual PRs on GitHub, set `RENOVATE_TOKEN` to a GitHub PAT with `repo` scope and drop `--dry-run=full`:

```bash
RENOVATE_TOKEN=<github-pat> docker run --rm \
  -e RENOVATE_TOKEN \
  -e LOG_LEVEL=debug \
  ghcr.io/renovatebot/renovate \
  nlopez/homelab/kubernetes
```

## Thanks
*  Lots of inspiration drawn from [nicolerenee/k8s-state](https://github.com/nicolerenee/k8s-state).
