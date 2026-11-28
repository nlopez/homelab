#!/usr/bin/env bash
# One-time bootstrap of the cloud DOKS cluster, run by the operator:
#   1. a ServiceAccount the home Argo CD uses to manage the cluster, saved as
#      an Argo CD cluster item in the Automation vault;
#   2. a 1Password Connect server for the cluster (Automation vault only), its
#      credentials and token saved in Private and installed on the cluster;
#   3. ownership of the Gateway API CRDs DOKS preinstalls, so the Envoy Gateway
#      chart can replace them with the experimental channel (TCPRoute).
# Prints item IDs only, never a token value.
set -euo pipefail

CLUSTER=cloud
AUTOMATION=evjh25ux2mnoufaut6qhvm2pdi
PRIVATE=bamv726zv6zbcfke3cnbwjtnuu
CTX=do-nyc3-$CLUSTER
k() { kubectl --context "$CTX" "$@"; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"

doctl kubernetes cluster kubeconfig save "$CLUSTER" --set-current-context=false >/dev/null
server=$(k config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo "$CLUSTER API: $server"

# 1. Argo CD access
k apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-manager
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: argocd-manager
  namespace: kube-system
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-manager-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: argocd-manager
type: kubernetes.io/service-account-token
EOF
for _ in $(seq 30); do
  token=$(k -n kube-system get secret argocd-manager-token -o jsonpath='{.data.token}' | base64 -d)
  [[ -n "$token" ]] && break
  sleep 1
done
[[ -n "$token" ]] || { echo "token never populated" >&2; exit 1; }
ca=$(k -n kube-system get secret argocd-manager-token -o jsonpath='{.data.ca\.crt}')

config=$(jq -nc --arg t "$token" --arg ca "$ca" '{bearerToken:$t, tlsClientConfig:{insecure:false, caData:$ca}}')
argo_item=$(jq -nc --arg n "$CLUSTER" --arg s "$server" --arg c "$config" \
  '{title:("Argo CD cluster " + $n), category:"SECURE_NOTE", fields:[
     {id:"name", label:"name", type:"STRING", value:$n},
     {id:"server", label:"server", type:"STRING", value:$s},
     {id:"config", label:"config", type:"CONCEALED", value:$c},
     {id:"notesPlain", label:"notesPlain", type:"STRING", purpose:"NOTES",
      value:("Argo CD cluster secret for the " + $n + " DOKS cluster (ServiceAccount kube-system/argocd-manager, cluster-admin). Does not expire; rotate by deleting and recreating the argocd-manager-token Secret there.")}]}' |
  OP_APP_AUTH=1 op item create --vault "$AUTOMATION" --format json | jq -r .id)
unset token config

# 2. 1Password Connect
OP_APP_AUTH=1 op connect server create "$CLUSTER" --vaults "$AUTOMATION" >/dev/null
[[ -s 1password-credentials.json ]] || { echo "no 1password-credentials.json" >&2; exit 1; }
connect_token=$(OP_APP_AUTH=1 op connect token create "$CLUSTER-operator" --server "$CLUSTER" --vault "$AUTOMATION")

creds_item=$(OP_APP_AUTH=1 op document create 1password-credentials.json --vault "$PRIVATE" \
  --title "1Password Connect $CLUSTER credentials" --format json | jq -r .uuid)
token_item=$(jq -nc --arg t "1Password Connect $CLUSTER token" --arg v "$connect_token" \
  '{title:$t, category:"API_CREDENTIAL", fields:[
     {id:"credential", label:"credential", type:"CONCEALED", value:$v}]}' |
  OP_APP_AUTH=1 op item create --vault "$PRIVATE" --format json | jq -r .id)

k create namespace 1password --dry-run=client -o yaml | k apply -f - >/dev/null
k create secret generic op-credentials -n 1password --from-file=1password-credentials.json \
  --dry-run=client -o yaml | k apply -f - >/dev/null
k create secret generic onepassword-token -n 1password --from-literal=token="$connect_token" \
  --dry-run=client -o yaml | k apply -f - >/dev/null
unset connect_token

# 3. Gateway API CRDs
for crd in $(k get crd -o name | grep '\.gateway\.networking\.k8s\.io$'); do
  k annotate --overwrite "$crd" doks.digitalocean.com/install-policy=external >/dev/null
done

echo
echo "argo cluster item (Automation): $argo_item"
echo "connect creds doc (Private):    $creds_item"
echo "connect token item (Private):   $token_item"
k -n 1password get secrets op-credentials onepassword-token -o name
k get crd -o json | jq -r '.items[] | select(.spec.group=="gateway.networking.k8s.io")
  | "\(.metadata.name): \(.metadata.annotations["doks.digitalocean.com/install-policy"] // "DOKS-managed")"'
