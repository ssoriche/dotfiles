# Personal Dotfiles

A comprehensive dotfiles configuration managed with [chezmoi](https://www.chezmoi.io/), featuring automated setup for development environments including Cursor, VSCode, terminal configurations, and various development tools.

## Overview

This repository contains my personal dotfiles and configuration files for:

- **Editors**: Cursor, VSCode/VSCodium, Neovim
- **Terminal**: Fish shell, Wezterm, Ghostty
- **Development Tools**: Git, Atuin, Bat, K9s
- **Window Management**: Aerospace, Hammerspoon, Karabiner
- **Package Management**: Devbox (Nix-based)
- **AI Development**: Cursor rules for enhanced coding assistance

## Quick Start

### Prerequisites

- [chezmoi](https://www.chezmoi.io/) - Dotfiles manager
- macOS (primary target platform)

### Installation

1. **Install chezmoi** (if not already installed):

   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```

2. **Initialize with this repository**:

   ```bash
   chezmoi init --apply https://github.com/YOUR_USERNAME/dotfiles.git
   ```

3. **Apply configurations**:
   ```bash
   chezmoi apply
   ```

## Cursor & VSCode Configuration

### Settings Management

This dotfiles setup uses a modular approach to manage Cursor and VSCode settings:

#### Settings Structure

```
private_dot_config/vscode-settings/
├── 01-base.json          # Core editor settings
├── 02-vim.json           # Vim keybindings and behavior
├── 03-navigation.json    # File navigation and search
├── 03-theme.json         # UI theme and appearance
├── 04-languages.json     # Language-specific settings
├── 05-keybindings.json   # Custom keybindings
├── 06-whichkey.json      # Which-key menu configuration
├── 99-overrides.json     # Final overrides
└── bin/
    ├── manage-vscode-settings.fish
    └── vscode-manager-aliases.fish
```

#### Managing Settings

The settings are automatically merged and applied using the management script:

```bash
# Apply settings to specific editor
manage-vscode-settings.fish apply cursor
manage-vscode-settings.fish apply codium

# Apply settings to all editors
manage-vscode-settings.fish apply all

# Show differences before applying
manage-vscode-settings.fish diff cursor
manage-vscode-settings.fish diff all
```

### Extension Management

Extensions are managed through text files that list required extensions:

```
private_dot_config/vscode-settings/
├── cursor-extensions.txt     # Cursor-specific extensions
├── codium-extensions.txt     # VSCodium-specific extensions
└── shared-extensions.txt     # Extensions for both editors
```

#### Installing Extensions

The management script provides convenient commands for extension installation:

```bash
# Install extensions for specific editor
manage-vscode-settings.fish install-extensions cursor
manage-vscode-settings.fish install-extensions codium

# Install extensions for all editors
manage-vscode-settings.fish install-extensions all

# Sync extensions (install missing, keep existing)
manage-vscode-settings.fish sync-extensions cursor
manage-vscode-settings.fish sync-extensions all
```

### Cursor Rules

AI-powered development assistance through Cursor rules:

```
private_dot_config/cursor/rules/
├── core/
│   └── mantras.mdc              # Core development principles
└── development/
    ├── discoverability.mdc      # Contextual help system
    └── conventional-commits.mdc # Commit message standards
```

#### Cursor Rules Features

- **Core Mantras**: Fundamental development principles and agent behavior standards
- **Discoverability**: Contextual help system that responds to user queries
- **Conventional Commits**: Automated generation of standardized commit messages

## Key Features

### Development Environment

- **Unified Settings**: Consistent configuration across Cursor and VSCode
- **Modular Configuration**: Easy to customize individual aspects
- **Extension Sync**: Automated extension installation and management
- **AI Enhancement**: Cursor rules for improved coding assistance

### Terminal Setup

- **Fish Shell**: Modern shell with intelligent autocompletion
- **Wezterm/Ghostty**: GPU-accelerated terminal emulators
- **Atuin**: Enhanced shell history with sync capabilities
- **Bat**: Syntax-highlighted `cat` replacement

### Window Management

- **Aerospace**: Tiling window manager for macOS
- **Hammerspoon**: Lua-based automation and window management
- **Karabiner**: Advanced keyboard customization

### Development Tools

- **Git**: Comprehensive git configuration with templates
- **Devbox**: Nix-based development environment management
- **K9s**: Kubernetes cluster management
- **Neovim**: Highly configured editor setup

## Usage

### Managing Dotfiles with chezmoi

```bash
# Edit a file
chezmoi edit ~/.config/fish/config.fish

# Apply changes
chezmoi apply

# Add a new file
chezmoi add ~/.new-config-file

# Check status
chezmoi status

# View differences
chezmoi diff

# Update from repository
chezmoi update
```

### Cursor/VSCode Workflow

1. **Settings Updates**: Modify JSON files in `private_dot_config/vscode-settings/`
2. **Apply Changes**: Run `manage-vscode-settings.fish apply all`
3. **Extension Management**: Update extension lists and run `manage-vscode-settings.fish sync-extensions all`
4. **Cursor Rules**: Add new `.mdc` files to enhance AI assistance
5. **Complete Setup**: Use `manage-vscode-settings.fish setup all` for new installations

### Adding New Extensions

1. Add extension ID to appropriate file:

   - `shared-extensions.txt` for both editors
   - `cursor-extensions.txt` for Cursor only
   - `codium-extensions.txt` for VSCodium only

2. Install the new extensions:

   ```bash
   # Sync extensions (installs any missing extensions)
   manage-vscode-settings.fish sync-extensions all

   # Or install for specific editor
   manage-vscode-settings.fish install-extensions cursor
   ```

### Additional Extension Management

The script provides several other useful extension management commands:

```bash
# List currently installed extensions
manage-vscode-settings.fish list-extensions cursor
manage-vscode-settings.fish list-extensions all

# Export currently installed extensions to a file
manage-vscode-settings.fish export-extensions cursor

# Complete setup (settings + extensions)
manage-vscode-settings.fish setup cursor
manage-vscode-settings.fish setup all

# Check status of all editors
manage-vscode-settings.fish status
```

## Upstream Projects

This configuration builds upon and integrates with several excellent open-source projects:

### Core Tools

- [chezmoi](https://www.chezmoi.io/) - Dotfiles manager
- [Cursor](https://cursor.sh/) - AI-powered code editor
- [VSCode](https://code.visualstudio.com/) - Microsoft's code editor
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor

### Terminal & Shell

- [Fish Shell](https://fishshell.com/) - Smart and user-friendly command line shell
- [Wezterm](https://wezfurlong.org/wezterm/) - GPU-accelerated terminal emulator
- [Ghostty](https://ghostty.org/) - Fast, native terminal emulator
- [Atuin](https://atuin.sh/) - Magical shell history

### Development Environment

- [Devbox](https://www.jetpack.io/devbox/) - Instant, easy, predictable development environments
- [Nix](https://nixos.org/) - Purely functional package manager

### Window Management

- [Aerospace](https://github.com/nikitabobko/AeroSpace) - Tiling window manager for macOS
- [Hammerspoon](https://www.hammerspoon.org/) - Desktop automation for macOS
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) - Keyboard customizer

### Cursor Rules

- [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) - Collection of Cursor rules
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message specification

## Customization

### Adding New Configurations

1. **Add files to chezmoi**:

   ```bash
   chezmoi add ~/.config/new-tool/config.yaml
   ```

2. **Edit with chezmoi**:

   ```bash
   chezmoi edit ~/.config/new-tool/config.yaml
   ```

3. **Apply changes**:
   ```bash
   chezmoi apply
   ```

### Modifying Cursor Rules

1. Create new `.mdc` files in `private_dot_config/cursor/rules/`
2. Use the frontmatter format:
   ```yaml
   ---
   description: Rule description
   globs:
   alwaysApply: false
   ---
   ```

### VSCode Settings Customization

1. Modify the appropriate JSON file in `private_dot_config/vscode-settings/`
2. Run `manage-vscode-settings.fish` to apply changes
3. Settings are merged in numerical order (01, 02, 03, etc.)

## Contributing

While this is a personal dotfiles repository, contributions and suggestions are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request with a clear description

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The [chezmoi](https://www.chezmoi.io/) project for excellent dotfiles management
- The [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) community for AI development enhancements
- All the upstream projects that make this configuration possible
- The open-source community for continuous inspiration and improvement

---

_This README is maintained as part of the dotfiles and is automatically deployed via chezmoi._
