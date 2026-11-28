# DigitalOcean

The `cloud` DOKS cluster in `nyc3`, outside the home network, for the services the home cluster
can't host without depending on itself. Forgejo moves here first.

## Cost

| Item | Monthly |
| --- | --- |
| Control plane (not HA) | $0 |
| 3 × `s-2vcpu-4gb` nodes (2 vCPU, 4 GB, 80 GB disk each) | $72 |
| Block storage volumes, at $0.10/GB (e.g. 50 GB for Forgejo and its database) | $5 |
| **Total** | **about $77** |

The cluster is reachable only from the tailnet: its gateway is a Tailscale load balancer, so it
has no DigitalOcean load balancer. The HA control plane adds $40/month, which is over the $100
budget, so `ha = false`. A control-plane outage stops `kubectl` and Argo CD syncs but not running
pods.

## Credentials

The provider reads `DIGITALOCEAN_TOKEN`. Pull-request plans use a read-only token from `ci-pr`
(`secrets.plan.env`); applies on `main` use a token with read and write access to Kubernetes and
VPCs from `ci` (`secrets.env`).

## Upgrades

The cluster takes patch releases in its Sunday maintenance window. A minor upgrade is a change to
`version_prefix` in `kubernetes.tf`, one minor version at a time.

## Bootstrap

Once per cluster, the operator runs `bootstrap-cloud.sh` with doctl, kubectl, and the 1Password
app. It:

- creates the `kube-system/argocd-manager` ServiceAccount the home Argo CD deploys with, and saves
  it as the `Argo CD cluster cloud` item in Automation, which
  `kubernetes/apps/argocd/manifests/cloud-cluster.yaml` turns into Argo CD's cluster secret;
- creates a 1Password Connect server for the cluster (Automation only), keeps its credentials and
  token in Private, and installs them in the cluster's `1password` namespace;
- takes ownership of the Gateway API CRDs DOKS preinstalls (standard channel), with the
  `doks.digitalocean.com/install-policy=external` annotation DOKS documents, so the Envoy Gateway
  chart can install the experimental channel `TCPRoute` that Forgejo SSH uses.

The script reaches the cluster on its public endpoint, which the control plane firewall closes.
On a new cluster, first apply with `control_plane_firewall` disabled (or with your public IPv4
address in `allowed_addresses`), run the script, let Argo CD deploy `cloud-tailscale-operator`,
then move the Argo CD item to the tailnet path: `server`
`https://cloud-k8s-api.argocd.svc.cluster.local` (the egress Service in
`kubernetes/apps/argocd/manifests/cloud-api-egress.yaml`) and, in `config`, `tlsClientConfig`
`{"insecure": false, "serverName": "tailscale-operator-cloud.macaroni-pirate.ts.net"}` with no
`caData`. Then enable the firewall again.

## Reaching the cluster

The public API endpoint accepts no outside addresses. Reach the cluster through the Tailscale
operator's API server proxy instead, which passes your own credentials through:

```sh
doctl kubernetes cluster kubeconfig save cloud --set-current-context=false
kubectl config set-cluster do-nyc3-cloud --server=https://tailscale-operator-cloud.macaroni-pirate.ts.net
kubectl config unset clusters.do-nyc3-cloud.certificate-authority-data
```

The proxy's certificate is a public `ts.net` one, so the DigitalOcean CA comes out. On a machine
that doesn't resolve MagicDNS names, use the proxy's tailnet address and keep the name for TLS:
`--server=https://<tailscale ip -4 tailscale-operator-cloud>
--tls-server-name=tailscale-operator-cloud.macaroni-pirate.ts.net`.

`doctl` and the DigitalOcean API don't go through the cluster's endpoint, so they keep working.
