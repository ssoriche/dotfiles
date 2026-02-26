#!/bin/bash
# Add the devbox Applications folder to the macOS Dock as a stack.
# This runs once per machine via chezmoi to make Nix-installed GUI apps
# (AeroSpace, WezTerm, Obsidian, etc.) easily accessible.

APPS_DIR="$HOME/.local/share/devbox/global/default/.devbox/nix/profile/default/Applications"

# Skip if the directory doesn't exist (devbox not set up yet)
if [ ! -d "$APPS_DIR" ]; then
    echo "Devbox Applications directory not found, skipping Dock setup"
    exit 0
fi

# Check if already in the Dock
if defaults read com.apple.dock persistent-others 2>/dev/null | grep -q "Devbox Apps"; then
    echo "Devbox Apps already in Dock, skipping"
    exit 0
fi

echo "Adding Devbox Apps folder to Dock..."
defaults write com.apple.dock persistent-others -array-add \
    "<dict>
        <key>tile-data</key>
        <dict>
            <key>file-data</key>
            <dict>
                <key>_CFURLString</key>
                <string>file://${APPS_DIR}/</string>
                <key>_CFURLStringType</key>
                <integer>15</integer>
            </dict>
            <key>file-label</key>
            <string>Devbox Apps</string>
            <key>file-type</key>
            <integer>2</integer>
            <key>displayas</key>
            <integer>1</integer>
            <key>showas</key>
            <integer>2</integer>
        </dict>
        <key>tile-type</key>
        <string>directory-tile</string>
    </dict>"

killall Dock
echo "Devbox Apps folder added to Dock"
