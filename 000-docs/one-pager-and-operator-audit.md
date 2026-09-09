# Box Cloud Filesystem — One-Pager and Operator Audit

**Version:** 2.0.0 | **License:** MIT | **Author:** Jeremy Longshore / Intent Solutions
**Review date:** 2026-09-09 | **Marketplace grade:** A

## One-pager

Box Cloud Filesystem is an Agent Skill and Claude Code plugin for operating the
official [Box CLI](https://github.com/box/boxcli). It supports search, download,
upload, version updates, and sharing through explicit commands with numeric Box
IDs, narrow access defaults, and post-operation receipts.

The optional Claude Code hooks are deliberately queue-only. A Write or Edit
inside the configured workspace adds an eligible relative path to
`.box-sync-pending`. The Stop hook reports that queue. Neither hook invokes Box
or performs a remote write.

### Install

```bash
npx skills add jeremylongshore/box-cloud-filesystem --skill box-cloud-filesystem
```

```text
/plugin marketplace add jeremylongshore/box-cloud-filesystem
/plugin install box-cloud-filesystem@box-cloud-filesystem
```

Requirements are Node.js 18+, Box CLI 4.x, and authenticated Box access. The
workspace queue additionally requires Bash and `jq`.

### Operating model

| Zone | Examples | Required boundary |
|---|---|---|
| Read | search, list, metadata, download | Remain within requested scope |
| Create | upload, create folder | Verify parent ID and collisions |
| Update | version upload, move, copy | Verify item ID and remote modification time |
| Expose | shared link, collaborator access | Confirm audience and access settings |
| Destructive | delete, bulk move | Explicit request and exact target summary |

Use IDs rather than names, prefer a version upload for an existing file, never
infer remote deletion from a missing local file, and never create an open link
without explicit approval.

### Quick reference

```bash
box users:get me --json
box folders:items FOLDER_ID --json
box search "query" --type file --json
box files:download FILE_ID --destination LOCAL_PATH
box files:upload LOCAL_PATH --parent-id FOLDER_ID --json
box files:versions:upload FILE_ID LOCAL_PATH --json
box files:share FILE_ID --access collaborators --json
```

For a reviewed workspace, initialize an approved folder and local target:

```bash
./scripts/box-init-workspace.sh FOLDER_ID /tmp/box-workspace
```

Before syncing pending paths, re-read remote metadata, classify each path as
create/update/conflict/skip, present the plan, and obtain approval. Clear only
queue entries backed by verified Box receipts.

## Operator audit

### Architecture and data flow

```text
explicit request ──> SKILL.md guardrails ──> Box CLI ──> Box API

Write/Edit event ──> local containment and exclusion checks
                 └─> .box-sync-pending (local only)

Stop event ────────> pending-path summary (local only)
```

| Component | Responsibility |
|---|---|
| `SKILL.md` | Operation workflow, approval boundaries, receipts, recovery |
| `hooks/hooks.json` | Register queue and summary handlers |
| `box-init-workspace.sh` | Validate, download, manifest, and write mode-0600 config |
| `box-sync-on-write.sh` | Queue safe relative paths without any Box call |
| `box-sync-summary.sh` | Report pending paths without clearing or uploading |

Configuration lives at
`${XDG_CONFIG_HOME:-$HOME/.config}/box-cloud-filesystem/config.json` and records
the canonical workspace, Box folder ID, initialization time, `queue_changes`,
and the invariant `auto_upload: false`. The downloaded manifest keeps Box item
IDs and modification times for later reviewed comparisons; it is not authority
to overwrite a newer remote version.

### Security review

- Hooks cannot cause a remote write; only explicit `box` commands can.
- Canonical-path containment prevents a sibling-prefix escape.
- Symlinks, hidden paths, and credential-like filenames are excluded.
- Box CLI owns authentication; scripts do not collect or print tokens.
- Local configuration is atomically written with mode 0600.
- Sharing defaults to collaborators-only and public exposure requires approval.
- Deletes, bulk changes, conflicts, and scope widening require explicit approval.

### Failure and recovery

| Failure | Response |
|---|---|
| Authentication expired | Run `box login`; never request a token in chat |
| 403 | Report the scope/admin boundary; do not widen access automatically |
| Missing ID | Re-list the approved parent and resolve the numeric ID |
| Name collision | Version the intended file or use an approved distinct name |
| Remote changed | Stop and ask whether to keep remote, local, or both |
| Partial bulk failure | Re-list, report confirmed receipts, retry unresolved items only |
| Queue hook failure | Preserve local work and report that no upload occurred |

### Release gates

- JSON manifests and hook schema parse and validate.
- `shellcheck scripts/*.sh` passes.
- Queue-hook regression tests prove no Box executable is invoked.
- Marketplace skill validation is Grade A and Tier-2 GREEN.
- Plugin and marketplace manifests validate with Claude Code.
- The Agent Skills CLI discovers exactly the intended public skill.

The repository is the source of truth. Gist publication is a separate,
maintainer-invoked operation and is not part of hook execution.

## Links

- Repository: https://github.com/jeremylongshore/box-cloud-filesystem
- Box CLI: https://github.com/box/boxcli
- Box developer documentation: https://developer.box.com/
- Tons of Skills: https://tonsofskills.com
