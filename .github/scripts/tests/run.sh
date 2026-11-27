#!/usr/bin/env bash
# Tests for the scripts CI runs (.github/scripts, scripts/). Plain bash, jq,
# git, and Python with PyYAML; no network. Run from anywhere:
#
#   .github/scripts/tests/run.sh
#
# Run by .github/workflows/script-tests.yaml on every pull request.
# Fixtures hold literal backticks and $ in single quotes on purpose.
# shellcheck disable=SC2016,SC2001
set -uo pipefail

# Built from parts, so this file never names an unused codename's hostname,
# which check-hostnames itself would flag.
domain=desertbluffs.com

repo="$(cd "$(dirname "$0")/../../.." && pwd)"
scripts="${repo}/.github/scripts"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
failures=0

pass() { echo "ok   $1"; }
fail() { echo "FAIL $1"; failures=$((failures + 1)); }
# expect <name> <expected> <actual>
expect() {
  if [ "$2" = "$3" ]; then pass "$1"; else
    fail "$1"
    diff <(echo "$2") <(echo "$3") | sed 's/^/     /'
  fi
}
# contains <name> <needle> <haystack>
contains() {
  if grep -qF -- "$2" <<<"$3"; then pass "$1"; else
    fail "$1: missing '$2'"
    sed 's/^/     /' <<<"$3"
  fi
}

### plan-destroys.sh

out="$(cat <<'JSON' | "${scripts}/plan-destroys.sh"
{"resource_changes": [
  {"address": "a.kept", "change": {"actions": ["no-op"]}},
  {"address": "a.updated", "change": {"actions": ["update"]}},
  {"address": "aws_iam_user.x", "change": {"actions": ["delete", "create"]}},
  {"address": "b.created_first", "change": {"actions": ["create", "delete"]}},
  {"address": "c.gone", "change": {"actions": ["delete"]}}
]}
JSON
)"
expect "plan-destroys lists deletes and both kinds of replace" \
"aws_iam_user.x (delete then create)
b.created_first (create then delete)
c.gone (delete)" "${out}"
expect "plan-destroys prints nothing for a plan with no resource changes" "" \
  "$(echo '{"format_version": "1.2"}' | "${scripts}/plan-destroys.sh")"
expect "plan-destroys skips a replaced terraform_data trigger" "" \
  "$(echo '{"resource_changes": [{"address": "terraform_data.refresh", "type": "terraform_data",
    "change": {"actions": ["delete", "create"]}}]}' | "${scripts}/plan-destroys.sh")"

### manifest-destroys.sh

md="${work}/manifest-destroys"
mkdir -p "${md}/base" "${md}/target"
cat >"${md}/base/sonarr.yaml" <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: config
  namespace: sonarr
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cache
  namespace: sonarr
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarr
  namespace: sonarr
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: sonarr-database
  namespace: sonarr
YAML
cat >"${md}/target/sonarr.yaml" <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: config
  namespace: sonarr
YAML
cat >"${md}/base/cnpg.yaml" <<'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: clusters.postgresql.cnpg.io
YAML
printf '' >"${md}/target/cnpg.yaml"
cat >"${md}/base/litexiv.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: litexiv
YAML
cat >"${md}/base/httpbin.yaml" <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: httpbin
YAML
printf '' >"${md}/target/httpbin.yaml"
cp "${md}/base/sonarr.yaml" "${md}/target/new.yaml"
expect "manifest-destroys lists removed apps and removed stateful resources" \
"CustomResourceDefinition clusters.postgresql.cnpg.io in cnpg
Application litexiv (deletes everything it runs)
Cluster sonarr/sonarr-database in sonarr
PersistentVolumeClaim sonarr/cache in sonarr" "$("${scripts}/manifest-destroys.sh" "${md}")"
expect "manifest-destroys prints nothing when only stateless resources go" "" \
  "$(mkdir -p "${md}2/base" "${md}2/target" && cp "${md}/base/httpbin.yaml" "${md}2/base/" &&
    printf '' >"${md}2/target/httpbin.yaml" && "${scripts}/manifest-destroys.sh" "${md}2")"
expect "manifest-destroys prints nothing without rendered manifests" "" \
  "$("${scripts}/manifest-destroys.sh" "${work}/no-such-output")"
mkdir -p "${md}3/base" "${md}3/target"
printf 'kind: [unclosed\n' >"${md}3/base/broken.yaml"
cp "${md}3/base/broken.yaml" "${md}3/target/"
if "${scripts}/manifest-destroys.sh" "${md}3" >/dev/null 2>&1; then
  fail "manifest-destroys fails on a manifest it can't parse"
else
  pass "manifest-destroys fails on a manifest it can't parse"
fi

### plan-diff.sh

out="$(printf '%s\n' '  ~ resource "a" "b" {' '      ~ x = 1 -> 2' '      + y = 3' '      - z = 4' \
  '-/+ resource "c" "d" {' '      id = "q"' 'Plan: 1 to add, 1 to change, 1 to destroy.' \
  | "${scripts}/plan-diff.sh")"
expect "plan-diff moves action markers to column 0 for diff highlighting" \
'```diff
!   resource "a" "b" {
!       x = 1 -> 2
+       y = 3
-       z = 4
!   resource "c" "d" {
      id = "q"
Plan: 1 to add, 1 to change, 1 to destroy.
```' "${out}"

### app-token.sh

openssl genrsa -out "${work}/app.pem" 2048 2>/dev/null
openssl rsa -in "${work}/app.pem" -pubout -out "${work}/app.pub" 2>/dev/null
token="$("${scripts}/app-token.sh" jwt 5930324 "${work}/app.pem")"
IFS=. read -r jwt_header jwt_payload jwt_signature <<<"${token}"
b64url_decode() { local s="${1//-/+}"; s="${s//_//}"; while [ $(( ${#s} % 4 )) -ne 0 ]; do s="${s}="; done; openssl base64 -d -A <<<"${s}"; }
expect "app-token jwt has an RS256 header" '{"alg":"RS256","typ":"JWT"}' "$(b64url_decode "${jwt_header}")"
claims="$(b64url_decode "${jwt_payload}")"
expect "app-token jwt names the app as issuer" "5930324" "$(jq -r .iss <<<"${claims}")"
expect "app-token jwt lasts ten minutes, backdated one" "600" "$(jq '.exp - .iat' <<<"${claims}")"
b64url_decode "${jwt_signature}" > "${work}/jwt.sig"
if printf '%s.%s' "${jwt_header}" "${jwt_payload}" |
  openssl dgst -sha256 -verify "${work}/app.pub" -signature "${work}/jwt.sig" >/dev/null 2>&1; then
  pass "app-token jwt signature verifies with the app's public key"
else
  fail "app-token jwt signature verifies with the app's public key"
fi

### load-plan-credentials.sh

mkdir -p "${work}/bin"
cat > "${work}/bin/op" <<'SH'
#!/usr/bin/env bash
# Stand-in for `op read --no-newline <ref>`: returns "secret-of-<field>".
[ "$1" = read ] && [ "$2" = --no-newline ] || exit 64
printf 'secret-of-%s' "${3##*/}"
SH
chmod +x "${work}/bin/op"
cat > "${work}/plan.env" <<'ENV'
# A comment, and a blank line, are skipped.

TF_VAR_api_key=op://vault/item/api-key
PLAIN=just-a-value
JSON_VALUE=["a:read", "b:read"]
ENV
: > "${work}/github_env"
masks="$(PATH="${work}/bin:${PATH}" GITHUB_ENV="${work}/github_env" \
  "${scripts}/load-plan-credentials.sh" "${work}/plan.env")"
expect "load-plan-credentials masks every value" \
"::add-mask::secret-of-api-key
::add-mask::just-a-value
::add-mask::[\"a:read\", \"b:read\"]" "${masks}"
# Read the exported variables back the way the runner does.
exported="$(python3 - "${work}/github_env" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
for name, delim in re.findall(r"^([A-Za-z_][A-Za-z0-9_]*)<<(EOF_[0-9a-f]{16})$", text, re.M):
    value = re.search(re.escape(f"{name}<<{delim}") + r"\n(.*?)\n" + re.escape(delim), text, re.S).group(1)
    print(f"{name}={value}")
PY
)"
expect "load-plan-credentials exports resolved and plain values" \
"TF_VAR_api_key=secret-of-api-key
PLAIN=just-a-value
JSON_VALUE=[\"a:read\", \"b:read\"]" "${exported}"

### ci-summary.sh

head=aaaa1111bbbb2222cccc3333dddd4444eeee5555
cat > "${work}/annotations.json" <<'JSON'
[
  {"check": "dns / Plan", "url": "u/dns", "title": "plan-result", "message": "{\"stack\":\"DNS\",\"outcome\":\"success\",\"summary\":\"No changes. Your infrastructure matches the configuration.\"}"},
  {"check": "state-bucket / Plan", "url": "u/sb", "title": "plan-result", "message": "{\"stack\":\"State bucket\",\"outcome\":\"success\",\"summary\":\"Plan: 1 to add, 0 to change, 1 to destroy.\"}"},
  {"check": "state-bucket / Plan", "url": "u/sb", "title": "plan-destroys", "message": "State bucket: aws_iam_user.x (delete then create)"},
  {"check": "datadog / Plan", "url": "u/dd", "title": "plan-result", "message": "{\"stack\":\"Datadog\",\"outcome\":\"failure\",\"summary\":\"\"}"}
]
JSON
cat > "${work}/comments.json" <<'JSON'
[{"html_url": "u/k8s", "body": "<!-- manifest-diff -->\n## Argo CD Diff Preview\n\nNo changes found"}]
JSON
cat > "${work}/runs.json" <<'JSON'
[
  {"name": "ci-ok", "status": "in_progress", "conclusion": null},
  {"name": "Protected gate", "status": "in_progress", "conclusion": null},
  {"name": "pre-commit", "status": "completed", "conclusion": "success"},
  {"name": "datadog / Plan", "status": "completed", "conclusion": "failure"},
  {"name": "dns / Apply", "status": "completed", "conclusion": "skipped"},
  {"name": "Manifest Diff", "status": "in_progress", "conclusion": null}
]
JSON
expect "ci-summary renders the whole comment" \
'<!-- ci-summary -->
### ❌ ci-ok failure on `aaaa1111`

**Checks not passing:**

- `datadog / Plan`: failure
- `Manifest Diff`: in_progress

| Stack | Plan | Destroys |
| --- | --- | --- |
| [DNS](u/dns) | No changes | no |
| [Datadog](u/dd) | ❌ plan failure | no |
| [State bucket](u/sb) | 1 to add, 0 to change, 1 to destroy | ⚠️ yes |

Each stack links to its plan job; the full plan is in that job'"'"'s summary.

**Kubernetes manifest diff:** No changes' \
  "$("${scripts}/ci-summary.sh" "${work}/runs.json" "${work}/annotations.json" "${work}/comments.json" "${head}" failure)"
echo '[]' > "${work}/empty.json"
expect "ci-summary says when no stack planned" \
'<!-- ci-summary -->
### ✅ ci-ok passed on `aaaa1111`

No OpenTofu stack planned on this commit.' \
  "$("${scripts}/ci-summary.sh" "${work}/empty.json" "${work}/empty.json" "${work}/empty.json" "${head}" success)"

### ansible-drift-summary.sh

cat > "${work}/check.log" <<'LOG'
TASK [hosts : Populate /etc/hosts] *********************************************
ok: [knode1.lga1.radoncanyon.com]
changed: [odroid.lga2.radoncanyon.com]
--- before: /etc/hosts
+++ after: /etc/hosts
+10.0.0.1 secret-looking-line
TASK [chrony : config] *********************************************************
ok: [odroid.lga2.radoncanyon.com]

PLAY RECAP *********************************************************************
knode1.lga1.radoncanyon.com : ok=70   changed=0    unreachable=0    failed=0
odroid.lga2.radoncanyon.com : ok=89   changed=1    unreachable=0    failed=0
LOG
summary="$("${scripts}/ansible-drift-summary.sh" "${work}/check.log")"
expect "ansible-drift-summary lists changed tasks and the recap" \
'Changed tasks:

```
TASK [hosts : Populate /etc/hosts] *********************************************
  changed: [odroid.lga2.radoncanyon.com]
```

Recap:

```
knode1.lga1.radoncanyon.com : ok=70   changed=0    unreachable=0    failed=0
odroid.lga2.radoncanyon.com : ok=89   changed=1    unreachable=0    failed=0
```' "${summary}"
if grep -q "secret-looking-line" <<<"${summary}"; then
  fail "ansible-drift-summary leaves out the --diff output"
else
  pass "ansible-drift-summary leaves out the --diff output"
fi

### oidc-plan-env.sh

# A curl that answers the OIDC token request with a token naming its audience.
cat > "${work}/bin/curl" <<'SH'
#!/usr/bin/env bash
for a in "$@"; do case "$a" in audience=*) aud="${a#audience=}" ;; esac; done
printf '{"value":"eyJtoken-for-%s"}' "${aud}"
SH
chmod +x "${work}/bin/curl"
: > "${work}/oidc_env"
oidc_out="$(printf 'TF_VAR_a=a.example.com\n# comment\n\nTF_VAR_b=b.example.com\n' |
  PATH="${work}/bin:${PATH}" GITHUB_ENV="${work}/oidc_env" ACTIONS_ID_TOKEN_REQUEST_URL=https://t.example \
  ACTIONS_ID_TOKEN_REQUEST_TOKEN=x "${scripts}/oidc-plan-env.sh")"
expect "oidc-plan-env exports one token per NAME=audience line" \
"TF_VAR_a=eyJtoken-for-a.example.com
TF_VAR_b=eyJtoken-for-b.example.com" "$(cat "${work}/oidc_env")"
expect "oidc-plan-env masks every token" \
"::add-mask::eyJtoken-for-a.example.com
::add-mask::eyJtoken-for-b.example.com" "${oidc_out}"
GITHUB_ENV="${work}/oidc_env" "${scripts}/oidc-plan-env.sh" </dev/null >/dev/null 2>&1
expect "oidc-plan-env fails without id-token: write" "1" "$?"
rm "${work}/bin/curl"

### argocd-sync-check.py

sync="${scripts}/argocd-sync-check.py"
expect "sync-check maps changed paths to Applications" \
"argocd
sonarr" "$(printf 'kubernetes/apps/sonarr/deployment.yaml\nkubernetes/apps/argocd/values.yaml\nkubernetes/README.md\nkubernetes/_template/helm/values.yaml\n' | python3 "${sync}" targets)"
expect "sync-check adds the root when an application.yaml changes" \
"bootstrap
sonarr" "$(echo kubernetes/apps/sonarr/application.yaml | python3 "${sync}" targets)"
expect "sync-check checks every Application after a bootstrap change" "*" \
  "$(echo kubernetes/bootstrap/Application.yaml | python3 "${sync}" targets)"

# A repo with three commits: base, the pushed one, and a later one.
s="${work}/syncrepo"
git init -q "${s}" && mkdir -p "${s}/kubernetes/apps/web"
gitc() { git -C "${s}" -c user.name=t -c user.email=t@t -c commit.gpgsign=false "$@"; }
echo a > "${s}/kubernetes/apps/web/a.yaml"; gitc add -A; gitc commit -qm base
base="$(gitc rev-parse HEAD)"
echo b > "${s}/kubernetes/apps/web/a.yaml"; gitc commit -qam push
pushed="$(gitc rev-parse HEAD)"
echo c > "${s}/README.md"; gitc add -A; gitc commit -qm later
later="$(gitc rev-parse HEAD)"
app() { # <revision> <sync> <health> [<phase>]
  printf '{"items":[{"metadata":{"name":"web"},"status":{"sync":{"status":"%s","revision":"%s"},"health":{"status":"%s"},"operationState":{"phase":"%s","message":"boom","syncResult":{"revision":"%s"}}}}]}' \
    "$2" "$1" "$3" "${4:-Succeeded}" "$1" > "${work}/apps.json"
}
synccheck() { REPO_ROOT="${s}" ARGOCD_APPS_JSON="${work}/apps.json" SYNC_TIMEOUT=0 python3 "${sync}" wait "${base}" "${pushed}" 2>&1; }

app "${pushed}" Synced Healthy
contains "sync-check passes a Synced, Healthy app at the pushed commit" "Every changed Application is Synced and Healthy" "$(synccheck)"
app "${later}" Synced Healthy
contains "sync-check accepts an app already at a later commit" "Every changed Application is Synced and Healthy" "$(synccheck)"
# A checkout made before the later commit was pushed has to fetch it.
gitc branch at-push "${pushed}"
git clone -q --single-branch --branch at-push "file://${s}" "${work}/synccheckout"
contains "sync-check fetches a later commit its checkout lacks" "Every changed Application is Synced and Healthy" \
  "$(REPO_ROOT="${work}/synccheckout" ARGOCD_APPS_JSON="${work}/apps.json" SYNC_TIMEOUT=0 python3 "${sync}" wait "${base}" "${pushed}" 2>&1)"
app "${base}" Synced Healthy
contains "sync-check waits for an app still at an older commit" "Timed out after 0s waiting for web" "$(synccheck)"
app "${pushed}" OutOfSync Healthy Running
contains "sync-check waits for a running sync" "Timed out after 0s waiting for web" "$(synccheck)"
app "${pushed}" OutOfSync Degraded Failed
contains "sync-check fails a failed sync" "Sync failed for web" "$(synccheck)"
expect "sync-check exits 1 when a sync fails" "1" "$(synccheck >/dev/null; echo $?)"
contains "sync-check skips a push with no Application change" "No Argo CD Application changed" \
  "$(REPO_ROOT="${s}" ARGOCD_APPS_JSON="${work}/apps.json" python3 "${sync}" wait "${pushed}" "${later}")"

### credential-expiry.py

expiry="${scripts}/credential-expiry.py"
cat > "${work}/creds.yaml" <<'YAML'
- {name: Soon, vault: ci, item: a, expires: 2030-01-20, used_by: x, rotate: y}
- {name: Later, vault: ci, item: b, expires: 2030-06-01, used_by: x, rotate: y}
- {name: Gone, vault: ci-pr, item: c, expires: 2029-12-25, used_by: x, rotate: y}
YAML
out="$(TODAY=2030-01-01 python3 "${expiry}" "${work}/creds.yaml")"
expect "credential-expiry exits 1 when one is close" "1" "$(TODAY=2030-01-01 python3 "${expiry}" "${work}/creds.yaml" >/dev/null; echo $?)"
contains "credential-expiry lists one expiring within 30 days" "**Soon** expires in 19 days" "${out}"
contains "credential-expiry lists an expired one" "**Gone** expired 7 days ago" "${out}"
if grep -q Later <<<"${out}"; then fail "credential-expiry leaves out a distant one"; else pass "credential-expiry leaves out a distant one"; fi
contains "credential-expiry says when none is close" "No credential expires within 30 days" \
  "$(TODAY=2029-01-01 python3 "${expiry}" "${work}/creds.yaml")"
echo '- {name: Bad, vault: ci, item: d, expires: soon, used_by: x, rotate: y}' > "${work}/bad.yaml"
expect "credential-expiry rejects an entry without a date" "2" "$(python3 "${expiry}" "${work}/bad.yaml" 2>/dev/null; echo $?)"
expect "the repo's credentials.yaml is complete" "0" "$(TODAY=2000-01-01 python3 "${expiry}" >/dev/null; echo $?)"
### ci-gate-run.sh (end to end, against a fake gh)

# The fake gh serves GETs from ${GH_FIXTURES}/<path with / as _>.json (query
# dropped), applies --jq as gh does, and logs every other call, with its body,
# to ${GH_FIXTURES}/calls.log, answering from <METHOD>_<path>.json if present.
mkdir -p "${work}/ghbin"
cat > "${work}/ghbin/gh" <<'SH'
#!/usr/bin/env bash
[ "$1" = api ] || exit 2; shift
method=GET url="" jqexpr="" input=0 fields=()
while [ $# -gt 0 ]; do
  case "$1" in
    -X) method="$2"; shift 2 ;;
    --jq) jqexpr="$2"; shift 2 ;;
    --paginate) shift ;;
    --input) input=1; shift 2 ;;
    -f|-F) fields+=("$2"); shift 2 ;;
    *) url="$1"; shift ;;
  esac
done
path="${url%%\?*}"
if [ "${method}" != GET ]; then
  { echo "${method} ${path}"
    for f in "${fields[@]}"; do
      case "${f}" in *=@*) echo "  ${f%%=@*}:"; sed 's/^/    /' "${f#*=@}" ;; *) echo "  ${f}" ;; esac
    done
    [ "${input}" = 1 ] && jq -c .; echo; } >> "${GH_FIXTURES}/calls.log"
  f="${GH_FIXTURES}/${method}_$(tr / _ <<<"${path}").json"
  if [ -f "${f}" ]; then body="$(cat "${f}")"; else body='{"id": 999}'; fi
else
  f="${GH_FIXTURES}/$(tr / _ <<<"${path}").json"
  [ -f "${f}" ] || { echo "fake gh: no fixture ${f}" >&2; exit 1; }
  body="$(cat "${f}")"
fi
if [ -n "${jqexpr}" ]; then jq -r "${jqexpr}" <<<"${body}"; else echo "${body}"; fi
SH
chmod +x "${work}/ghbin/gh"

# gate_fixtures <dir> <pre-commit conclusion> <destroys: yes|no> <label: none|owner|app>
gate_fixtures() {
  local d="$1" pc="$2" destroys="$3" label="$4" n=0
  rm -rf "${d}" && mkdir -p "${d}"
  [ "${destroys}" = yes ] && n=1
  cat > "${d}/repos_o_r_commits_${head}_check-runs.json" <<JSON
{"check_runs": [
  {"id": 1, "name": "ci-ok", "status": "in_progress", "conclusion": null, "output": {"annotations_count": 0}},
  {"id": 2, "name": "Protected gate", "status": "in_progress", "conclusion": null, "output": {"annotations_count": 0}},
  {"id": 3, "name": "pre-commit", "status": "completed", "conclusion": "${pc}", "output": {"annotations_count": 0}},
  {"id": 4, "name": "dns / Plan", "status": "completed", "conclusion": "success", "html_url": "u/dns", "output": {"annotations_count": ${n}}}
]}
JSON
  echo '[{"title": "plan-destroys", "message": "DNS: aws_route53_record.x (delete)"}]' > "${d}/repos_o_r_check-runs_4_annotations.json"
  printf '{"content": "%s"}' "$(echo '* @owner' | base64)" > "${d}/repos_o_r_contents_.github_CODEOWNERS.json"
  case "${label}" in
    none) echo '[]' > "${d}/repos_o_r_issues_7_labels.json"; echo '[]' > "${d}/repos_o_r_issues_7_events.json" ;;
    owner|app)
      echo '[{"name": "destroy-approved"}]' > "${d}/repos_o_r_issues_7_labels.json"
      if [ "${label}" = app ]; then app='{"slug": "some-app"}'; else app=null; fi
      echo "[{\"event\": \"labeled\", \"label\": {\"name\": \"destroy-approved\"}, \"actor\": {\"login\": \"owner\"}, \"performed_via_github_app\": ${app}, \"created_at\": \"2030-01-01T00:10:00Z\"}]" \
        > "${d}/repos_o_r_issues_7_events.json" ;;
  esac
  # The head commit was pushed at 00:00; a re-run added the 00:20 suite.
  echo '{"check_suites": [{"created_at": "2030-01-01T00:20:00Z"}, {"created_at": "2030-01-01T00:00:00Z"}]}' \
    > "${d}/repos_o_r_commits_${head}_check-suites.json"
  echo '[]' > "${d}/repos_o_r_issues_7_comments.json"
  echo '[{"filename": "kubernetes/apps/web/deployment.yaml"}]' > "${d}/repos_o_r_pulls_7_files.json"
}
gaterun() { # <fixtures dir>; prints the exit status
  PATH="${work}/ghbin:${PATH}" GH_FIXTURES="$1" GATE_SETTLE=0 GATE_POLL=0 GITHUB_ENV="$1/env" \
    REPO=o/r SHA="${head}" PR=7 BASE_REF=main RUN_URL=u/run "${scripts}/ci-gate-run.sh" >"$1/out.log" 2>&1
  echo $?
}
conclusion() { jq -rs '[.[] | select(.conclusion)] | last | .conclusion' < <(sed -n '/^PATCH repos\/o\/r\/check-runs\/999/,/^$/p' "$1/calls.log" | grep '^{'); }

g="${work}/gate"
gate_fixtures "${g}" success no none
expect "gate passes when every check passed" "0" "$(gaterun "${g}")"
expect "gate completes ci-ok as success" "success" "$(conclusion "${g}")"
contains "gate starts ci-ok as in_progress first" "status=in_progress" "$(sed -n '1,/^$/p' "${g}/calls.log")"
contains "gate posts the summary comment" "POST repos/o/r/issues/7/comments" "$(cat "${g}/calls.log")"
contains "gate records the check run for the cancel step" "CHECK_RUN_ID=999" "$(cat "${g}/env")"

gate_fixtures "${g}" failure no none
expect "gate fails when a check failed" "1" "$(gaterun "${g}")"
expect "gate completes ci-ok as failure when a check failed" "failure" "$(conclusion "${g}")"
contains "gate names the failed check" "pre-commit: failure" "$(cat "${g}/out.log")"

gate_fixtures "${g}" success yes none
expect "gate fails a destroy without destroy-approved" "1" "$(gaterun "${g}")"
expect "gate completes ci-ok as failure for an unapproved destroy" "failure" "$(conclusion "${g}")"

gate_fixtures "${g}" success yes app
expect "gate fails destroy-approved added through an app" "1" "$(gaterun "${g}")"

gate_fixtures "${g}" success yes owner
expect "gate passes a destroy a code owner approved" "0" "$(gaterun "${g}")"
expect "gate completes ci-ok as success for an approved destroy" "success" "$(conclusion "${g}")"
# The head commit is pushed after the label: a rebase, say.
echo '{"check_suites": [{"created_at": "2030-01-01T00:30:00Z"}]}' > "${g}/repos_o_r_commits_${head}_check-suites.json"
expect "gate fails an approval added before the head commit was pushed" "1" "$(gaterun "${g}")"
contains "gate asks for the label again" "remove the label and add it again" "$(cat "${g}/out.log")"

# A PR that edits what reports destroys could hide one, so it needs approval.
gate_fixtures "${g}" success no none
echo '[{"filename": ".github/scripts/manifest-destroys.sh"}]' > "${g}/repos_o_r_pulls_7_files.json"
expect "gate fails a change to the destroy checks without destroy-approved" "1" "$(gaterun "${g}")"
contains "gate names the destroy check the PR changes" \
  "Changes the destroy checks: .github/scripts/manifest-destroys.sh" "$(cat "${g}/out.log")"
gate_fixtures "${g}" success no none
echo '[{"filename": ".github/actions/tofu-plan/x.yml", "previous_filename": ".github/actions/tofu-plan/action.yml"}]' \
  > "${g}/repos_o_r_pulls_7_files.json"
expect "gate fails a renamed destroy check without destroy-approved" "1" "$(gaterun "${g}")"
gate_fixtures "${g}" success no owner
echo '[{"filename": ".github/workflows/kubernetes-argocd-diff.yaml"}]' > "${g}/repos_o_r_pulls_7_files.json"
expect "gate passes a change to the destroy checks a code owner approved" "0" "$(gaterun "${g}")"

### ansible-merge-tags.py

mt="${scripts}/ansible-merge-tags.py"
expect "ansible-merge-tags applies an allowlisted role alone" "unattended_upgrades" \
  "$(printf 'ansible/roles/unattended_upgrades/tasks/main.yml\nansible/README.md\n' | python3 "${mt}")"
expect "ansible-merge-tags applies nothing when another role changed too" "" \
  "$(printf 'ansible/roles/unattended_upgrades/tasks/main.yml\nansible/roles/sshd/tasks/main.yml\n' | python3 "${mt}")"
expect "ansible-merge-tags applies nothing for group_vars" "" \
  "$(echo ansible/group_vars/all | python3 "${mt}")"
expect "ansible-merge-tags applies nothing for site.yaml" "" \
  "$(echo ansible/site.yaml | python3 "${mt}")"
expect "ansible-merge-tags applies nothing for a docs-only change" "" \
  "$(echo ansible/README.md | python3 "${mt}")"
expect "every allowlisted tag is in site.yaml" "" "$(python3 - "${mt}" "${repo}/ansible/site.yaml" <<'PY'
import importlib.util, sys, yaml
spec = importlib.util.spec_from_file_location("mt", sys.argv[1]); mt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mt)
plays = yaml.safe_load(open(sys.argv[2]))
tagged = {r.get("tags") for p in plays for r in p.get("roles", []) if isinstance(r, dict)}
print(" ".join(t for t in mt.AUTO_APPLY.values() if t not in tagged))
PY
)"

### workflows

# Every workflow runs its steps with pipefail. Under the default shell
# (bash -e), `ci-gate-check.sh 2>&1 | tee gate.log` passed whatever the gate
# found, so ci-ok passed with failed checks.
nopipefail="$(python3 - "${repo}"/.github/workflows/*.yaml <<'PY'
import sys, yaml
for path in sys.argv[1:]:
    w = yaml.safe_load(open(path))
    if ((w.get("defaults") or {}).get("run") or {}).get("shell") != "bash":
        print(path.rsplit("/", 1)[1])
    for name, job in (w.get("jobs") or {}).items():
        for step in job.get("steps") or []:
            if "run" in step and step.get("shell") not in (None, "bash"):
                print(f"{path.rsplit('/', 1)[1]}: {name}: shell {step['shell']}")
PY
)"
expect "every workflow defaults to bash with pipefail" "" "${nopipefail}"

### scripts/pr-land (against the fake gh, with a stub pr-wait)

prl="${work}/pr-land"
mkdir -p "${prl}/bin"
cp "${repo}/scripts/pr-land" "${prl}/bin/"
printf '#!/usr/bin/env bash\nexit "${PR_WAIT_EXIT:-0}"\n' > "${prl}/bin/pr-wait"
chmod +x "${prl}/bin/pr-wait"
# prl_fixtures <dir> <gateway run conclusion> <merge: ok|fail>
prl_fixtures() {
  local d="$1"
  rm -rf "${d}" && mkdir -p "${d}"
  echo '{"head": {"sha": "beef1111"}, "title": "dns: add a record"}' > "${d}/repos_o_r_pulls_7.json"
  [ "$3" = ok ] && echo '{"sha": "merge2222", "merged": true}' > "${d}/PUT_repos_o_r_pulls_7_merge.json"
  cat > "${d}/repos_o_r_actions_runs.json" <<JSON
{"workflow_runs": [
  {"id": 1, "name": "DNS", "status": "completed", "conclusion": "success"},
  {"id": 2, "name": "Gateway", "status": "completed", "conclusion": "$2"}
]}
JSON
  echo '{"jobs": [{"name": "dns / Plan", "steps": []}, {"name": "dns / Apply", "steps": [{"name": "Apply", "conclusion": "success"}]}]}' \
    > "${d}/repos_o_r_actions_runs_1_jobs.json"
  echo '{"jobs": [{"name": "gateway / Apply", "steps": [{"name": "Apply", "conclusion": "skipped"}]}]}' \
    > "${d}/repos_o_r_actions_runs_2_jobs.json"
}
prlrun() { # <fixtures dir> [pr-wait exit] [reviewed sha]; prints pr-land's exit status
  PATH="${work}/ghbin:${PATH}" GH_FIXTURES="$1" GH_REPO=o/r PR_LAND_POLL=0 PR_WAIT_EXIT="${2:-0}" \
    "${prl}/bin/pr-land" 7 "${3:-beef1111}" >"$1/out.log" 2>&1
  echo $?
}

p="${work}/prl"
prl_fixtures "${p}" success ok
expect "pr-land passes when every run on main passed" "0" "$(prlrun "${p}")"
contains "pr-land merges the head pr-wait checked" "sha=beef1111" "$(cat "${p}/calls.log")"
contains "pr-land keeps the PR title in the squash commit" "commit_title=dns: add a record (#7)" "$(cat "${p}/calls.log")"
contains "pr-land reports an Apply step that ran" "dns / Apply: applied" "$(cat "${p}/out.log")"
contains "pr-land reports an Apply step that was skipped" "gateway / Apply: Apply step skipped, nothing applied" "$(cat "${p}/out.log")"
prl_fixtures "${p}" failure ok
expect "pr-land fails when a run on main failed" "1" "$(prlrun "${p}")"
contains "pr-land names the failed run" "Gateway: failure" "$(cat "${p}/out.log")"
prl_fixtures "${p}" success fail
expect "pr-land fails when the merge fails" "2" "$(prlrun "${p}")"
contains "pr-land says nothing was merged" "nothing was merged" "$(cat "${p}/out.log")"
prl_fixtures "${p}" success ok
echo '{"workflow_runs": []}' > "${p}/repos_o_r_actions_runs.json"
expect "pr-land passes a merge that starts no runs on main" "0" "$(prlrun "${p}")"
contains "pr-land says no workflow ran" "No workflow ran on main" "$(cat "${p}/out.log")"
prl_fixtures "${p}" success ok
expect "pr-land passes on pr-wait's failure exit" "1" "$(prlrun "${p}" 1)"
expect "pr-land doesn't merge when pr-wait fails" "" "$(cat "${p}/calls.log" 2>/dev/null)"
prl_fixtures "${p}" success ok
expect "pr-land refuses a head other than the one reviewed" "6" "$(prlrun "${p}" 0 cafe2222)"
expect "pr-land doesn't merge an unreviewed head" "" "$(cat "${p}/calls.log" 2>/dev/null)"
expect "pr-land merges with a reviewed SHA prefix" "0" "$(prlrun "${p}" 0 beef1111)"
expect "pr-land rejects a malformed SHA" "2" "$(prlrun "${p}" 0 nothex12)"

### terraform-stack-dirs.sh, tofu-validate.sh, tflint.sh

# Test the directory-finding helper with real repo stacks
out="$(cd "${repo}" && bash "${repo}/scripts/terraform-stack-dirs.sh" dns/main.tf datadog/main.tf dns/variables.tf)"
contains "terraform-stack-dirs deduplicates stacks" "dns" "${out}"
contains "terraform-stack-dirs finds all changed stacks" "datadog" "${out}"
# Count unique entries
count="$(echo "${out}" | sort -u | wc -l | tr -d ' ')"
expect "terraform-stack-dirs returns exactly 2 stacks" "2" "${count}"

# Test that tofu-validate finds the right stacks (use mocked tofu)
mkdir -p "${work}/testbin"
printf '#!/usr/bin/env bash\nexit 0\n' > "${work}/testbin/tofu"
chmod +x "${work}/testbin/tofu"
out="$(cd "${repo}" && PATH="${work}/testbin:${PATH}" TF_PLUGIN_CACHE_DIR="${work}/cache" bash "${repo}/scripts/tofu-validate.sh" dns/main.tf datadog/main.tf 2>&1)"
contains "tofu-validate processes changed files" "Validating" "${out}"

# Test that tflint finds the right stacks (use mocked tflint)
printf '#!/usr/bin/env bash\nexit 0\n' > "${work}/testbin/tflint"
chmod +x "${work}/testbin/tflint"
out="$(cd "${repo}" && PATH="${work}/testbin:${PATH}" TF_PLUGIN_CACHE_DIR="${work}/cache" bash "${repo}/scripts/tflint.sh" dns/main.tf datadog/main.tf 2>&1)"
contains "tflint processes changed files" "Linting" "${out}"

### scripts/tofu-test.sh

mkdir -p "${work}/tofu_test/with_test"
mkdir -p "${work}/tofu_test/no_test"
touch "${work}/tofu_test/with_test/test.tftest.hcl" "${work}/tofu_test/with_test/main.tf"
touch "${work}/tofu_test/no_test/main.tf"
mkdir -p "${work}/tofu_test_bin"
cat > "${work}/tofu_test_bin/tofu" <<'SH'
#!/usr/bin/env bash
# Stub tofu for testing; just pretend init and test succeed
case "$1" in
  -chdir=*) chdir="${1#-chdir=}"; shift; dir="$chdir" ;;
  *) dir="." ;;
esac
case "$1" in
  init) [ -d "$dir" ] && exit 0 || exit 1 ;;
  test) [ -f "${dir}/test.tftest.hcl" ] && exit 0 || exit 1 ;;
  *) exit 1 ;;
esac
SH
chmod +x "${work}/tofu_test_bin/tofu"
tofu_test_out="$(PATH="${work}/tofu_test_bin:${PATH}" bash "${repo}/scripts/tofu-test.sh" \
  "${work}/tofu_test/with_test/test.tftest.hcl" \
  "${work}/tofu_test/with_test/main.tf" \
  "${work}/tofu_test/no_test/main.tf" 2>&1)"
expect "tofu-test selects only directories with test files" "0" "$?"
contains "tofu-test tests the directory with a test file" "Testing ${work}/tofu_test/with_test" "${tofu_test_out}"
if grep -q "Testing ${work}/tofu_test/no_test" <<<"${tofu_test_out}"; then
  fail "tofu-test skips directories without test files"
else
  pass "tofu-test skips directories without test files"
fi
tofu_test_out="$(PATH="${work}/tofu_test_bin:${PATH}" bash "${repo}/scripts/tofu-test.sh" \
  "${work}/tofu_test/no_test/main.tf" 2>&1)"
expect "tofu-test passes when no changed directory has test files" "0" "$?"

### scripts/plan

plan="${repo}/scripts/plan"
stacks="$(python3 "${plan}" --list | cut -f1)"
callers="$(grep -l 'uses: ./.github/workflows/_tofu-stack.yaml' "${repo}"/.github/workflows/*.yaml | wc -l | tr -d ' ')"
contains "plan --list finds the DNS stack" "dns" "${stacks}"
contains "plan --list expands the AWS matrix" "aws/ses" "${stacks}"
expect "plan --list covers every stack workflow" "${callers}" \
  "$(python3 "${plan}" --list | cut -f2 | sort -u | wc -l | tr -d ' ')"
gateway="$(python3 "${plan}" gateway --dry-run)"
contains "plan gateway uses the PR plan's excludes" "-exclude=opnsense_wireguard_server.lga1" "${gateway}"
contains "plan gateway sets the PR plan's placeholders" "export TF_VAR_wg_psk=placeholder" "${gateway}"
contains "plan gateway reads only the read-only credentials" "op run --env-file gateway/secrets.plan.env" "${gateway}"
contains "plan never takes the state lock" "plan -input=false -lock=false" "${gateway}"
if grep -q "secrets.env " <<<"${gateway}"; then fail "plan never uses the apply credentials"; else pass "plan never uses the apply credentials"; fi
contains "plan runs tofu from the repo root, past the apply wrapper" "tofu -chdir=gateway" "${gateway}"
expect "plan uses a service account token instead of the app when one is set" "" \
  "$(OP_SERVICE_ACCOUNT_TOKEN=x python3 "${plan}" dns --dry-run | grep -E 'OP_APP_AUTH|--account')"
arr="$(python3 "${plan}" arr --dry-run)"
contains "plan arr says which keys CI passes as OIDC tokens" "# set TF_VAR_sonarr_api_key: CI uses a GitHub OIDC token here" "${arr}"
contains "plan arr uses the PR plan's excludes" "-exclude=radarr_notification_plex.plex" "${arr}"
python3 "${plan}" arr >/dev/null 2>&1
expect "plan arr refuses to run without the real keys" "2" "$?"
python3 "${plan}" no-such-stack >/dev/null 2>&1
expect "plan rejects an unknown stack" "2" "$?"

### scripts/check-hostnames.py

# A throwaway repo with one private app, one public app, and the docs they need.
make_repo() {
  local dir="$1"
  rm -rf "${dir}" && mkdir -p "${dir}/scripts" "${dir}/kubernetes/apps/web" "${dir}/kubernetes/apps/pub/manifests"
  cp "${repo}/scripts/check-hostnames.py" "${dir}/scripts/"
  route() { # <file> <name> <host> <gateways...>
    local f="$1" n="$2" h="$3"; shift 3
    { echo "apiVersion: gateway.networking.k8s.io/v1"; echo "kind: HTTPRoute"
      echo "metadata: {name: ${n}}"; echo "spec:"; echo "  parentRefs:"
      for g in "$@"; do echo "  - {name: ${g}, namespace: envoy-gateway-system}"; done
      echo "  hostnames: [${h}]"; } > "${f}"
  }
  route "${dir}/kubernetes/apps/web/httproute.yaml" web swee.desertbluffs.com private
  route "${dir}/kubernetes/apps/pub/manifests/httproute.yaml" pub nox.desertbluffs.com private internet
  printf '# Unused codenames\n\n- kikit\n- lullu\n' > "${dir}/CODENAMES.md"
  cat > "${dir}/EXPOSURE.md" <<'MD'
| Service | Namespace | Hostname | Internet | Notes |
| --- | --- | --- | --- | --- |
| Pub | `pub` | `nox` | Yes | |
| Web | `web` | `swee` | No | |
MD
  git -C "${dir}" init -q && git -C "${dir}" add -A
}
hostcheck() { (cd "$1" && git add -A && python3 scripts/check-hostnames.py 2>&1); }

r="${work}/hostrepo"
make_repo "${r}"
if out="$(hostcheck "${r}")"; then pass "check-hostnames passes a consistent repo"; else fail "check-hostnames passes a consistent repo"; echo "${out}"; fi

make_repo "${r}"
cp -r "${r}/kubernetes/apps/web" "${r}/kubernetes/apps/web2"
contains "check-hostnames catches two apps routing one hostname" \
  "swee.desertbluffs.com is routed by more than one app" "$(hostcheck "${r}")"

make_repo "${r}"
echo "see kikit.${domain}" > "${r}/notes.txt"
contains "check-hostnames catches a codename still listed as unused" \
  "kikit.${domain} uses a codename CODENAMES.md still lists as unused" "$(hostcheck "${r}")"

make_repo "${r}"
sed -i 's/| `swee` | No |/| `swee` | Yes |/' "${r}/EXPOSURE.md"
contains "check-hostnames catches Internet: Yes without an internet route" \
  "swee.desertbluffs.com says Internet: Yes, but only the private gateway routes it" "$(hostcheck "${r}")"

make_repo "${r}"
sed -i 's/| `nox` | Yes |/| `nox` | Only |/' "${r}/EXPOSURE.md"
contains "check-hostnames catches Internet: Only with a private route" \
  "nox.desertbluffs.com says Internet: Only, but the private gateway routes it too" "$(hostcheck "${r}")"

make_repo "${r}"
sed -i '/`swee`/d' "${r}/EXPOSURE.md"
contains "check-hostnames catches a routed hostname missing from EXPOSURE.md" \
  "swee.desertbluffs.com is routed but not in the table" "$(hostcheck "${r}")"

### scripts/opnsense-config

oc() { python3 -I "${repo}/scripts/opnsense-config" "$@"; }
# Built from parts so no file in the repo holds a PEM private key header.
pem="-----BEGIN ""PRIVATE KEY-----"
cat >"${work}/config.xml" <<XML
<?xml version="1.0"?>
<opnsense>
  <system>
    <hostname>gw</hostname>
    <user uuid="aaaaaaaa-0000-0000-0000-000000000001">
      <name>admin</name>
      <password>FIXTURE-SECRET-password</password>
      <authorizedkeys>FIXTURE-SECRET-authorizedkeys</authorizedkeys>
      <otp_seed>FIXTURE-SECRET-otp</otp_seed>
      <apikeys>FIXTURE-SECRET-apikeys</apikeys>
    </user>
    <remotebackup>
      <GDriveP12key>FIXTURE-SECRET-p12</GDriveP12key>
      <GDrivePassword>FIXTURE-SECRET-gdrive</GDrivePassword>
    </remotebackup>
    <authserver><otpLength>6</otpLength><passwordFirst>1</passwordFirst></authserver>
  </system>
  <cert><descr>web</descr><crt>FIXTURE-SECRET-crt</crt><prv>${pem}FIXTURE-SECRET-prv</prv></cert>
  <OPNsense>
    <wireguard>
      <server><servers><server uuid="bbbbbbbb-0000-0000-0000-000000000002">
        <privkey>FIXTURE-SECRET-privkey</privkey>
        <pubkey>FIXTUREPUBKEY</pubkey>
      </server></servers></server>
      <client><clients><client uuid="cccccccc-0000-0000-0000-000000000003">
        <psk>FIXTURE-SECRET-psk</psk>
        <keepalive>25</keepalive>
      </client></clients></client>
    </wireguard>
    <AcmeClient><validations><validation uuid="dddddddd-0000-0000-0000-000000000004">
      <dns_cf_token>FIXTURE-SECRET-acme</dns_cf_token>
      <dns_cf_key>0123456789abcdef0123456789abcdefFIXTURESECRETBLOB</dns_cf_key>
    </validation></validations></AcmeClient>
    <netsnmp><general><rocommunity>FIXTURE-SECRET-snmp</rocommunity></general></netsnmp>
    <Firewall><Filter><rules>
      <rule uuid="eeeeeeee-0000-0000-0000-000000000005">
        <enabled>1</enabled><sequence>10</sequence><action>pass</action><quick>1</quick>
        <interface>lan</interface><direction>in</direction><ipprotocol>inet</ipprotocol>
        <protocol>TCP</protocol><source_net>lan</source_net><source_not>0</source_not>
        <destination_net>web</destination_net><destination_not>1</destination_not>
        <destination_port>443</destination_port><statetype>keep</statetype><log>0</log>
        <description>LAN out</description><audit>FIXTURE-SECRET-audit</audit>
      </rule>
    </rules></Filter></Firewall>
  </OPNsense>
  <nat>
    <outbound><mode>hybrid</mode></outbound>
    <rule uuid="ffffffff-0000-0000-0000-000000000006">
      <sequence>100</sequence><disabled>0</disabled><nordr>1</nordr><interface>lan</interface>
      <protocol>tcp/udp</protocol>
      <source><network/><port/><not>0</not></source>
      <destination><network>remote</network><port>domain</port><not>0</not></destination>
      <target/><local-port/><log>0</log><pass>pass</pass><descr>No redirect</descr>
    </rule>
  </nat>
  <descr>\$2y\$10\$FIXTURESECRETHASH</descr>
  <staticroutes><route>a</route><route>b</route></staticroutes>
</opnsense>
XML

expect "opnsense-config flatten labels uuid records and repeated siblings" \
"system/user[aaaaaaaa]/name=admin
system/user[aaaaaaaa]/password=[REDACTED]
staticroutes/route#1=a
staticroutes/route#2=b" \
  "$(oc flatten "${work}/config.xml" system staticroutes | grep -E '/(name|password)=|route')"
expect "opnsense-config flatten --strip-uuids --sort drops uuids and sorts" \
"OPNsense/wireguard/client/clients/client/keepalive=25
OPNsense/wireguard/client/clients/client/psk=[REDACTED]" \
  "$(oc flatten "${work}/config.xml" OPNsense/wireguard/client --strip-uuids --sort)"
expect "opnsense-config flatten and redact print no fixture secret" "" \
  "$({ oc flatten "${work}/config.xml"; oc rules "${work}/config.xml"; oc redact "${work}/config.xml"; } \
    | grep -E 'FIXTURE-?SECRET|PRIVATE KEY')"
expect "opnsense-config redacts every secret in the fixture" "15" \
  "$(oc flatten "${work}/config.xml" | grep -c '=\[REDACTED\]$')"
contains "opnsense-config keeps flags that only look secret" "authserver/passwordFirst=1" \
  "$(oc flatten "${work}/config.xml" system)"
contains "opnsense-config keeps public keys unless asked" "pubkey=FIXTUREPUBKEY" "$(oc flatten "${work}/config.xml")"
contains "opnsense-config --redact-pubkeys redacts public keys" "pubkey=[REDACTED]" \
  "$(oc flatten --redact-pubkeys "${work}/config.xml")"
contains "opnsense-config --no-redact prints secrets" "psk=FIXTURE-SECRET-psk" \
  "$(oc flatten --no-redact "${work}/config.xml")"
expect "opnsense-config redact keeps the document's structure" "lan" \
  "$(oc redact "${work}/config.xml" | python3 -I -c 'import sys, xml.etree.ElementTree as E; print(E.parse(sys.stdin).getroot().findtext("OPNsense/Firewall/Filter/rules/rule/interface"))')"
expect "opnsense-config rules prints filter and NAT rules" \
"## filter rules (legacy)
## filter rules
10 on pass lan dir=in quick=1 inet TCP lan -> !web:443 state=keep | LAN out
## port forwards
100 on lan tcp/udp any -> remote:domain => : nordr pass=pass | No redirect
## outbound nat mode=hybrid" "$(oc rules "${work}/config.xml")"
expect "opnsense-config classifies every listed tag" "ok" \
  "$(python3 -I -c '
import importlib.machinery, importlib.util, sys
loader = importlib.machinery.SourceFileLoader("oc", sys.argv[1])
spec = importlib.util.spec_from_loader("oc", loader)
oc = importlib.util.module_from_spec(spec)
loader.exec_module(oc)
bad = [t for t in oc.SECRET_TAGS if not oc.is_secret(t, "x")]
bad += [t for t in oc.NOT_SECRET_TAGS if oc.is_secret(t, "x" * 40)]
print(bad or "ok")' "${repo}/scripts/opnsense-config")"
# fetch_test <body>: load_root on a URL, with urlopen replaced by a stub that
# records the request and returns <body>.
fetch_test() {
  OPNSENSE_API_KEY="${KEY:-k}" OPNSENSE_API_SECRET="${SECRET:-s}" python3 -I -c '
import importlib.machinery, importlib.util, io, sys, urllib.request
loader = importlib.machinery.SourceFileLoader("oc", sys.argv[1])
oc = importlib.util.module_from_spec(importlib.util.spec_from_loader("oc", loader))
loader.exec_module(oc)
def urlopen(req, timeout):
    print(req.full_url, req.get_header("Authorization"))
    return io.BytesIO(sys.argv[2].encode())
urllib.request.urlopen = urlopen
print(oc.load_root("https://gw.example/").findtext("system/hostname"))' "${repo}/scripts/opnsense-config" "$1" 2>&1
}
expect "opnsense-config fetches a URL from the backup API with basic auth" \
"https://gw.example/api/core/backup/download/this Basic azpz
gw" "$(fetch_test '<?xml version="1.0"?><opnsense><system><hostname>gw</hostname></system></opnsense>')"
mkdir -p "${work}/bin"
# A stub op that prints the last 7 characters of the reference it reads.
cat >"${work}/bin/op" <<'SH'
#!/bin/sh
[ "${OP_APP_AUTH}" = 1 ] && [ -z "${OP_FAIL}" ] || exit 1
for ref; do :; done
printf %s "${ref}" | tail -c 7
SH
chmod +x "${work}/bin/op"
contains "opnsense-config reads op:// credentials for the URL's host" \
  "Basic $(printf %s 'ple/key:ple/sec' | base64)" \
  "$(PATH="${work}/bin:${PATH}" KEY='op://v/api-{host}/key' SECRET='op://v/api-{host}/sec' \
    fetch_test '<?xml version="1.0"?><opnsense/>')"
contains "opnsense-config names the op:// reference it failed to read" "op read op://v/api-gw.example/key" \
  "$(PATH="${work}/bin:${PATH}" OP_FAIL=1 KEY='op://v/api-{host}/key' fetch_test '<?xml version="1.0"?><opnsense/>')"
contains "opnsense-config rejects a download that is not XML" "returned no XML document" \
  "$(fetch_test '&lt;?xml version="1.0"?&gt;')"
contains "opnsense-config needs API credentials to fetch" "set OPNSENSE_API_KEY" \
  "$(env -u OPNSENSE_API_KEY python3 -I "${repo}/scripts/opnsense-config" rules https://gw.example 2>&1)"

echo
if [ "${failures}" -gt 0 ]; then echo "${failures} failed"; exit 1; fi
echo "all passed"
