#!/bin/bash
# Add the Flox global Applications folder to the macOS Dock as a stack.
# This runs once per machine via chezmoi to make Flox-installed GUI apps
# (AeroSpace, WezTerm, Obsidian, etc.) easily accessible.

FLOX_ENV_DIR="$HOME/.flox"

# Skip if the Flox environment doesn't exist
if [ ! -f "$FLOX_ENV_DIR/env/manifest.toml" ]; then
    echo "Flox global environment not found, skipping Dock setup"
    exit 0
fi

# Find the Applications directory inside the Flox environment
# Path varies by architecture: run/<arch>-<os>.<name>.<mode>/...
APPS_DIR=$(find "$FLOX_ENV_DIR/run" -type d -name "Applications" 2>/dev/null | head -1)

if [ -z "$APPS_DIR" ] || [ ! -d "$APPS_DIR" ]; then
    echo "Flox Applications directory not found, skipping Dock setup"
    exit 0
fi

# Check if already in the Dock
if defaults read com.apple.dock persistent-others 2>/dev/null | grep -q "Flox Apps"; then
    echo "Flox Apps already in Dock, skipping"
    exit 0
fi

echo "Adding Flox Apps folder to Dock..."
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
            <string>Flox Apps</string>
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
echo "Flox Apps folder added to Dock"
