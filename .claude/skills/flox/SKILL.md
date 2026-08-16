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
| `vcs` | git, gh, tig, delta, difftastic, git-absorb, git-credential-manager, jujutsu, gitu, gh-dash | Git ecosystem tools that should share a revision |
| `editors` | neovim, lua-language-server, tree-sitter | Editor + language server ABI compatibility |
| `golang` | go, golangci-lint | Linter must match Go version |
| `node` | nodejs, bun | JS runtimes |
| `lua` | luarocks, lua | Lua ecosystem |
| `python` | uv | Standalone; updates frequently |
| `linters` | typos, dotenv-linter | Standalone linters |
| `cloud` | awscli2 | Large package, independent update cadence |
| `pinned` | granted | Version-pinned packages |
| `claude` | claude-code (`flox/claude-code`) | Fast-moving, unfree; sourced from the flox catalog (see Catalogs below) |
| `opencode` | opencode | Fast-moving AI tooling; needs independent upgrades |
| `gui` | aerospace, wezterm, obsidian, halloy | GUI apps — keep separate from CLI tools |

### When to create a new group

Create a new group when:
- A package updates much faster or slower than its current group
- Two packages have ABI/version compatibility requirements with each other but not with their current group
- A package is blocking upgrades of unrelated packages in its group
- A large package (like awscli2) is slowing resolution for the whole group

## Catalogs (nixpkgs vs flox)

Flox resolves packages from **catalogs**. Which one a package comes from is determined by its `pkg-path`:

- **nixpkgs** (default) — a bare `pkg-path` like `"claude-code"` or `"ripgrep"` resolves from nixpkgs.
- **flox** — prefixing with `flox/` (e.g. `"flox/claude-code"`) resolves from the flox catalog, curated by Flox. It often tracks fast-moving upstream tools **ahead of** nixpkgs.

`flox search <pkg>` lists both variants when they exist:

```bash
$ flox search claude-code
claude-code        Agentic coding tool that lives in your terminal...   # nixpkgs
flox/claude-code   Agentic coding tool from Anthropic                    # flox catalog
```

Compare their latest versions before choosing a source:

```bash
flox show claude-code        # Catalog: nixpkgs   → Latest: 2.1.193
flox show flox/claude-code   # Catalog: flox      → Latest: 2.1.196
```

To switch a package's source, change only its `pkg-path` (the install id / attribute name stays the same), then apply and re-lock:

```toml
claude-code = { pkg-path = "flox/claude-code", pkg-group = "claude" }
```

```bash
chezmoi apply ~/.flox/env/manifest.toml
flox activate -- claude --version   # fresh activation re-locks; confirm the new version
chezmoi add ~/.flox/env/manifest.lock
```

`claude-code` is sourced from the flox catalog for exactly this reason — it stays current faster than nixpkgs.

## TOML style convention

The manifest uses a **hybrid style**:
- **Dot notation** for toplevel packages (no pkg-group, one line each)
- **Inline tables** for grouped packages (pkg-group visible at a glance)

```toml
# toplevel — dot notation
ripgrep.pkg-path = "ripgrep"

# grouped — inline table
git = { pkg-path = "git", pkg-group = "vcs" }
go = { pkg-path = "go", version = "1.25", pkg-group = "golang" }
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

### Constrain a version (`>=` floor)

```toml
mypackage.pkg-path = "mypackage"
mypackage.version = ">=1.2.3"
```

Floors are a **forward ratchet**, not a minimum requirement — they stop a fresh resolve from landing on a year-old version. They're the right tool for a package sharing a group with others, because an open-ended floor imposes no upper bound and any number of them can be satisfied by one snapshot. Exact pins can't make that promise, which is why the one-pin-per-group rule exists.

Renovate manages both forms (see `renovate.json`): one custom manager bumps exact pins, another rewrites `>=X` to `>=Y` in place. Adding either form is all it takes to put a package under Renovate — but don't convert a floor to an exact pin just to get updates, since the floor is already managed and the pin adds a constraint its group may not tolerate.

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

### Commit discipline for the lockfile

Flox uses a **single lockfile** for all packages. When making multiple changes (e.g., adding a package AND upgrading a group), perform each operation as a separate cycle:

1. Make change A (e.g., add package to manifest)
2. Apply, verify, sync lockfile
3. **Commit** — lockfile reflects only change A
4. Make change B (e.g., `flox upgrade editors`)
5. Sync lockfile
6. **Commit** — lockfile reflects only change B

This keeps each commit's lockfile diff attributable to that commit's manifest or upgrade change. Batching multiple operations before syncing the lockfile produces a single diff that conflates unrelated changes.

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

### A whole group silently stops upgrading

Group resolution is **atomic**: every package in a group resolves from one nixpkgs revision, so a single member that cannot resolve in newer snapshots pins the entire group. There is no error — `flox upgrade` just reports "No upgrades available", and the group omits itself from the machine-wide dry-run. It looks like everything is current.

The usual cause is a **dead `pkg-path`** — a package renamed or dropped upstream. It still resolves in old snapshots, so nothing ever fails; it just caps how far the group can move. This froze `toplevel` for a year on `darwin.apple_sdk.frameworks.CoreServices` after nixpkgs collapsed the per-framework derivations into `apple-sdk`.

**Symptom to watch for**: every `>=` floor in the group resolving to *exactly* its floor. That means the group is stuck at whatever snapshot was current when those floors were written.

**Diagnose** by comparing revision dates per group — an outlier that is months behind the rest is the tell:

```bash
python3 -c "
import json,collections
d=json.load(open('dot_flox/env/private_manifest.lock'))
g=collections.defaultdict(set)
for p in d['packages']:
    if p.get('system')=='aarch64-darwin':
        g[p.get('group','toplevel')].add(str(p.get('rev_date'))[:10])
for k,v in sorted(g.items()): print(k, sorted(v))
"
```

Then bisect with `flox lock-manifest`, which does a **fresh** resolve when given no `-l` base lockfile. Write a scratch manifest containing the group's packages, drop members one at a time, and watch the resolved `rev_date`:

```bash
flox lock-manifest scratch.toml | python3 -c "
import json,sys
print({str(p.get('rev_date'))[:10] for p in json.load(sys.stdin)['packages'] if p.get('system')=='aarch64-darwin'})
"
```

When removing one package jumps the revision forward by months, that package is the blocker. Confirm it is the *pkg-path* and not a version constraint by also trying a run with all `>=` floors stripped — if the revision doesn't budge, the constraints were never the cause.

**Fix**: remove the dead entry, or if it is genuinely needed, isolate it into its own `pkg-group` so it can only freeze itself. Check whether the package is now a stub before keeping it — `ls $(dirname)` on its store path is often just a README saying the thing was deprecated.

### Resolution fails for a group

A group may fail to resolve if packages within it have conflicting version requirements.

**Fix**: Split the conflicting package into its own group, or relax version constraints.

Note the asymmetry between the two failure modes above: **exact pins** in a shared group cause loud `constraints too tight` failures, while a **dead pkg-path** causes a silent freeze. Both argue for isolating anything unusual into its own group.

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

### GUI app hotkeys/permissions stop working after `gui` group upgrade

Upgrading the `gui` group (aerospace, wezterm, obsidian, halloy) rebuilds each app at a **new `/nix/store/<hash>-<pkg>-<version>` path**. macOS ties TCC permissions (Accessibility, Input Monitoring, etc.) to that specific bundle path, so a permission granted to the old path does not carry over — the app silently loses it, even though System Settings may still show a (now-stale) entry checked.

Symptom for AeroSpace specifically: global hotkeys (e.g. `alt-2`) stop being intercepted and fall through to normal macOS key behavior (e.g. `alt-2` types `™` instead of switching workspaces), while the AeroSpace server itself is otherwise healthy (`aerospace list-workspaces` still responds).

**Fix**: After any `gui` group upgrade, re-grant Accessibility (System Settings → Privacy & Security → Accessibility) for the affected app — remove the stale entry with `-` and re-add it from its current `/nix/store/...` path if simply toggling doesn't work, then relaunch the app.
