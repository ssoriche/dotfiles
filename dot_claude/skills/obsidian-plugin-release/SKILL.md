---
name: obsidian-plugin-release
description: Guide for setting up and managing the release process for Obsidian plugins. Use when adding a release workflow to a new plugin, debugging release issues, or understanding the standardized Makefile/version-bump/GitHub Actions pattern used across ssoriche's Obsidian plugin repos.
argument-hint: [task]
---

# Obsidian Plugin Release Process

## Overview

Two-phase release workflow:
1. `make release VERSION=x.y.z` — creates a release PR
2. `make tag-release VERSION=x.y.z` — creates the tag after PR is merged

Tag push triggers the GitHub Actions release workflow.

---

## Required Files (per repo)

| File | Purpose |
|------|---------|
| `Makefile` | `release` and `tag-release` targets with all guards |
| `version-bump.mjs` | Lifecycle hook: updates `manifest.json` + `versions.json` |
| `versions.json` | Maps version → minAppVersion for Obsidian compatibility |
| `manifest.json` | Obsidian plugin manifest (must have `minAppVersion`) |
| `package.json` | Must have `"version"` script that invokes `version-bump.mjs` |
| `.github/workflows/release.yml` | Builds plugin and publishes GitHub release on tag push |

---

## Layout Variants

Three layouts encountered, each requiring path adjustments:

**Flat** (task-shelf, slack-emoji): All files at repo root. No path prefixes needed.

**Hybrid** (backup-git): Root `package.json` manages scripts; plugin code in `plugin/`. version-bump.mjs uses `plugin/` prefix. `git add` in the `version` script uses `plugin/manifest.json plugin/versions.json`.

**Monorepo** (sync-pg): `plugin/` and `server/` subdirectories. version-bump.mjs lives in `plugin/`, uses relative paths. Both plugin and server are co-versioned — `make release` bumps both; `make tag-release` validates both.

---

## Makefile Guards

### `release` target

- VERSION required and semver-validated: `grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.-]+)?(\+[A-Za-z0-9.-]+)?$'`
- Working directory must be clean
- Current branch must be `main`
- Local main must be in sync with `origin/main` (fetch + SHA compare)
- Creates branch `release/v$(VERSION)`, runs `bun pm version "$(VERSION)" --no-git-tag-version`, stages files, commits, pushes, creates PR

### `tag-release` target

- VERSION required and semver-validated (same regex)
- Current branch must be `main`
- Local main must be in sync with `origin/main`
- All package.json(s) and manifest.json must match VERSION (use `jq -r '.version' file.json`)
- No local or remote tag with this name already exists
- Creates annotated tag, pushes it

---

## PR Body

Use `printf | --body-file -` (not `$$'...'` ANSI-C quoting — not POSIX-portable):

```makefile
@printf '## Summary\n\n- Bump version to $(VERSION)\n\nAfter merging, run:\n\n    make tag-release VERSION=$(VERSION)\n' \
    | gh pr create --title "chore: bump version to $(VERSION)" --body-file -
```

---

## `bun pm version` (NOT `bun version`)

`bun version` only prints bun's own version. The correct command is:

```
bun pm version "$(VERSION)" --no-git-tag-version
```

This sets `npm_package_version` env var and runs the `"version"` script in package.json.

---

## version-bump.mjs Pattern

```js
import { readFileSync, writeFileSync } from "fs";
const targetVersion = process.env.npm_package_version;
// validate: required, manifest is object, minAppVersion present, versions is object
// write manifest.json with new version
// write versions.json: update entry if versions[targetVersion] !== minAppVersion
```

Key validations before any writes:
- `npm_package_version` must be set (run via `bun pm version`)
- manifest must be a non-null, non-array object
- manifest must have `minAppVersion`
- versions must be a non-null, non-array object
- Use `versions[targetVersion] !== minAppVersion` (not `!(targetVersion in versions)`) to ensure stale entries are updated

---

## package.json `"version"` script

**Flat repos:**
```json
"version": "bun version-bump.mjs && git add manifest.json versions.json"
```

**Hybrid (backup-git):**
```json
"version": "bun version-bump.mjs && git add plugin/manifest.json plugin/versions.json"
```

**Monorepo plugin subdir (sync-pg):**
```json
"version": "bun version-bump.mjs && git add manifest.json versions.json"
```
(runs from `plugin/`, so paths are relative to plugin/)

---

## GitHub Actions release.yml Pattern

- Trigger: `push: tags: ['v*']`
- Pin bun: `BUN_VERSION: '1.2'` env + `oven-sh/setup-bun@v2` with `bun-version: ${{ env.BUN_VERSION }}`
- Use `actions/upload-artifact@v7` and `actions/download-artifact@v8`
- `concurrency` block on the `create-release` job: `group: create-release-${{ github.ref_name }}`, `cancel-in-progress: false`

CHANGELOG extraction — graceful fallback if file missing or section absent:
```yaml
if [ ! -f CHANGELOG.md ]; then echo "has_notes=false" >> "$GITHUB_OUTPUT"
else
  awk -v ver="$version" 'index($0, "## [" ver "]") == 1 {found=1; next} found && /^## \[/{exit} found' CHANGELOG.md > release-notes.md
  # emit has_notes=true/false based on whether file is non-empty
fi
```

Two release steps: one using `body_path: release-notes.md`, one with `generate_release_notes: true`.

Artifact upload paths are relative to repo root; download path is `plugin-release/`; release file globs must match the full relative path in artifact.

---

## Artifact Path Note

When `upload-artifact` lists individual files like `plugin/build/main.js`, the artifact preserves the full relative path. After `download-artifact` to `plugin-release/`, files land at `plugin-release/plugin/build/main.js` — **not** `plugin-release/main.js`.

---

## devbox Wrapping

Repos **with** devbox (slack-emoji, sync-pg): wrap ALL commands with `devbox run --`, including `jq`:
```makefile
$$(devbox run -- jq -r '.version' package.json)
```

Repos **without** devbox (task-shelf, backup-git): use bare commands.

`jq` is available on macOS and GitHub Actions ubuntu-latest without installation.

---

## SHELL Directive

All Makefiles must include `SHELL := /bin/bash` at the top to ensure bash semantics for the recipe shells (needed for `$$`, `$$(...)` expansions). This must come before any targets.
