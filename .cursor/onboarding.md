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
- Include source attribution when adapting from other repositories

### File Management

- **Prefer editing existing files** over creating new ones
- Use chezmoi naming conventions (`private_dot_config` = `~/.config`)
- Keep AI-specific context in `.cursor/` (ignored by chezmoi)

### Documentation

- Update README.md when adding significant features
- Be accurate about script capabilities (don't document manual workarounds)
- Include upstream project attribution

## Critical Project Components

### VSCode/Cursor Settings Management

- **Script**: `private_dot_config/vscode-settings/bin/manage-vscode-settings.fish`
- **Modular Settings**: Numbered JSON files (01-base.json, 02-vim.json, etc.)
- **Key Commands**:
  - `manage-vscode-settings.fish apply all` - Apply settings
  - `manage-vscode-settings.fish sync-extensions all` - Install extensions
  - `manage-vscode-settings.fish setup all` - Complete setup

### Extension Management

- **Files**: `cursor-extensions.txt`, `codium-extensions.txt`, `shared-extensions.txt`
- **Never use manual cat/xargs** - the script handles this properly
- Extensions are automatically merged and installed via the management script

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

### Adding New Configurations

1. `chezmoi add ~/.config/new-tool/config.yaml`
2. `chezmoi edit ~/.config/new-tool/config.yaml`
3. `chezmoi apply`
4. Commit with appropriate conventional commit message

### Managing Cursor Rules

1. Create `.mdc` files in appropriate subdirectory
2. Use YAML frontmatter with `description`, `globs`, `alwaysApply`
3. Test the rule functionality
4. Commit with `feat(cursor): add [rule description]`

### VSCode/Cursor Settings Updates

1. Modify appropriate JSON file in `private_dot_config/vscode-settings/`
2. Run `manage-vscode-settings.fish apply all`
3. Test the changes
4. Commit the JSON file changes

### Extension Management

1. Add extension ID to appropriate txt file
2. Run `manage-vscode-settings.fish sync-extensions all`
3. Commit the updated extension list

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
