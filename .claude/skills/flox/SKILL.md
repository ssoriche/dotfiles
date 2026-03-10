---
name: flox
description: Manage Flox packages in the chezmoi dotfiles repository. Use when adding, removing, upgrading, or troubleshooting Flox packages.
argument-hint: "<action> [package]"
disable-model-invocation: true
---

# Flox Package Management

## How Flox works in this repo

The Flox manifest and lockfile live in the **chezmoi source directory**:

```
Source:  ~/.local/share/chezmoi/dot_flox/env/manifest.toml
         ~/.local/share/chezmoi/dot_flox/env/private_manifest.lock
Deploy:  ~/.flox/env/manifest.toml
         ~/.flox/env/manifest.lock
```

**Always edit the chezmoi source manifest**, then apply. Never edit `~/.flox/env/manifest.toml` directly — chezmoi will overwrite it.

The **lockfile is tracked in chezmoi** so that exact resolved versions are preserved across machines. After any `flox upgrade`, copy the updated lockfile back into chezmoi:

```bash
chezmoi add ~/.flox/env/manifest.lock
```

## Package group strategy

Packages are organized into **pkg-groups** so they can resolve against independent nixpkgs revisions. This prevents slow-moving or large packages from blocking upgrades of fast-moving ones.

| Group | Contents | When to use |
|---|---|---|
| `toplevel` (default) | Stable CLI tools (ripgrep, fd, bat, jq, etc.) | No `pkg-group` needed — this is the implicit default |
| `git` | git, gh, tig, delta, difftastic, git-absorb, git-credential-manager, jujutsu, gitu | Git ecosystem tools that should match git's version |
| `editors` | neovim, lua-language-server, tree-sitter | Editor + language server ABI compatibility |
| `go` | go, golangci-lint | Linter must match Go version |
| `node` | nodejs, bun | JS runtimes |
| `lua` | luarocks, lua | Lua ecosystem |
| `python` | uv | Standalone; updates frequently |
| `linters` | typos, dotenv-linter | Standalone linters |
| `cloud` | awscli2 | Large package, independent update cadence |
| `pinned` | granted | Version-pinned packages |
| `claude` | claude-code | Fast-moving, unfree; needs independent upgrades |
| `gui` | aerospace, wezterm, obsidian, halloy | GUI apps — keep separate from CLI tools |

### When to create a new group

Create a new group when:
- A package updates much faster or slower than its current group
- Two packages have ABI/version compatibility requirements with each other but not with their current group
- A package is blocking upgrades of unrelated packages in its group
- A large package (like awscli2) is slowing resolution for the whole group

## TOML style convention

The manifest uses a **hybrid style**:
- **Dot notation** for toplevel packages (no pkg-group, one line each)
- **Inline tables** for grouped packages (pkg-group visible at a glance)

```toml
# toplevel — dot notation
ripgrep.pkg-path = "ripgrep"

# grouped — inline table
git = { pkg-path = "git", pkg-group = "git" }
go = { pkg-path = "go", version = "1.24", pkg-group = "go" }
```

## Common operations

### Add a package

```toml
# Toplevel (no group needed) — dot notation
mypackage.pkg-path = "mypackage"

# Grouped — inline table
mypackage = { pkg-path = "mypackage", pkg-group = "appropriate-group" }
```

Then apply and install:
```bash
chezmoi apply ~/.flox/env/manifest.toml
flox install mypackage  # or just let flox resolve on next activation
```

### Remove a package

1. Delete the relevant line(s) from `dot_flox/env/manifest.toml`
2. Apply: `chezmoi apply ~/.flox/env/manifest.toml`
3. Uninstall: `flox uninstall mypackage`

### Upgrade packages

**Always dry-run first** — flox may propose downgrades if a group resolves to an older nixpkgs revision:

```bash
flox upgrade --dry-run              # check ALL groups for downgrades
flox upgrade --dry-run git          # check a specific group
```

If the dry-run looks good, apply:

```bash
flox upgrade git                    # upgrade a specific group
flox upgrade claude-code            # single package (only if not grouped with others)
```

**After upgrading, always sync the lockfile back to chezmoi**:

```bash
chezmoi add ~/.flox/env/manifest.lock
```

**Avoid** `flox upgrade` with no arguments unless you've verified the dry-run shows no downgrades. Prefer upgrading groups individually.

### Pin a version

```toml
mypackage = { pkg-path = "mypackage", version = "1.2.3", pkg-group = "pinned" }
```

### Search for available packages

```bash
flox search <query>
flox show <package>  # detailed info including available versions
```

### Check current state

```bash
flox list           # all installed packages with versions
flox list -c        # show config (groups, options)
```

## Workflow

1. **Edit** the chezmoi source: `~/.local/share/chezmoi/dot_flox/env/manifest.toml`
2. **Apply** via chezmoi: `chezmoi apply ~/.flox/env/manifest.toml`
3. **Verify** resolution: `flox list`
4. **Sync lockfile**: `chezmoi add ~/.flox/env/manifest.lock`
5. **Commit** both manifest and lockfile in the chezmoi repo

## Troubleshooting

### `flox upgrade` proposes downgrades

This happens when a group (especially `toplevel`) resolves to a different nixpkgs revision than what's in the lockfile. Splitting packages into groups changes which revision each group lands on — fewer constraints means flox has more freedom to pick a revision, and it may pick an older one.

**Prevention**: Always `flox upgrade --dry-run` first. The lockfile preserves the current good versions.

**Fix if it happens**: Restore the lockfile from chezmoi:
```bash
chezmoi apply ~/.flox/env/manifest.lock
```

### `flox upgrade` doesn't pick up a new version

This usually means the package shares a nixpkgs revision with other packages (the `toplevel` group) and that revision doesn't have the newer version yet.

**Fix**: Move the package to its own `pkg-group` so it resolves independently:

```toml
mypackage = { pkg-path = "mypackage", pkg-group = "mypackage" }  # isolate into own group
```

Then: `chezmoi apply ~/.flox/env/manifest.toml && flox upgrade mypackage`

### Resolution fails for a group

A group may fail to resolve if packages within it have conflicting version requirements.

**Fix**: Split the conflicting package into its own group, or relax version constraints.

### Package not found

```bash
flox search <name>   # verify exact package name
flox show <name>     # check if it exists in the catalog
```

Some packages use different names in nixpkgs (e.g., `_1password-cli` not `1password-cli`).

### Flake-based packages

Packages pinned to specific git commits or repos use `flake` instead of `pkg-path`:

```toml
mypackage.flake = "github:owner/repo/ref#output"
```

These bypass pkg-groups entirely — each flake resolves independently.
