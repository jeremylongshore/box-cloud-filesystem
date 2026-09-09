# CLAUDE.md

## What This Is

Claude Code plugin for reviewed Box CLI (`@box/cli`) operations. Write/Edit
hooks queue eligible local changes for review and never upload automatically;
remote mutations use explicit Box CLI commands with safety guardrails.

## Structure

- `skills/box-cloud-filesystem/SKILL.md` — core skill (auto-activating)
- `skills/box-cloud-filesystem/references/` — operations guide + sync pattern
- `hooks/hooks.json` — PostToolUse (Write/Edit) + Stop hooks
- `scripts/` — hook handlers + workspace init + gist updater

## Validation

```bash
shellcheck scripts/*.sh
```

Marketplace grading (requires the marketplace repository):
```bash
python3 scripts/validate-skills-schema.py --marketplace --verbose
```

## Conventions

- Shell scripts: `set -euo pipefail`, `#!/usr/bin/env bash`
- SKILL.md: imperative voice, no first/second person
- Portable paths: `${CLAUDE_PLUGIN_ROOT}` in hooks, `${CLAUDE_SKILL_DIR}` in skills
- Commit messages: Conventional Commits format

## Gist

The public gist (ID in `.gist-id`) contains the one-pager, operator audit, changelog, and all source files. Update with `./scripts/update-gist.sh` after releases.

## External Sync

This repo is the source of truth. The Tons of Skills marketplace pulls from here daily via `sources.yaml` in the marketplace monorepo.
