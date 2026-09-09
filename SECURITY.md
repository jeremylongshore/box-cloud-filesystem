# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 2.0.x   | Yes       |
| 1.0.x   | No        |

## Reporting a Vulnerability

If you discover a security vulnerability in this plugin, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, email **jeremy@intentsolutions.io** with:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

You will receive a response within 48 hours. We will work with you to understand the issue and coordinate a fix before any public disclosure.

## Security Design

This plugin is designed with a safety-first approach:

- **No Box credentials stored** — authentication is delegated to Box CLI (`@box/cli`)
- **No hook uploads** — Write/Edit hooks only queue local relative paths for review
- **Path containment** — queue hooks reject paths outside the canonical workspace and reject symlinks
- **Sensitive-path exclusions** — hidden and credential-like filenames are not queued
- **Restricted config** — local non-secret workspace configuration is written with mode 0600
- **Strict bash mode** — all scripts use `set -euo pipefail`
- **Defensive parsing** — `jq` commands use `// empty` fallback to handle malformed input
- **Narrow sharing examples** — examples use `collaborators`; audience changes require confirmation
- **Trust zones** — operations classified by risk level (Read/Create/Update/Expose/Destructive)

## Scope

This policy covers:

- The plugin source code in this repository
- The hook scripts (`scripts/*.sh`)
- The SKILL.md content that guides agent behavior

This policy does **not** cover:

- The Box CLI itself (`@box/cli`) — report issues to [box/boxcli](https://github.com/box/boxcli/security)
- The Box platform — report issues via [Box's security page](https://www.box.com/security)
- The Claude Code runtime — report issues to [Anthropic](https://www.anthropic.com)
