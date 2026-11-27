#!/usr/bin/env bash
# Lists what a pull request's Kubernetes changes delete, one line per item.
# Prints nothing when nothing is deleted.
#
# Reads the per-Application manifests argocd-diff-preview writes with
# --output-app-manifests: <output>/base/<app>.yaml (main) and
# <output>/target/<app>.yaml (the PR). Counts as a delete:
# - an Application on main that the PR no longer renders. Its finalizer makes
#   Argo CD delete everything it runs, PVCs and CRDs included, even when the
#   same resources move to another Application.
# - a resource the PR stops rendering in an Application on both sides, when
#   deleting it loses data: a PVC, PV, Namespace, CRD (and with it every object
#   of that kind), or a database whose operator keeps it in PVCs.
#
# Needs mikefarah yq v4. Run by .github/workflows/kubernetes-argocd-diff.yaml;
# ci-ok then needs the destroy-approved label.
#
# Usage: manifest-destroys.sh <output folder>
set -euo pipefail
export LC_ALL=C

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <output folder>" >&2
  exit 2
fi
out="$1"

# One "group|kind|namespace|name" line per object in a rendered manifest.
objects() {
  yq -N 'select(.kind != null)
    | [(.apiVersion // "" | sub("/?[^/]+$"; "")), .kind,
       (.metadata.namespace // ""), (.metadata.name // "")]
    | join("|")' "$1" | sort -u
}

[ -d "${out}/base" ] || exit 0
# Parsed to files rather than in <(...), so a manifest yq can't read fails the
# job instead of listing nothing.
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
for base in "${out}"/base/*.yaml; do
  [ -e "${base}" ] || continue
  app="$(basename "${base}" .yaml)"
  target="${out}/target/${app}.yaml"
  if [ ! -e "${target}" ]; then
    echo "Application ${app} (deletes everything it runs)"
    continue
  fi
  objects "${base}" >"${work}/base"
  objects "${target}" >"${work}/target"
  comm -23 "${work}/base" "${work}/target" |
    while IFS='|' read -r group kind namespace name; do
      case "${group}|${kind}" in
        "|PersistentVolumeClaim" | "|PersistentVolume" | "|Namespace" | \
          "apiextensions.k8s.io|CustomResourceDefinition" | \
          "postgresql.cnpg.io|Cluster" | "k8s.mariadb.com|MariaDB")
          echo "${kind} ${namespace:+${namespace}/}${name} in ${app}"
          ;;
      esac
    done
done
