#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd -P)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

workspace="${test_root}/workspace"
sibling="${test_root}/workspace-other"
config_root="${test_root}/config"
mock_bin="${test_root}/bin"
box_called="${test_root}/box-called"
mkdir -p "$workspace/docs" "$sibling" \
  "${config_root}/box-cloud-filesystem" "$mock_bin"

jq -n \
  --arg workspace "$workspace" \
  '{workspace: $workspace, queue_changes: true, auto_upload: false}' \
  > "${config_root}/box-cloud-filesystem/config.json"

printf '#!/usr/bin/env bash\ntouch %q\nexit 99\n' "$box_called" > "${mock_bin}/box"
chmod +x "${mock_bin}/box"

queue_file() {
  local file_path="$1"
  jq -n --arg file_path "$file_path" \
    '{tool_input: {file_path: $file_path}}' |
    PATH="${mock_bin}:$PATH" XDG_CONFIG_HOME="$config_root" \
      "$repo_root/scripts/box-sync-on-write.sh"
}

printf 'approved content\n' > "${workspace}/docs/report.md"
queue_file "${workspace}/docs/report.md"
queue_file "${workspace}/docs/report.md"

expected='docs/report.md'
actual="$(tr -d '\r' < "${workspace}/.box-sync-pending")"
[ "$actual" = "$expected" ] || {
  echo "Expected one deduplicated relative path, got: $actual" >&2
  exit 1
}
[ "$(stat -c '%a' "${workspace}/.box-sync-pending")" = "600" ] || {
  echo "Pending queue permissions are not restricted." >&2
  exit 1
}

printf 'not in scope\n' > "${sibling}/report.md"
queue_file "${sibling}/report.md"

printf 'sensitive\n' > "${workspace}/docs/API-TOKEN.txt"
queue_file "${workspace}/docs/API-TOKEN.txt"

printf 'hidden\n' > "${workspace}/.env"
queue_file "${workspace}/.env"

ln -s "${workspace}/docs/report.md" "${workspace}/linked-report.md"
queue_file "${workspace}/linked-report.md"

[ "$(wc -l < "${workspace}/.box-sync-pending" | tr -d ' ')" = "1" ] || {
  echo "Excluded, sibling, or duplicate path entered the queue." >&2
  exit 1
}

[ ! -e "$box_called" ] || {
  echo "The queue hook invoked Box unexpectedly." >&2
  exit 1
}

summary="$(XDG_CONFIG_HOME="$config_root" \
  "$repo_root/scripts/box-sync-summary.sh")"
grep -Fq '1 local file(s) are pending' <<<"$summary"
grep -Fq 'No Box upload was performed' <<<"$summary"
[ -s "${workspace}/.box-sync-pending" ] || {
  echo "The summary hook cleared the pending queue." >&2
  exit 1
}

echo "Queue hook tests passed."
