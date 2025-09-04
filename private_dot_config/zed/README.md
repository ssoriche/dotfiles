# Zed Editor Configuration

This directory contains Zed editor configuration files that mirror your VS Code/Cursor setup.

## Files

- `settings.json` - Main Zed configuration (theme, fonts, editor behavior, language settings)
- `keymap.json` - Custom keybindings including vim-style leader key sequences
- `README.md` - This documentation file

## Key Features Configured

### 🎨 Theme & Appearance

- **Theme**: Catppuccin Mocha (dark) / Catppuccin Latte (light)
- **Font**: JetBrains Mono Nerd Font (consistent across editor, terminal, UI)
- **UI**: Relative line numbers, minimal UI, custom status bar

### ⌨️ Vim Mode

- **Enabled**: Full vim mode with space as leader key
- **Leader Key**: `<space>` (same as VS Code setup)
- **Custom Bindings**: File operations, buffer management, git operations, code actions
- **Navigation**: `gd`, `gr`, `gi`, etc. for code navigation

### 🔧 Language Support

Pre-configured language settings matching your VS Code setup:

**Web Development:**

- JavaScript/TypeScript: Prettier formatting, 2-space tabs
- HTML/CSS/SCSS: Prettier formatting
- JSON/JSONC: Prettier formatting

**Systems Programming:**

- Python: 4-space tabs, language server formatting
- Go: Hard tabs, language server formatting
- Rust: 4-space tabs, language server formatting

**Configuration:**

- YAML/TOML: 2-space tabs, appropriate formatters
- Markdown: Prettier formatting, soft wrap
- Fish/Shell: Consistent indentation

### 🎯 Key Bindings

#### Leader Key Sequences (`<space>` + key)

- **Files**: `<space>ff` (find), `<space>fg` (grep), `<space>fs` (save)
- **Buffers**: `<space>bb` (list), `<space>bd` (close), `<space>bn/bp` (next/prev)
- **Code**: `<space>ca` (actions), `<space>cr` (rename), `<space>cf` (format)
- **Git**: `<space>gg` (status), `<space>gs` (stage), `<space>gb` (blame)
- **Windows**: `<space>wh/j/k/l` (navigate), `<space>wv/s` (split)

#### Standard Shortcuts

- `Cmd+P`: Quick open files
- `Cmd+Shift+P`: Command palette
- `Cmd+Shift+F`: Project search
- `Cmd+\``: Toggle terminal

#### Code Navigation

- `gd`: Go to definition
- `gr`: Find references
- `gi`: Go to implementation
- `gh`: Show hover
- `Ctrl+T`: Go back

## Installation & Setup

1. **Install Zed**: `brew install zed` (macOS)

2. **Deploy Configuration**:

   ```bash
   chezmoi apply
   ```

3. **Install Required Tools** (for formatters):

   ```bash
   # Prettier (JavaScript/TypeScript/JSON/CSS/HTML formatting)
   npm install -g prettier

   # Language servers (handled automatically by Zed for most languages)
   # Python: pip install pyright
   # Go: go install golang.org/x/tools/gopls@latest
   # Rust: rustup component add rust-analyzer
   ```

## Zed vs VS Code Feature Comparison

### ✅ Built-in to Zed (No Extensions Needed)

- **Vim Mode**: Full vim emulation with leader key support
- **Git Integration**: Inline blame, diff gutters, git status
- **Language Servers**: Automatic setup for most languages
- **Themes**: Catppuccin and other popular themes built-in
- **Terminal**: Integrated terminal with full customization
- **Project Navigation**: File finder, symbol search, project search

### 🔄 Zed Equivalents to Your Extensions

| VS Code Extension      | Zed Equivalent            | Notes                                            |
| ---------------------- | ------------------------- | ------------------------------------------------ |
| Vim                    | Built-in vim mode         | Activated with `"vim_mode": true`                |
| WhichKey               | Built-in command palette  | `Cmd+Shift+P` or space-based leader sequences    |
| GitLens                | Built-in git features     | Inline blame, git gutters, built-in git commands |
| Catppuccin             | Built-in theme            | Available in theme selector                      |
| Prettier               | External formatter        | Configure in language settings                   |
| ESLint                 | Language server           | Automatic via TypeScript language server         |
| Python/Go/Rust support | Built-in language servers | Automatic installation and setup                 |

### 🚧 Features Not Available (Yet)

- **Extensions Ecosystem**: Zed has a much smaller extension ecosystem
- **Spell Checker**: No built-in spell checking (vs Code Spell Checker)
- **Container/Docker**: Limited container development support
- **Kubernetes Tools**: No equivalent to VS Code Kubernetes extension
- **Live Server**: No built-in live development server

## Migration Tips

1. **Vim Muscle Memory**: Your vim keybindings should work identically
2. **File Navigation**: `Cmd+P` works the same for quick file access
3. **Search**: `Cmd+Shift+F` for project-wide search
4. **Git Workflow**: Git features are built-in, no need to install GitLens
5. **Formatting**: Auto-format on save configured for all languages

## Customization

To modify settings:

1. Open Zed
2. Press `Cmd+,` to open settings
3. Or edit `~/.config/zed/settings.json` directly

To add keybindings:

1. Press `Cmd+K`, then `Cmd+S` to open keymap
2. Or edit `~/.config/zed/keymap.json` directly

## Performance Notes

Zed is significantly faster than VS Code, especially for:

- **Startup Time**: Near-instant startup
- **Large Files**: Better performance with large codebases
- **Memory Usage**: Lower memory footprint
- **Vim Mode**: Native vim implementation (faster than VS Code vim extension)

Your configuration maintains the same productivity while gaining performance benefits.
