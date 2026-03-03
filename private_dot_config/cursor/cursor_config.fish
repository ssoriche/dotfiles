#!/usr/bin/env fish
# Cursor AI Shell Environment Configuration
# Minimal fish setup for consistent AI assistant behavior
# This file is version controlled and shared across the team

# Initialize global environment (prefer Flox, fall back to devbox)
if command -v flox >/dev/null 2>&1; and test -d "$HOME/.flox-global/.flox"
    flox activate -d "$HOME/.flox-global" | source
else if command -v devbox >/dev/null 2>&1
    devbox global shellenv --init-hook | source
else
    echo "Warning: neither flox nor devbox found in PATH" >&2
end

# Initialize direnv for automatic devbox.json loading
if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
    # Allow direnv to load automatically (suppress prompts)
    set -gx DIRENV_LOG_FORMAT ""
else
    echo "Warning: direnv not found in PATH" >&2
end

# Set basic PATH to include common locations
set -gx PATH /usr/local/bin /usr/bin /bin $PATH

# Fix PAGER issue - override problematic setting that causes "head: |: No such file or directory"
set -gx PAGER "less -R"

# Disable git pager for all git commands to prevent hanging in AI assistant context
# This ensures git commands return immediately without waiting for user interaction
set -gx GIT_PAGER cat

# Ensure we have a basic SHELL variable
set -gx SHELL (which fish)

# Fish doesn't have sessions like zsh, so no equivalent needed for SHELL_SESSIONS_DISABLE

# Note: Fish prompt is handled differently than zsh PS1
# The prompt can be customized via fish_prompt function if needed
