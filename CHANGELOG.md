# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-17

### Added

- SKILL.md with progressive disclosure architecture (A grade, 92/100 enterprise rubric)
  - Trust zone model: Read / Create / Update / Expose / Destructive
  - 8 operational safety rules
  - Quick command reference
  - Workspace sync pattern overview
  - Error handling table
  - 3 worked examples
- PostToolUse hook on Write/Edit for transparent Box sync (`box-sync-on-write.sh`)
  - Reads tool_input JSON from stdin
  - Version upload for known files, new upload for unknown
  - Manifest auto-update on new file upload
  - Path containment guard (only syncs files inside workspace)
- Stop hook for sync summary reporting (`box-sync-summary.sh`)
- Workspace init script (`box-init-workspace.sh`)
  - Downloads Box folder contents
  - Builds `.box-manifest.json` (filename-to-file-ID mapping)
  - Writes `~/.box-cloud-filesystem.json` global config
  - Validates Box CLI presence and auth before proceeding
- Reference documents (progressive disclosure)
  - `operations-guide.md` -- full Box CLI command reference organized by trust zone, 13-scenario error table
  - `sync-pattern.md` -- 5-step pull/work/push workflow, conflict detection, 3 worked examples
- README with install instructions (marketplace + standalone), quick start, safety overview
- MIT license

### Security

- Sharing defaults to `collaborators` access, never `open` unless user explicitly requests public
- All scripts use `set -euo pipefail` (strict bash mode)
- No credentials stored -- all auth delegated to Box CLI
- `jq` parsing uses defensive `// empty` fallback

[1.0.0]: https://github.com/jeremylongshore/box-cloud-filesystem/releases/tag/v1.0.0
