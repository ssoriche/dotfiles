#!/bin/bash
# Sync devbox GUI apps to /Applications and macOS Launch Services
# Called from devbox init_hook - runs in bash context to avoid Fish syntax issues
#
# This script:
# 1. Creates Finder aliases in /Applications for GUI apps installed via devbox
#    (e.g., WezTerm, AeroSpace, Obsidian, Maccy, Halloy) - visible in Finder/Spotlight
# 2. Registers apps with Launch Services for "Open With" menus and `open -a` command
#
# Both are updated when the Nix store path changes (i.e., when devbox updates packages).

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
STATE_DIR="$HOME/.local/state/devbox-apps"
mkdir -p "$STATE_DIR"

for app in ~/.local/share/devbox/global/default/.devbox/nix/profile/default/Applications/*.app; do
    [ -e "$app" ] || continue
    app_name=$(basename "$app")
    resolved_path=$(readlink -f "$app")
    state_file="$STATE_DIR/${app_name%.app}.path"

    # Check if we need to update (path changed or never registered)
    current_registered=""
    [ -f "$state_file" ] && current_registered=$(cat "$state_file")

    if [ "$resolved_path" != "$current_registered" ]; then
        # Update Finder alias in /Applications
        # Alias name is app name without .app extension (e.g., "WezTerm" not "WezTerm.app")
        alias_name="${app_name%.app}"
        rm -f "/Applications/$alias_name" 2>/dev/null
        osascript -e "tell application \"Finder\" to make alias file to POSIX file \"$resolved_path\" at POSIX file \"/Applications\"" 2>/dev/null
        # Rename from "AppName alias" to "AppName" (Finder adds " alias" suffix)
        [ -e "/Applications/$alias_name alias" ] && mv "/Applications/$alias_name alias" "/Applications/$alias_name"

        # Unregister old path from Launch Services if it exists
        [ -n "$current_registered" ] && "$LSREGISTER" -u "$current_registered" 2>/dev/null

        # Register new path with Launch Services
        "$LSREGISTER" -f "$resolved_path" 2>/dev/null

        # Save the registered path
        echo "$resolved_path" > "$state_file"
    fi
done
