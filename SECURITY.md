# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

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

- **No credentials stored** — all authentication is delegated to Box CLI (`@box/cli`)
- **Path containment** — the sync hook only fires for files inside the configured workspace directory
- **Strict bash mode** — all scripts use `set -euo pipefail`
- **Defensive parsing** — `jq` commands use `// empty` fallback to handle malformed input
- **Narrow sharing defaults** — sharing defaults to `collaborators` access, never `open`/public
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
