# Box Cloud Filesystem -- One-Pager & Operator Audit

**Version:** 1.0.0 | **License:** MIT | **Author:** Jeremy Longshore / Intent Solutions
**Enterprise Grade:** A (92/100) | **Created:** 2026-03-17

---

## One-Pager

### What

Claude Code plugin that gives AI agents transparent, safety-guarded access to [Box](https://www.box.com/) cloud storage via the official Box CLI (`@box/cli`). Works with any Box account -- personal, business, or enterprise.

### Why

Box CLI gives raw API access, but raw access without guidance leads to duplicated files, public sharing by default, stale manifests, and silent overwrites. This plugin wraps Box CLI with:

- **Transparent sync hooks** -- auto-upload files on every Write/Edit. Agents never think about Box.
- **An operator's manual (SKILL.md)** -- teaches agents explicit Box operations with trust-zone-based safety guardrails.

### How

**Transparent mode** -- initialize a workspace, then every Write or Edit inside it auto-syncs to Box via PostToolUse hooks. No `box` commands needed.

**Explicit mode** -- search, download, share, or organize files using Box CLI commands directly, guided by the SKILL.md.

### Install

```bash
ccpi install box-cloud-filesystem           # From Tons of Skills marketplace
# or
git clone https://github.com/jeremylongshore/box-cloud-filesystem.git  # Standalone
```

Prerequisites: `npm install --global @box/cli` + `jq` + `box login`

### File Tree

```
box-cloud-filesystem/
+-- .claude-plugin/
|   +-- plugin.json                  metadata
+-- hooks/
|   +-- hooks.json                   PostToolUse + Stop events
+-- scripts/
|   +-- box-init-workspace.sh        pull folder + build manifest
|   +-- box-sync-on-write.sh         hook: upload on Write/Edit
|   +-- box-sync-summary.sh          hook: print sync report
+-- skills/
|   +-- box-cloud-filesystem/
|       +-- SKILL.md                 core skill (A, 92/100)
|       +-- references/
|           +-- operations-guide.md  CLI commands + errors
|           +-- sync-pattern.md      sync workflow + examples
+-- README.md                        setup + quick start
+-- LICENSE                          MIT
```

### Key Features

- **Trust zones** -- operations classified as Read / Create / Update / Expose / Destructive
- **Version-first updates** -- `files:versions:upload` over re-upload to preserve history
- **Narrow sharing defaults** -- `collaborators`, never `open` unless user explicitly says "public"
- **Manifest-based sync** -- filename-to-file-ID mapping prevents duplicates and catches conflicts
- **Progressive disclosure** -- concise SKILL.md with detailed references/ for deep dives

### Compatibility

Claude Code, Codex, OpenClaw

### Links

| Resource | URL |
|----------|-----|
| GitHub repo | https://github.com/jeremylongshore/box-cloud-filesystem |
| Release v1.0.0 | https://github.com/jeremylongshore/box-cloud-filesystem/releases/tag/v1.0.0 |
| Marketplace | https://tonsofskills.com |
| Box CLI | https://github.com/box/boxcli |
| Box Developer Docs | https://developer.box.com/ |

---

# Operator-Grade System Audit

**Audit Date:** 2026-03-17
**Auditor:** Claude Opus 4.6 (automated)
**Repo:** `git@github.com:jeremylongshore/box-cloud-filesystem.git`
**Version:** 1.0.0 (3 commits, created 2026-03-17)
**Repo Size:** ~25 KB across 10 files, 761 total source lines

---

## 1. Executive Summary

### Business Purpose

Agents that can read and write files locally have no native cloud storage capability. Box CLI gives raw API access, but raw access without guidance leads to duplicated files, public sharing by default, stale manifests, and silent overwrites. This plugin wraps Box CLI with transparent sync hooks and an operator's manual with trust-zone-based safety guardrails.

### Tech Foundation

| Layer | Technology |
|-------|-----------|
| Runtime dependency | `@box/cli` (npm global), `jq` |
| Plugin format | Claude Code AI instruction plugin (Markdown + shell hooks) |
| Hook system | `hooks.json` -- PostToolUse (Write/Edit) and Stop lifecycle hooks |
| Shell scripts | Bash (`set -euo pipefail`), reads JSON from stdin via `jq` |
| Skill spec | SKILL.md with YAML frontmatter (2026 spec), two reference documents |
| Auth | Box OAuth, JWT, CCG, Developer Token |
| License | MIT |

---

## 2. Architecture

### Component Architecture

```
                    +--------------------------+
                    |     Agent Runtime        |
                    |  (Claude Code / Codex)   |
                    +------+---+-------+-------+
                           |   |       |
              SKILL.md     |   |       |    hooks.json
           (context inject)|   |       | (lifecycle hooks)
                           v   v       v
                    +------+---+-------+-------+
                    |                           |
      +-------------+  Transparent Mode        |
      |  PostToolUse |  (Write/Edit triggers)   |
      |  hook fires  +-----------+-------------+
      +------+-------+          |
             |                  |  Stop hook fires
             v                  v
    +--------+--------+  +-----+----------+
    | box-sync-on-    |  | box-sync-      |
    | write.sh        |  | summary.sh     |
    | - reads stdin   |  | - reads .log   |
    | - checks config |  | - prints count |
    | - uploads file  |  | - clears log   |
    | - logs action   |  +----------------+
    +--------+--------+
             |
             v
    +--------+--------+
    | Box API          |
    | (via @box/cli)   |
    +------------------+
```

### Hook Registration

| Hook | Event | Matcher | Timeout | Async |
|------|-------|---------|---------|-------|
| `box-sync-on-write.sh` | PostToolUse | `Write\|Edit` | 15s | Yes (non-blocking) |
| `box-sync-summary.sh` | Stop | `.*` | 10s | No (synchronous) |

### Data Flow

```
box-init-workspace.sh
  +-- Downloads Box folder contents to local workspace
  +-- Queries Box API for folder items (name, id, content_modified_at)
  +-- Writes .box-manifest.json to workspace root
  +-- Writes ~/.box-cloud-filesystem.json (global config for hooks)

box-sync-on-write.sh (per Write/Edit)
  +-- Reads tool_input JSON from stdin (file_path)
  +-- Reads ~/.box-cloud-filesystem.json (workspace path, folder ID)
  +-- Guards: exits if file not inside workspace or config missing
  +-- Reads .box-manifest.json to look up file ID by basename
  +-- Known file: box files:versions:upload (preserves history)
  +-- New file: box files:upload, appends to manifest
  +-- Appends action to .box-sync.log

box-sync-summary.sh (on Stop)
  +-- Reads sync log, prints summary, clears log
```

### State Files

| File | Location | Purpose |
|------|----------|---------|
| `.box-cloud-filesystem.json` | `$HOME/` | Workspace path, folder ID, init timestamp |
| `.box-manifest.json` | `$WORKSPACE/` | File-to-ID mapping for sync decisions |
| `.box-sync.log` | `$WORKSPACE/` | Append-only log of sync actions |

---

## 3. Directory Analysis

| File | Lines | Purpose |
|------|-------|---------|
| `SKILL.md` | 177 | Core skill -- trust zones, safety rules, quick reference, sync pattern, examples |
| `operations-guide.md` | 153 | Full CLI reference organized by trust zone + 13-scenario error table |
| `sync-pattern.md` | 110 | 5-step pull/work/push workflow + conflict detection + 3 worked examples |
| `README.md` | 97 | Install, prerequisites, component table, quick start, links |
| `box-sync-on-write.sh` | 65 | PostToolUse handler -- new vs existing file, manifest update, logging |
| `box-init-workspace.sh` | 50 | Downloads folder, builds manifest, writes config, validates auth |
| `hooks.json` | 35 | PostToolUse (Write/Edit) + Stop hook registration |
| `box-sync-summary.sh` | 29 | Reads sync log, prints summary, clears log |
| `plugin.json` | 24 | Plugin manifest (name, version, author, keywords) |
| `LICENSE` | 21 | MIT 2026 |
| **Total** | **761** | |

---

## 4. Security and Access

### Trust Zone Model

| Zone | Risk | Agent Behavior |
|------|------|---------------|
| **Read** | None | Execute freely -- search, list, download, metadata |
| **Create** | Low | Verify parent folder ID before uploading |
| **Update** | Medium | Use file ID (not name), prefer version upload |
| **Expose** | High | Default `collaborators`; never `open` unless explicit |
| **Destructive** | Critical | Only on explicit request; summarize plan first |

### Safety Rules

1. Inspect folder contents before writing
2. Use file IDs, not filenames (names not unique in Box)
3. Prefer version uploads over re-uploads
4. Never delete unless explicitly requested
5. Never create open shared links by default
6. Summarize bulk operations before executing
7. Report file ID, folder ID, action type after every write
8. Stop and ask if unexpected files in target folder

### Script Security

- All scripts use `set -euo pipefail` (strict mode)
- Path containment guard: sync hook only fires for files inside configured workspace
- No credentials stored -- all auth delegated to Box CLI
- `jq` parsing uses defensive `// empty` fallback
- No outbound network calls beyond `box` CLI

---

## 5. Current State Assessment

### Quality Scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Completeness | 9/10 | All components present, both modes covered |
| Correctness | 8/10 | Sound logic, some edge cases (see below) |
| Safety | 9/10 | Five-tier trust zones, sharing guardrails, path containment |
| Documentation | 9/10 | README + SKILL.md + 2 reference docs |
| Maintainability | 8/10 | Simple bash, no build step, no deps beyond box/jq |
| Portability | 8/10 | Uses `${CLAUDE_PLUGIN_ROOT}`, bash-only |
| **Overall** | **8.5/10** | Strong first release, production-ready for happy path |

### Known Edge Cases

| Priority | Issue | Impact |
|----------|-------|--------|
| P1 | Basename collision -- manifest lookups by basename only | Wrong file version-uploaded if same name in subdirs |
| P1 | Race condition -- async PostToolUse hooks can overlap on manifest | Concurrent writes could corrupt manifest |
| P2 | Singleton config -- one workspace at a time | Second init overwrites first |
| P3 | `date -Iseconds` -- GNU-only, not macOS-portable | Minor portability issue |

---

## 6. Recommendations

### Near-Term (v1.1)

| Priority | Recommendation |
|----------|---------------|
| P1 | Subdirectory-aware manifest (relative paths, not basenames) |
| P1 | `flock` serialization guard for concurrent manifest writes |
| P2 | `.gitignore` excluding state files |
| P2 | Multi-workspace support (config keyed by path) |
| P3 | `shellcheck` CI |

### Medium-Term (v1.2+)

| Priority | Recommendation |
|----------|---------------|
| P2 | Bidirectional sync (pull remote changes + conflict detection) |
| P2 | Add CLAUDE.md to repo |
| P3 | bats tests for shell scripts |
| P3 | Portable `date` handling for macOS |

### Long-Term (v2.0)

| Priority | Recommendation |
|----------|---------------|
| P3 | Selective sync via `.boxignore` |
| P3 | Webhook-based real-time sync for enterprise |
| P3 | MCP server variant for non-hook platforms |

---

## 7. Quick Reference

### Key Commands

| Task | Command |
|------|---------|
| Install plugin | `ccpi install box-cloud-filesystem` |
| Install Box CLI | `npm install --global @box/cli` |
| Authenticate | `box login` |
| Verify auth | `box users:get --me` |
| Init workspace | `./scripts/box-init-workspace.sh FOLDER_ID /tmp/box-workspace` |
| List root | `box folders:items 0 --json` |
| Search | `box search "query" --type file --json` |
| Download | `box files:download FILE_ID --destination ./` |
| Upload new | `box files:upload ./file.txt --parent-id FOLDER_ID` |
| Update existing | `box files:versions:upload FILE_ID ./file.txt` |
| Share (narrow) | `box files:share FILE_ID --access collaborators` |

### First-Use Checklist

- [ ] Install Box CLI: `npm install --global @box/cli`
- [ ] Install jq
- [ ] Authenticate: `box login`
- [ ] Verify: `box users:get --me`
- [ ] Install plugin: `ccpi install box-cloud-filesystem`
- [ ] Find target folder: `box folders:items 0 --json`
- [ ] Init workspace: `box-init-workspace.sh FOLDER_ID /tmp/box-workspace`
- [ ] Write a test file to verify hook sync
- [ ] Confirm file appears in Box web UI

---

*Audit produced by automated analysis of all 10 source files. All data drawn from the actual codebase.*
