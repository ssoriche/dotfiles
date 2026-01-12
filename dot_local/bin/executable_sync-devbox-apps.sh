#!/bin/bash
# Sync devbox GUI apps to /Applications as Finder aliases
# Called from devbox init_hook - runs in bash context to avoid Fish syntax issues
#
# This script creates macOS Finder aliases in /Applications for GUI apps
# installed via devbox (e.g., WezTerm, AeroSpace, Obsidian, Maccy, Halloy).
# Aliases allow Spotlight indexing and proper app identity (unlike symlinks).

for app in ~/.local/share/devbox/global/default/.devbox/nix/profile/default/Applications/*.app; do
    [ -e "$app" ] || continue
    app_name=$(basename "$app")
    resolved_path=$(readlink -f "$app")
    current_target=$(osascript -e "tell application \"Finder\" to get POSIX path of (original item of alias file \"$app_name\" of folder \"Applications\" of startup disk as alias)" 2>/dev/null)
    if [ "$resolved_path" != "$current_target" ]; then
        rm -f "/Applications/$app_name" 2>/dev/null
        osascript -e "tell application \"Finder\" to make alias file to POSIX file \"$resolved_path\" at POSIX file \"/Applications\"" 2>/dev/null
    fi
done
