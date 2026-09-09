#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd -P)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

mock_bin="${test_root}/bin"
config_root="${test_root}/config"
workspace="${test_root}/workspace"
box_log="${test_root}/box.log"
mkdir -p "$mock_bin"
cp "${repo_root}/tests/fixtures/box" "${mock_bin}/box"
chmod +x "${mock_bin}/box"

PATH="${mock_bin}:$PATH" \
BOX_MOCK_LOG="$box_log" \
XDG_CONFIG_HOME="$config_root" \
  "$repo_root/scripts/box-init-workspace.sh" 123 "$workspace"

config_path="${config_root}/box-cloud-filesystem/config.json"
[ "$(stat -c '%a' "$config_path")" = "600" ]
jq -e --arg workspace "$workspace" \
  '.workspace == $workspace and .box_folder_id == "123" and
   .queue_changes == true and .auto_upload == false' "$config_path" >/dev/null
jq -e '.entries[0].id == "99"' "${workspace}/.box-manifest.json" >/dev/null
grep -Fqx 'users:get me --json' "$box_log"
grep -Fqx "folders:download 123 --destination $workspace --create-path" "$box_log"
grep -Fqx 'folders:items 123 --json --fields name,id,type,content_modified_at' "$box_log"

nonempty="${test_root}/nonempty"
mkdir -p "$nonempty"
printf 'keep me\n' > "${nonempty}/existing.txt"
if PATH="${mock_bin}:$PATH" \
  BOX_MOCK_LOG="$box_log" \
  XDG_CONFIG_HOME="$config_root" \
    "$repo_root/scripts/box-init-workspace.sh" 123 "$nonempty" >/dev/null 2>&1; then
  echo "Initialization unexpectedly accepted a non-empty workspace." >&2
  exit 1
fi
grep -Fqx 'keep me' "${nonempty}/existing.txt"

if PATH="${mock_bin}:$PATH" \
  BOX_MOCK_LOG="$box_log" \
  XDG_CONFIG_HOME="$config_root" \
    "$repo_root/scripts/box-init-workspace.sh" invalid \
    "${test_root}/invalid" >/dev/null 2>&1; then
  echo "Initialization unexpectedly accepted a non-numeric Box folder ID." >&2
  exit 1
fi

echo "Workspace initialization tests passed."
