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

## Development Environment

### Shell Environment

- **Primary Shell**: Fish shell
- **OS**: macOS (Darwin)
- **Package Manager**: Devbox (Nix-based) for development tools
- **Dotfiles Manager**: chezmoi

### Installed Development Tools

Key tools managed via Devbox (see `dot_local/share/devbox/global/default/devbox.json`):

- **Search/Navigation**: `fd`, `rg` (ripgrep), `fzf`, `eza`
- **Text Processing**: `bat`, `jq`, `fastgron`, `jless`, `sd`
- **Version Control**: `git`, `gh`, `tig`, `delta`, `difftastic`, `git-absorb`, `jujutsu`
- **Editors**: Neovim (nightly), `lua-language-server`
- **Shell Enhancements**: `atuin`, `direnv`
- **Development**: `nodejs`, `go`, `uv`, `typos`, `dotenv-linter`
- **Kubernetes**: `k9s`, `kustomize`
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
- **Configuration Options**:
  - `includeCoAuthoredBy`: false - Disables "Co-Authored-By: Claude" in git commits
  - `permissions.allow/deny/ask`: Tool permission rules
  - `env`: Environment variables for sessions
  - `model`: Default model override
  - `outputStyle`: System prompt style configuration

**Note**: Runtime state files (`.claude.json`, conversation history, todos) are NOT managed by chezmoi as they contain session-specific data.

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
dot_local/share/devbox/                       → ~/.local/share/devbox/
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
