# Dotfiles Project Onboarding

This document provides context for AI assistants working on this personal dotfiles repository to understand the project structure, conventions, and key workflows.

## Project Overview

This is a comprehensive dotfiles configuration managed with [chezmoi](https://www.chezmoi.io/), targeting macOS development environments. The repository includes configurations for:

- **Editors**: Cursor, VSCode/VSCodium, Neovim
- **Terminal**: Fish shell, Wezterm, Ghostty
- **Development**: Git, Devbox (Nix), Atuin, K9s
- **Window Management**: Aerospace, Hammerspoon, Karabiner
- **AI Enhancement**: Cursor rules for development assistance

## Key Principles & Conventions

### Commit Messages

- **ALWAYS use conventional commits format**: `type(scope): description`
- Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`
- Common scopes: `cursor`, `vscode`, `fish`, `git`, `config`
- **Focus on WHY not WHAT**: Emphasize rationale and benefits over technical details
- Include source attribution when adapting from other repositories

### File Management

- **Prefer editing existing files** over creating new ones
- Use chezmoi naming conventions (`private_dot_config` = `~/.config`)
- Keep AI-specific context in `.cursor/` (ignored by chezmoi)
- **Separate generic vs project-specific**: Generic user settings belong in dotfiles, project-specific configurations belong in project repositories
- **Separate management tools from deployable configs**: Build tools and source files should not be deployed by chezmoi

### Documentation

- Update README.md when adding significant features
- Be accurate about script capabilities (don't document manual workarounds)
- Include upstream project attribution

## Architecture Principles

### Deployment vs Management Separation

**Key Insight**: Not everything in the repository should be deployed by chezmoi. Some directories contain tools that build or manage configurations.

**Examples**:

- ✅ **Deployable**: `private_dot_config/cursor/rules/` → `~/.config/cursor/rules/`
- ✅ **Deployable**: `Library/Application Support/Cursor/User/settings.json.tmpl` → `~/Library/Application Support/Cursor/User/settings.json`
- ❌ **Management Tool**: `vscode-settings/` (contains source files and build scripts)
- ❌ **Work Files**: `.cursor/extracted-rules/` (temporary analysis files)

**Implementation**:

- Management tools live at repository root
- Use `.chezmoiignore` to exclude them from deployment
- Templates read from management directories to build final configs

## Critical Project Components

### VSCode/Cursor Settings Management

- **Script**: `vscode-settings/bin/manage-vscode-settings.fish` (moved to repository root)
- **Modular Settings**: Numbered JSON files (01-base.json, 02-vim.json, etc.)
- **Architecture**: Management directory at repository root, not deployed by chezmoi
- **Key Commands**:
  - `vscode-settings/bin/manage-vscode-settings.fish apply all` - Apply settings
  - `vscode-settings/bin/manage-vscode-settings.fish sync-extensions all` - Install extensions
  - `vscode-settings/bin/manage-vscode-settings.fish setup all` - Complete setup

### Extension Management

- **Files**: `cursor-extensions.txt`, `codium-extensions.txt`, `shared-extensions.txt`
- **Never use manual cat/xargs** - the script handles this properly
- Extensions are automatically merged and installed via the management script
- **Extension categorization**:
  - `shared-extensions.txt`: Extensions that work in both VSCode and Cursor
  - `cursor-extensions.txt`: Cursor-only extensions
  - `codium-extensions.txt`: VSCodium-only extensions
- **Avoid intermediary files**: Files like `cursor-extensions-exported.txt` are temporary and shouldn't be version controlled

### Cursor Rules Structure

```
private_dot_config/cursor/rules/
├── core/
│   ├── mantras.mdc              # Core development principles
│   └── shell_environment.mdc    # Shell environment standardization
└── development/
    ├── discoverability.mdc      # Contextual help system
    └── conventional-commits.mdc # Commit message standards
```

### Shell Environment

- **Fish Configuration**: `private_dot_config/cursor/cursor_config.fish`
- **Environment Rule**: Enforces standardized shell usage in AI interactions
- **Integration**: Devbox + Direnv for consistent development environments

## Common Workflows

### Git Workflow Best Practices

**Staging Changes:**

- **Use `git add -u`** for tracked files only (avoids staging untracked work files)
- **Avoid `git add -A`** unless you specifically want to include all untracked files
- **Example workflow**:

  ```bash
  # Stage only changes to tracked files (recommended)
  git add -u

  # Or stage specific files
  git add file1.txt file2.txt

  # Avoid staging everything (includes untracked files)
  git add -A  # ❌ Use with caution
  ```

**Managing Untracked Files:**

- Work files in `.cursor/extracted-rules/` and similar directories should remain untracked
- Use `.gitignore` or specific staging to avoid committing temporary files

### Adding New Configurations

1. `chezmoi add ~/.config/new-tool/config.yaml`
2. `chezmoi edit ~/.config/new-tool/config.yaml`
3. `chezmoi apply`
4. Commit with appropriate conventional commit message

### Applying Changes with chezmoi

**Key Insight**: `chezmoi apply` uses TARGET paths (where files should be deployed), not SOURCE paths (in the chezmoi directory).

```bash
# ❌ Wrong - using source path
chezmoi apply private_dot_config/cursor/rules/file.mdc

# ✅ Correct - using target path
chezmoi apply ~/.config/cursor/rules/file.mdc

# Apply all changes
chezmoi apply

# Apply specific directory (target path)
chezmoi apply ~/.config/cursor/

# Apply specific file (target path)
chezmoi apply ~/.config/cursor/rules/development/git-commit-practices.mdc

# Only use --force when explicitly requested or needed
chezmoi apply --force ~/.config/cursor/rules/development/git-commit-practices.mdc
```

**When to use `--force`** (use sparingly):

- Only when explicitly requested by the user
- When you specifically want chezmoi-managed files to override existing local changes
- When deploying and you need to ensure the repository version takes precedence

### Managing Cursor Rules

1. Create `.mdc` files in appropriate subdirectory
2. Use YAML frontmatter with `description`, `globs`, `alwaysApply`
3. Test the rule functionality
4. Commit with `feat(cursor): add [rule description]`

### VSCode/Cursor Settings Updates

1. Modify appropriate JSON file in `vscode-settings/`
2. Run `vscode-settings/bin/manage-vscode-settings.fish apply all`
3. Test the changes
4. Commit the JSON file changes

### Extension Management

1. Add extension ID to appropriate txt file
2. Run `vscode-settings/bin/manage-vscode-settings.fish sync-extensions all`
3. Commit the updated extension list

### Theme Configuration Best Practices

**Installation Order Matters**: Extensions must be installed before settings templates are applied to ensure theme settings work properly.

**Correct Order**:

1. Install extensions: `vscode-settings/bin/manage-vscode-settings.fish sync-extensions cursor`
2. Apply settings: `vscode-settings/bin/manage-vscode-settings.fish apply cursor`
3. Deploy with chezmoi: `chezmoi apply "~/Library/Application Support/Cursor/User/settings.json"`

**Or use complete setup**: `vscode-settings/bin/manage-vscode-settings.fish setup cursor` (handles order automatically)

## Project History & Context

### Recent Additions

- **Conventional Commits Rule**: From awesome-cursorrules repository
- **Shell Environment**: Fish adaptation from ZR-Private/cursor-rules-experimental
- **Comprehensive README**: Complete project documentation

### Key Scripts

- `manage-vscode-settings.fish`: Sophisticated settings and extension management
- `vscode-manager-aliases.fish`: Helper aliases and utilities

### Upstream Dependencies

- Most configurations adapted from open-source projects
- Always include source attribution in commit messages
- Check upstream for updates and improvements

## AI Assistant Guidelines

### When Working on This Project

1. **Read this document first** to understand context
2. **Check existing patterns** before creating new approaches
3. **Validate script capabilities** - don't assume manual processes
4. **Use conventional commits** for all changes
5. **Update documentation** when making significant changes

### Common Pitfalls to Avoid

- Don't suggest manual extension installation when script exists
- Don't create files unnecessarily - prefer editing existing ones
- Don't ignore chezmoi conventions for file naming
- Don't forget to source-attribute external configurations
- **Don't use source paths with `chezmoi apply`** - always use target paths (where files should be deployed)
- Don't apply all configurations when only specific files need updating - use targeted `chezmoi apply` commands
- **Don't use `git add -A` carelessly** - prefer `git add -u` to avoid staging untracked work files
- **Don't version control intermediary files** - files like `*-exported.txt` are temporary artifacts
- **Don't mix project-specific settings with generic dotfiles** - kubernetes configs belong in project repos, not personal dotfiles
- **Don't assume shared extensions belong in editor-specific lists** - categorize extensions properly based on compatibility
- **Don't deploy management tools with chezmoi** - directories like `vscode-settings/` contain build tools, not target configurations
- **Don't duplicate editor configurations** - avoid redundant config directories like `Code/` when the editor isn't installed; Cursor uses `Library/Application Support/Cursor/` on macOS, not `~/.config/Code/`

### Quality Standards

- All shell scripts should be fish-compatible
- JSON configurations should be valid and tested
- Cursor rules should include proper frontmatter
- Documentation should be accurate and complete

## Useful References

- [chezmoi Documentation](https://www.chezmoi.io/user-guide/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules)

---

**Note**: This document should be updated as the project evolves. It serves as institutional knowledge to maintain consistency across AI assistant sessions.
