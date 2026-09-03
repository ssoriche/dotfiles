#!/bin/bash
# Configure flox preferences that would otherwise need setting by hand on
# each machine. Uses `flox config --set` rather than managing
# ~/.config/flox/flox.toml directly, since that file also holds
# auto_activate_environments allow/deny decisions that are local, per-machine
# state (added via `flox activate allow/deny`) and shouldn't be clobbered by
# chezmoi apply.
#
# hide_default_prompt: suppress the "flox [default]" prompt prefix from the
# auto-activated default environment (see private_dot_config/fish/config.fish).

if command -v flox >/dev/null 2>&1; then
    flox config --set hide_default_prompt true
fi
