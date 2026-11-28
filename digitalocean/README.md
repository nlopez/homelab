# DigitalOcean

The `kernel` DOKS cluster in `nyc3`, outside the home network, for the services the home cluster
can't host without depending on itself. Forgejo moves here first.

## Cost

| Item | Monthly |
| --- | --- |
| Control plane (not HA) | $0 |
| 3 × `s-2vcpu-4gb` nodes (2 vCPU, 4 GB, 80 GB disk each) | $72 |
| One load balancer, once an ingress controller asks for one | $12 |
| Block storage volumes, at $0.10/GB (e.g. 50 GB for Forgejo and its database) | $5 |
| **Total** | **about $89** |

The HA control plane adds $40/month, which is over the $100 budget, so `ha = false`. A
control-plane outage stops `kubectl` and Argo CD syncs but not running pods.

## Credentials

The provider reads `DIGITALOCEAN_TOKEN`. Pull-request plans use a read-only token from `ci-pr`
(`secrets.plan.env`); applies on `main` use a token with read and write access to Kubernetes and
VPCs from `ci` (`secrets.env`).

## Upgrades

The cluster takes patch releases in its Sunday maintenance window. A minor upgrade is a change to
`version_prefix` in `kubernetes.tf`, one minor version at a time.

## Bootstrap

Once per cluster, the operator runs `bootstrap-kernel.sh` with doctl, kubectl, and the 1Password
app. It creates the `kube-system/argocd-manager` ServiceAccount the home Argo CD deploys with and
saves it as the `Argo CD cluster kernel` item in Automation, which
`kubernetes/apps/argocd/manifests/kernel-cluster.yaml` turns into Argo CD's cluster secret. It
also creates a 1Password Connect server for kernel (Automation only), keeps its credentials and
token in Private, and installs them in kernel's `1password` namespace.

## Reaching the cluster

```sh
doctl kubernetes cluster kubeconfig save kernel
```
