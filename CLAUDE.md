# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Reference

**Working Directory**: This is the chezmoi source directory (typically `~/.local/share/chezmoi`)

**Most Common Commands**:
```bash
chezmoi diff                          # See what would change
chezmoi apply                         # Apply all changes
chezmoi edit <target-file>            # Edit a managed file

# VSCode/Cursor settings
./vscode-settings/bin/manage-vscode-settings.fish apply all
./vscode-settings/bin/manage-vscode-settings.fish sync-extensions cursor

# Python tool management (uv via flox profile functions)
setup-tools                           # Install Python CLI tools (llm, aider)
update-tools                          # Update all uv-managed tools
```

## Repository Overview

This is a personal dotfiles repository managed with **chezmoi**, containing comprehensive macOS development environment configurations for editors (Cursor, VSCode, Neovim), terminal tools, window managers, and development utilities.

## Key Architecture Concepts

### Chezmoi Structure

This repository uses chezmoi's naming conventions for file management:

- `dot_` prefix → becomes `.` (e.g., `dot_gitconfig` → `.gitconfig`)
- `private_` prefix → files with restricted permissions (chmod 600)
- `private_dot_config` → deploys to `~/.config/`
- `.tmpl` suffix → template files processed by chezmoi
- `.chezmoiignore` → files excluded from deployment (README.md, vscode-settings/, etc.)

**Important**: Files in `.chezmoiignore` (like `vscode-settings/`) are management tools that live in the repo but are NOT deployed to the home directory.

### VSCode/Cursor Settings Architecture

The repository uses a unique modular approach for editor settings:

**Location**: `vscode-settings/` (at repository root, NOT deployed by chezmoi)

**Structure**:
- Settings are split into numbered JSON modules (01-base.json, 02-vim.json, etc.)
- Modules are merged in numerical order during deployment
- Management script: `vscode-settings/bin/manage-vscode-settings.fish`
- Extensions tracked in: `shared-extensions.txt`, `cursor-extensions.txt`, `codium-extensions.txt`

**Why this architecture**: The `vscode-settings/` directory contains source files and management tooling that should NOT be deployed by chezmoi. The actual merged settings are deployed via chezmoi templates to editor-specific locations (`~/Library/Application Support/Cursor/User/settings.json`, etc.).

### Cursor Rules System

**Modern Structure** (preferred):
- Location: `private_dot_config/cursor/rules/` (deployed to `~/.config/cursor/rules/`)
- Format: `.mdc` files with YAML frontmatter
- Categories: `core/` (always-apply rules) and `development/` (context-specific)
- Deployment: `chezmoi apply ~/.config/cursor/rules/`
- **Auto-loading**: Cursor automatically loads rules from `~/.config/cursor/rules/` - no manual activation needed

**Current Rules in Repository**:
- Core rules: `mantras.mdc`, `shell_environment.mdc`, `fish-shell.mdc`, `personal-preferences.mdc`
- Development rules: `conventional-commits.mdc`, `discoverability.mdc`, `coding-standards.mdc`, `git-commit-practices.mdc`, `debugging-methodology.mdc`

**Frontmatter Format**:
```yaml
---
description: Rule description
globs: ["*.ts", "*.js"]  # Optional file patterns
alwaysApply: true        # Apply to all projects
---
```

**Legacy**: `vscode-settings/cursor-global-rules.txt` exists for backward compatibility but is deprecated.

### Flox Package Management

Flox is the machine's package manager. The manifest and lockfile are managed via chezmoi:

```
Source:  dot_flox/env/manifest.toml          → ~/.flox/env/manifest.toml
         dot_flox/env/private_manifest.lock   → ~/.flox/env/manifest.lock
```

**Always edit the chezmoi source manifest**, then apply. The lockfile is tracked for reproducibility — sync it back after any upgrade.

**Key commands**:
```bash
flox search <pkg>                   # Find packages
flox show <pkg>                     # Available versions
flox list                           # Current installed versions
flox upgrade --dry-run <group>      # Always dry-run first
flox upgrade <group>                # Upgrade a specific group
chezmoi add ~/.flox/env/manifest.lock  # Sync lockfile after changes
```

**Package groups** isolate nixpkgs revisions so fast-moving or ABI-coupled packages upgrade independently.

**The one-pin-per-group rule.** Exact pins *can* share a group, but only while a single catalog snapshot satisfies all of them — `ripgrep 15.2.0` + `fd 10.4.2` locks, `ripgrep 15.2.0` + `fd 8.7.0` fails `constraints too tight`. Renovate bumps packages on independent schedules, so co-pinned versions drift apart eventually. Hence: **at most one Renovate-managed exact pin per group**, with unpinned packages free to share it as *followers* — they carry no constraint and resolve from whatever snapshot the pin picks. This rule counts *exact pins only*; `>=` floors are unbounded and don't compete, so they may share a group freely (see below).

Multi-package groups, each driven by one pin (or none):

| Group | Driver (pinned) | Followers (unpinned) | Purpose |
|---|---|---|---|
| *toplevel* (default) | — | bat, jq, fzf, eza, etc. | Stable CLI tools — no `pkg-group` needed |
| `vcs` | — | git, gh, tig, delta, difftastic, git-absorb, gitu, gh-dash, git-credential-manager | Git ecosystem, shared revision |
| `editors` | `neovim` | lua-language-server, tree-sitter | Editor + language server ABI compatibility |
| `golang` | `go` | golangci-lint | Linter must match Go version |
| `kubernetes` | `kubie` | kustomize, krew, kns, k9s | Kubernetes tooling, shared revision |
| `node` | — | nodejs, bun | JS runtimes |
| `lua.org` | — | luarocks, lua | Lua ecosystem |
| `linters` | — | typos, dotenv-linter | Standalone analysis tools |

Single-package groups exist purely to isolate one pin so it bumps independently: `ripgrep`, `fd`, `atuin.sh`, `python` (uv), `claude` (claude-code), `herdr`, `pi-coding-agent`, `aerospace`, `wezterm`, `obsidian`, `halloy`, `maccy`, plus unpinned singletons `cloud` (awscli2), `nono`, `container`, `coderabbit-cli`, and `pinned` (granted, held deliberately).

GUI apps each get their own group rather than a shared `gui` one: nothing among them is ABI coupled, and separate groups both keep them from blocking CLI upgrades and allow independent pinning.

**TOML style**: inline tables for grouped followers (`git = { pkg-path = "git", pkg-group = "vcs" }`), dot notation for anything Renovate manages (`atuin.version = "18.17.1"`, `chezmoi.version = ">=2.70.5"`) — the custom managers in `renovate.json` only match the dot-notation `<pkg>.version = "..."` form, so an inline-table pin like `granted` is skipped and stays held.

**Catalogs**: A bare `pkg-path` (`claude-code`) resolves from the **nixpkgs** catalog. Prefixing with `flox/` (`flox/claude-code`) resolves from the **flox** catalog, which is curated by Flox and often tracks fast-moving upstream tools *ahead of* nixpkgs. `flox search <pkg>` lists both variants; compare with `flox show <pkg>` vs `flox show flox/<pkg>`. `claude-code` uses the flox catalog for this reason.

**Flake-based packages** bypass groups entirely: `zap` (follows its release tag, `github:natejsimonsen/zap/v0.1.0`, Renovate-managed via the `github-releases` datasource) and `agent-safehouse` (pinned to a specific nixpkgs commit).

**Renovate integration**: `renovate.json` resolves versions from the Flox catalog API (`api.flox.dev`) rather than repology, which tracks nixpkgs directly and runs ahead of the lagging `flox/nixpkgs` snapshots — it would propose versions Flox cannot resolve. Two custom managers cover the manifest: one bumps dot-notation exact pins, the other rewrites `>=X` floors in place to `>=Y`. So **declaring either a pin or a floor is the only step needed to put a package under Renovate**. Darwin-only packages (`aerospace`, `maccy`, `container`) use a second datasource scoped to `aarch64-darwin`, since the default rule only offers versions built for every system in `[options].systems`.

**Floors and pins are not interchangeable.** A `>=` floor is a forward ratchet with no upper bound, so any number of floored packages can share one group forever — which is why the 17 toplevel floors are safe where 17 exact pins would hit `constraints too tight`. Never "upgrade" a floor to an exact pin to get Renovate coverage; the floor is already covered, and the pin adds a constraint its group may not tolerate.

**A dead `pkg-path` freezes its whole group, silently.** Group resolution is atomic, so one member that cannot resolve in newer snapshots caps the entire group — and it produces no error, just `No upgrades available` and an omission from the machine-wide dry-run. `darwin.apple_sdk.frameworks.CoreServices` held `toplevel` on the 2025-08-06 rev for a year this way, after nixpkgs collapsed the per-framework derivations into `apple-sdk` and left behind stubs containing a lone deprecation README. The tell is every `>=` floor in a group resolving to *exactly* its floor, plus one group's `rev_date` sitting months behind the others. Note the asymmetry: exact-pin conflicts fail loudly, dead pkg-paths fail silently. Bisect with `flox lock-manifest` (no `-l` base gives a fresh resolve) — see the flox skill for the procedure.

**A broken darwin build is usually the rev, not the version.** The Woodpecker runner is linux, so CI only ever proves the linux side of a lock. obsidian 1.13.4 merged green and then failed locally with `chmod: cannot access 'Obsidian.app'`. The version was fine — the nixpkgs revision the lock had pinned (`643809054d65`) was not, and `flox upgrade obsidian` to `b7c2ada94fe9` fixed it with no version change. Reach for `flox upgrade <group>` before pinning a version back.

Neither `flox lock-manifest -l <lock>` nor `flox activate` will do this for you: both preserve the locked rev for an unchanged pin, which is what makes the relock incremental. So CI cannot self-heal a bad rev — it takes an explicit `flox upgrade <group>` followed by `chezmoi add ~/.flox/env/manifest.lock`. Note the resulting lock-only commit does not match the pipeline's `path` filter, so it lands without CI running at all.

For detailed operational docs (adding/removing packages, troubleshooting, etc.), see the flox skill: `.claude/skills/flox/SKILL.md`.

## Common Development Commands

### Chezmoi Operations

```bash
# Check what changes would be applied
chezmoi diff

# Apply all pending changes
chezmoi apply

# Apply specific directory/file
chezmoi apply ~/.config/cursor/

# Edit a managed file
chezmoi edit ~/.config/fish/config.fish

# Add new file to chezmoi management
chezmoi add ~/.new-config-file

# Check status of managed files
chezmoi status

# Update from repository
chezmoi update
```

### VSCode/Cursor Settings Management

The management script is located at: `vscode-settings/bin/manage-vscode-settings.fish`

```bash
# Apply settings to editors
./vscode-settings/bin/manage-vscode-settings.fish apply cursor
./vscode-settings/bin/manage-vscode-settings.fish apply all

# Show differences before applying
./vscode-settings/bin/manage-vscode-settings.fish diff cursor

# Sync extensions (install missing, update versions)
./vscode-settings/bin/manage-vscode-settings.fish sync-extensions cursor
./vscode-settings/bin/manage-vscode-settings.fish sync-extensions all

# Use -v flag for verbose output
./vscode-settings/bin/manage-vscode-settings.fish -v sync-extensions cursor

# Complete setup (settings + extensions) for new installation
./vscode-settings/bin/manage-vscode-settings.fish setup cursor

# Check status and installed extensions
./vscode-settings/bin/manage-vscode-settings.fish status
./vscode-settings/bin/manage-vscode-settings.fish list-extensions cursor

# Compare extension versions
./vscode-settings/bin/manage-vscode-settings.fish diff-extensions cursor

# Cursor rules management
./vscode-settings/bin/manage-vscode-settings.fish cursor-rules-status
```

### Cursor Rules Deployment

```bash
# Check rules status
./vscode-settings/bin/manage-vscode-settings.fish cursor-rules-status

# Deploy updated rules
chezmoi apply ~/.config/cursor/rules/

# Verify deployment
ls -la ~/.config/cursor/rules/core/
ls -la ~/.config/cursor/rules/development/
```

### Python Tool Management with uv

Python CLI tools are managed using `uv` within flox. Tools are installed to `~/.local/bin` and automatically available in your PATH. The `setup-tools`/`update-tools` helpers are defined in the flox `[profile]` section (`dot_flox/env/private_manifest.toml`).

**Configured Tools**:
- `llm` - CLI tool for interacting with LLMs
- `aider` - AI pair programming assistant

**Commands**:
```bash
# First-time installation of Python tools (flox profile function)
setup-tools

# Update all uv-managed tools (flox profile function)
update-tools

# Install additional tools manually
uv tool install --python python3.14 <tool-name>@latest

# List installed tools
uv tool list
```

**Note**: uv automatically downloads and manages Python 3.14 - no need to add Python to flox packages.

### Accessing Flox GUI Apps

GUI applications installed via flox (like AeroSpace, Wezterm) live in the Nix store and aren't discoverable by Spotlight. A chezmoi `run_once` script (`run_once_after_add-flox-apps-to-dock.sh`) automatically adds the Flox Apps folder to the Dock as a stack on first `chezmoi apply`.

Right-click the Dock folder to customize display (fan/grid/list, sort order).

Zap (the launcher, also flox-installed) has the same blind spot: it only scans `/Applications`, `/System/Applications`, and `~/Applications`. `private_dot_config/zap/config.json` adds the flox Applications dir to its `searchPaths` so flox GUI apps are launchable:

```json
{ "searchPaths": ["~/.flox/run/aarch64-darwin.default-run/Applications"] }
```

Use the **stable `~/.flox/run/...-run/Applications` symlink**, not a resolved `/nix/store` path — flox repoints that symlink on every generation, so the config survives upgrades (unlike the Dock tile, which canonicalizes and needs the self-healing script above). Zap picks up symlinked `.app` bundles fine and re-reads `searchPaths` on each activation; only `hotkeys` changes need an app restart.

## Development Environment

### Shell Environment

- **Primary Shell**: Fish shell
- **OS**: macOS (Darwin)
- **Package Manager**: Flox (Nix-based)
- **Dotfiles Manager**: chezmoi

### Installed Development Tools

Key tools managed via Flox (see `dot_flox/env/manifest.toml`):

- **Search/Navigation**: `fd`, `rg` (ripgrep), `fzf`, `eza`
- **Text Processing**: `bat`, `fx`, `fastgron`, `jless`, `sd`
- **Version Control**: `git`, `gh`, `tig`, `delta`, `difftastic`, `git-absorb`, `jujutsu`
- **Editors**: Neovim (nightly), `lua-language-server`
- **Shell Enhancements**: `atuin`, `direnv`
- **Development**: `nodejs`, `go`, `uv` (Python tool manager - see Python Tool Management section), `typos`, `dotenv-linter`
- **Kubernetes**: `k9s`, `kustomize`, `krew`
- **System Monitoring**: `btop`
- **Utilities**: `chezmoi`, `age`, `passage`, `tldr`, `yazi`

### Terminal Emulators

Configured in this repository:
- Wezterm (primary) - configuration in `private_dot_config/wezterm/`
- Ghostty - configuration in `private_dot_config/ghostty/`

### Window Management

- **Aerospace**: Tiling window manager - `private_dot_config/aerospace/`
- **Hammerspoon**: Lua automation - `dot_hammerspoon/`
- **Karabiner**: Keyboard customization - `private_dot_config/private_karabiner/`

### Claude Code Configuration

- **User Settings**: `dot_claude/settings.json` (deployed to `~/.claude/settings.json`)
- **Global Memories**: `dot_claude/CLAUDE.md` (deployed to `~/.claude/CLAUDE.md`)

**Configuration Options in settings.json**:
  - `includeCoAuthoredBy`: false - Disables "Co-Authored-By: Claude" in git commits
  - `permissions.allow/deny/ask`: Tool permission rules
  - `env`: Environment variables for sessions
  - `model`: Default model override
  - `outputStyle`: System prompt style configuration

**Global Memories in CLAUDE.md**:
  - User preferences and instructions that apply across all projects
  - Added via `#` prefix in Claude Code prompts (e.g., "#Always use conventional commits")
  - Automatically loaded in every Claude Code session

**Note**: Runtime state files (`.claude.json`, conversation history, project-specific state, todos) are NOT managed by chezmoi as they contain session-specific and machine-local data. UI preferences like vim mode (`editorMode`) are currently stored in `.claude.json` and not yet configurable via `settings.json`.

## Working with This Repository

### Adding New Extensions

1. Edit the appropriate extension file:
   - `vscode-settings/shared-extensions.txt` - for both editors
   - `vscode-settings/cursor-extensions.txt` - Cursor only
   - `vscode-settings/codium-extensions.txt` - VSCodium only

2. Sync extensions:
   ```bash
   ./vscode-settings/bin/manage-vscode-settings.fish sync-extensions cursor
   ```

### Modifying Editor Settings

1. Edit the appropriate JSON module in `vscode-settings/`:
   - `01-base.json` - Core editor settings
   - `02-vim.json` - Vim keybindings
   - `03-navigation.json` - File navigation
   - `03-theme.json` - UI theme
   - `04-languages.json` - Language-specific
   - `05-keybindings.json` - Custom keybindings
   - `06-whichkey.json` - Which-key menu
   - `99-overrides.json` - Final overrides

2. Validate and apply:
   ```bash
   ./vscode-settings/bin/manage-vscode-settings.fish validate
   ./vscode-settings/bin/manage-vscode-settings.fish apply all
   ```

### Adding New Cursor Rules

1. Create a new `.mdc` file in `private_dot_config/cursor/rules/core/` or `development/`

2. Add frontmatter:
   ```yaml
   ---
   description: Brief description of the rule
   globs: ["*.ts", "*.tsx"]  # Optional: file patterns
   alwaysApply: false        # true for core rules
   ---
   ```

3. Deploy the rule:
   ```bash
   chezmoi apply ~/.config/cursor/rules/
   ```

4. Verify:
   ```bash
   ./vscode-settings/bin/manage-vscode-settings.fish cursor-rules-status
   ```

### External Resources Management

The repository uses `.chezmoiexternal.toml` to manage external resources:
- Fisher plugin manager for Fish shell
- Hammerspoon Spoons
- Catppuccin themes for bat, btop, k9s
- JetBrains Mono Nerd Font
- Granted assume script

These are automatically fetched/updated by chezmoi with a 168h refresh period.

## Personal Preferences

From `private_dot_config/cursor/rules/core/personal-preferences.mdc`:

- **Indentation**: 2 spaces by default
- **Programming Style**: Prefer functional patterns over classes
- **Command-line Tools**: Prefer `fd` over `find`, `rg` over `grep`
- **Testing**: Always test changes before committing
- **Documentation**: Clear inline comments, markdown for docs
- **Version Control**: Use git worktrees for project management

## File Organization Patterns

### Chezmoi Source to Destination Mapping

```
Repository                                    → Deployed Location
─────────────────────────────────────────────────────────────────────────
dot_gitconfig                                 → ~/.gitconfig
private_dot_config/fish/config.fish           → ~/.config/fish/config.fish
private_dot_config/cursor/rules/              → ~/.config/cursor/rules/
dot_hammerspoon/                              → ~/.hammerspoon/
Library/                                      → ~/Library/
```

### Non-Deployed Files

These exist in the repo but are NOT deployed (per `.chezmoiignore`):
- `README.md` - Repository documentation
- `vscode-settings/` - Settings management tools
- `.cursor/` - AI assistant context
- `.git/`, `.vscode/`, `.idea/` - Version control and editor files

## Important Notes

1. **Never directly edit deployed files**: Always edit in the chezmoi source directory and apply changes
2. **Working directory context**: Commands in this doc assume you're in the chezmoi source directory (`~/.local/share/chezmoi`)
3. **Settings merge order matters**: VSCode/Cursor settings are merged numerically (01, 02, 03...)
4. **Cursor rules use .mdc format**: Not plain text; must include YAML frontmatter
5. **Cursor auto-loads rules**: Once deployed to `~/.config/cursor/rules/`, Cursor automatically loads them
6. **Extension versions are tracked**: Use sync-extensions to keep versions in sync
7. **The vscode-settings directory is NOT deployed**: It contains management tools only
8. **Use the management script**: Don't manually merge settings or install extensions when the script can do it
9. **Python tools managed by uv**: Run `setup-tools` (a flox profile function) to install Python CLI tools

## Troubleshooting

### Settings not applying to editor

1. Check chezmoi status: `chezmoi status`
2. Validate JSON syntax: `./vscode-settings/bin/manage-vscode-settings.fish validate`
3. Check differences: `chezmoi diff`
4. Force apply: `./vscode-settings/bin/manage-vscode-settings.fish apply all`
5. Restart the editor

### Extensions not syncing

1. Check editor CLI is available: `cursor --version` or `codium --version`
2. Run with verbose mode: `./vscode-settings/bin/manage-vscode-settings.fish -v sync-extensions cursor`
3. Check for failed extensions and clean up: `./vscode-settings/bin/manage-vscode-settings.fish remove-missing-extensions cursor`

### Cursor rules not loading

1. Check deployment: `./vscode-settings/bin/manage-vscode-settings.fish cursor-rules-status`
2. Verify frontmatter format in .mdc files
3. Ensure rules are in `~/.config/cursor/rules/` (not the source directory)
4. Deploy if needed: `chezmoi apply ~/.config/cursor/rules/`
