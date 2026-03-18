# Contributing

Thanks for your interest in contributing to Box Cloud Filesystem.

## Quick Start

1. Fork the repo
2. Create a feature branch (`git checkout -b feat/my-change`)
3. Make your changes
4. Run validation (see below)
5. Commit with a descriptive message
6. Open a pull request

## What to Contribute

- Bug fixes in hook scripts
- New Box CLI operation patterns in the SKILL.md or references
- Error handling improvements
- Documentation clarifications
- Shell portability fixes (macOS compatibility)

## Validation

Before submitting, verify your changes pass:

```bash
# Lint shell scripts
shellcheck scripts/*.sh

# Validate plugin structure (if you have ccpi installed)
ccpi validate --strict

# Validate SKILL.md (if you have the marketplace repo)
python3 scripts/validate-skills-schema.py --enterprise --verbose
```

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add bidirectional sync support
fix: handle basename collision in manifest lookup
docs: clarify sharing access levels
chore: update gist with latest one-pager
```

## Code Style

- Shell scripts: `set -euo pipefail`, `#!/usr/bin/env bash`
- SKILL.md: imperative voice, no first/second person in body
- Use `${CLAUDE_PLUGIN_ROOT}` for portable paths in hooks
- Use `${CLAUDE_SKILL_DIR}` for portable paths in SKILL.md references

## Pull Request Process

1. PRs are reviewed by the maintainer
2. All shell scripts must pass `shellcheck`
3. SKILL.md changes should not drop the enterprise grade below A (90+)
4. One approval required to merge

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
