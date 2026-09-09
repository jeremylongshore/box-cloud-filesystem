#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd -P)"
cd "$repo_root"

jq -e '.name == "box-cloud-filesystem" and .version == "2.0.0" and
  .skills == "./skills/" and .hooks == "./hooks/hooks.json"' \
  .claude-plugin/plugin.json >/dev/null
jq -e '.name == "box-cloud-filesystem" and .version == "2.0.0" and
  .license == "MIT" and (.keywords | length >= 3) and
  (.plugins | length == 1) and
  .plugins[0].name == "box-cloud-filesystem" and
  (.plugins[0] | has("version") | not) and .plugins[0].source == "./"' \
  .claude-plugin/marketplace.json >/dev/null
jq -e '.hooks.PostToolUse[0].matcher == "Write|Edit" and
  (.hooks.PostToolUse[0].hooks | length == 1) and
  .hooks.PostToolUse[0].hooks[0].type == "command" and
  .hooks.Stop[0].matcher == null and
  (.hooks.Stop[0].hooks | length == 1) and
  .hooks.Stop[0].hooks[0].type == "command"' hooks/hooks.json >/dev/null

if rg -n --hidden --glob '!.git/**' --glob '!tests/validate-repository.sh' -- \
  'users:get --me|transparent sync|automatically upload|--enterprise|ccpi install' .; then
  echo "Stale v1 behavior or tooling remains in the repository." >&2
  exit 1
fi

if rg -n -- '^[[:space:]]*box[[:space:]]' \
  scripts/box-sync-on-write.sh scripts/box-sync-summary.sh; then
  echo "A local hook contains a Box CLI invocation." >&2
  exit 1
fi

grep -Fq 'auto_upload: false' scripts/box-init-workspace.sh
grep -Fq 'never uploads automatically' skills/box-cloud-filesystem/SKILL.md

echo "Repository contract validation passed."
