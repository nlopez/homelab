#!/bin/sh
# Renders the private-zone record snapshot from Gateway API routes and
# pushes it to the OPNsense gateways, which apply it as Unbound local
# data. One full snapshot per push: gateways converge even after gaps.
set -eu

ZONE='desertbluffs.com'
TTL=60
GATEWAY_NAME=private
GATEWAY_NAMESPACE=envoy-gateway-system
: "${DNS_SYNC_TARGETS:=100.83.144.88 100.86.37.97}"

snap=$(mktemp)
addrs=$(mktemp)
trap 'rm -f "$snap" "$addrs"' EXIT

kubectl get gateway -n "$GATEWAY_NAMESPACE" "$GATEWAY_NAME" -o json |
  jq -r '.status.addresses[]?.value' > "$addrs"
if [ ! -s "$addrs" ]; then
  echo "no addresses on gateway $GATEWAY_NAMESPACE/$GATEWAY_NAME" >&2
  exit 1
fi

# Hostnames from routes attached to the private gateway, private zone
# only; wildcards stay out of the local data.
kubectl get httproute,grpcroute,tcproute,udproute -A -o json |
  jq -r --arg gw "$GATEWAY_NAME" --arg zone "$ZONE" '
    .items[]
    | select(.spec.parentRefs[]? | .name == $gw and .namespace == null)
    | [.spec.hostnames[]?]
    | map(select(. == $zone or endswith("." + $zone)))
    | unique[]
    | select(startswith("*") | not)
  ' |
  sort -u |
  while IFS= read -r host; do
    while IFS= read -r addr; do
      case "$addr" in
        *:*) printf '%s. %s IN AAAA %s\n' "$host" "$TTL" "$addr" >> "$snap" ;;
        *) printf '%s. %s IN A %s\n' "$host" "$TTL" "$addr" >> "$snap" ;;
      esac
    done < "$addrs"
  done

sort -o "$snap" "$snap"
record_count=$(wc -l < "$snap" | tr -d ' ')
# A bad API response or filter change must not erase DNS on both sites.
# The receiver's maximum record count guards the opposite direction.
if [ "$record_count" -lt 20 ]; then
  echo "refusing unexpectedly small snapshot: $record_count records" >&2
  exit 1
fi
echo "snapshot: $record_count records"

rc=0
for gw in $DNS_SYNC_TARGETS; do
  if ssh -o LogLevel=ERROR -o ConnectTimeout=8 \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "dns-sync@$gw" sudo /usr/local/sbin/dns-sync-apply < "$snap"; then
    echo "$gw: ok"
  else
    echo "$gw: push failed" >&2
    rc=1
  fi
done
exit "$rc"
