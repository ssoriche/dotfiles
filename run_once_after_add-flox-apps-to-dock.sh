#!/bin/bash
# Add the Flox global Applications folder to the macOS Dock as a fan stack.
# This runs via chezmoi to make Flox-installed GUI apps (AeroSpace, WezTerm,
# Obsidian, Raycast, etc.) easily accessible.
#
# The Dock canonicalizes symlinks: even if you hand it the stable
# ~/.flox/run/.../Applications symlink, on the next `killall Dock` it rewrites
# the tile to the concrete /nix/store/...-environment-*/Applications path of the
# current generation. So every flox generation eventually leaves the tile
# pinned to a now-stale store path.
#
# To self-heal, this script compares the *resolved* target of any existing
# "Flox Apps" tile against the *resolved* current Applications dir. If they
# match (and the display is right) it does nothing; otherwise it removes and
# re-adds the tile. This keeps churn to zero on unchanged generations while
# repointing automatically whenever flox rebuilds.

FLOX_ENV_DIR="$HOME/.flox"

# Desired display: displayas 0 = stack (icon is the pile of contents),
# 1 = plain folder icon. showas 1 = fan, 2 = grid, 3 = list.
WANT_DISPLAYAS=0
WANT_SHOWAS=1

# Skip if the Flox environment doesn't exist
if [ ! -f "$FLOX_ENV_DIR/env/manifest.toml" ]; then
    echo "Flox global environment not found, skipping Dock setup"
    exit 0
fi

# Find the Applications directory inside the Flox environment.
# Path varies by architecture: run/<arch>-<os>.<name>.<mode>/Applications.
# This is a symlink flox repoints per generation, so the tile stays current.
APPS_DIR=$(find -L "$FLOX_ENV_DIR/run" -type d -name "Applications" 2>/dev/null | head -1)

if [ -z "$APPS_DIR" ] || [ ! -d "$APPS_DIR" ]; then
    echo "Flox Applications directory not found, skipping Dock setup"
    exit 0
fi

# Write the concrete resolved path — the Dock would canonicalize a symlink to
# this anyway, so storing it directly makes the comparison below honest.
WANT_DIR=$(cd "$APPS_DIR" && pwd -P)
WANT_URL="file://${WANT_DIR}/"

# Resolve a file:// URL (strip scheme + trailing slash) to its real directory,
# or empty string if it no longer exists (e.g. GC'd generation).
resolve_url() {
    local p="${1#file://}"
    p="${p%/}"
    (cd "$p" 2>/dev/null && pwd -P) || echo ""
}

# Locate any existing "Flox Apps" tile and read its current target + display.
TMP_PLIST=$(mktemp)
defaults export com.apple.dock "$TMP_PLIST"

flox_idx=-1
cur_url=""
cur_showas=""
cur_displayas=""
idx=0
while label=$(/usr/libexec/PlistBuddy -c "Print persistent-others:$idx:tile-data:file-label" "$TMP_PLIST" 2>/dev/null); do
    if [ "$label" = "Flox Apps" ]; then
        flox_idx=$idx
        cur_url=$(/usr/libexec/PlistBuddy -c "Print persistent-others:$idx:tile-data:file-data:_CFURLString" "$TMP_PLIST" 2>/dev/null || echo "")
        cur_showas=$(/usr/libexec/PlistBuddy -c "Print persistent-others:$idx:tile-data:showas" "$TMP_PLIST" 2>/dev/null || echo "")
        cur_displayas=$(/usr/libexec/PlistBuddy -c "Print persistent-others:$idx:tile-data:displayas" "$TMP_PLIST" 2>/dev/null || echo "")
        break
    fi
    idx=$((idx + 1))
done

# Compare by *resolved* target so a symlink and its store path count as equal,
# and so we only repoint when flox has actually rebuilt to a new generation.
cur_real=$(resolve_url "$cur_url")

# Already correct (same resolved target AND right display) → nothing to do.
if [ "$flox_idx" -ge 0 ] && [ -n "$cur_real" ] && [ "$cur_real" = "$WANT_DIR" ] && [ "$cur_showas" = "$WANT_SHOWAS" ] && [ "$cur_displayas" = "$WANT_DISPLAYAS" ]; then
    echo "Flox Apps already in Dock, pointing at the current generation — nothing to do"
    rm -f "$TMP_PLIST"
    exit 0
fi

# Remove a stale/misconfigured tile before re-adding.
if [ "$flox_idx" -ge 0 ]; then
    echo "Flox Apps tile is stale (resolved='$cur_real' showas='$cur_showas' displayas='$cur_displayas'), repointing..."
    /usr/libexec/PlistBuddy -c "Delete persistent-others:$flox_idx" "$TMP_PLIST"
    defaults import com.apple.dock "$TMP_PLIST"
fi
rm -f "$TMP_PLIST"

echo "Adding Flox Apps folder to Dock..."
defaults write com.apple.dock persistent-others -array-add \
    "<dict>
        <key>tile-data</key>
        <dict>
            <key>file-data</key>
            <dict>
                <key>_CFURLString</key>
                <string>${WANT_URL}</string>
                <key>_CFURLStringType</key>
                <integer>15</integer>
            </dict>
            <key>file-label</key>
            <string>Flox Apps</string>
            <key>file-type</key>
            <integer>2</integer>
            <key>displayas</key>
            <integer>${WANT_DISPLAYAS}</integer>
            <key>showas</key>
            <integer>${WANT_SHOWAS}</integer>
        </dict>
        <key>tile-type</key>
        <string>directory-tile</string>
    </dict>"

killall Dock
echo "Flox Apps folder added to Dock (fan stack)"
