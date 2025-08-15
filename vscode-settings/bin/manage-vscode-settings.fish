#!/usr/bin/env fish

set script_dir (dirname (status --current-filename))
set settings_dir (dirname $script_dir)
set chezmoi_dir (chezmoi source-path)

# Color output functions
function info
    echo (set_color blue)"ℹ️  $argv"(set_color normal)
end

function success
    echo (set_color green)"✅ $argv"(set_color normal)
end

function warning
    echo (set_color yellow)"⚠️  $argv"(set_color normal)
end

function error
    echo (set_color red)"❌ $argv"(set_color normal)
end

function usage
    echo "Usage: $argv[1] [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  assemble [editor]     - Assemble settings for specific editor (cursor|codium|all)"
    echo "  diff [editor]         - Show differences for editor settings"
    echo "  apply [editor]        - Apply settings to editor"
    echo "  install-extensions [editor] - Install extensions for editor"
    echo "  list-extensions [editor]    - List installed extensions for editor"
    echo "  diff-extensions [editor]    - Compare installed extension versions with expected"
    echo "  sync-extensions [editor]    - Sync extensions (install missing, auto-update versions)"
    echo "  export-extensions [editor]  - Export currently installed extensions"
    echo "  remove-missing-extensions [editor] - Remove extensions that don't exist from config"
    echo "  status                - Show status of all editors"
    echo "  validate              - Validate JSON syntax in all setting files"
    echo "  backup                - Backup current editor settings and extensions"
    echo "  restore               - Restore from backup"
    echo "  list                  - List all setting modules"
    echo "  setup [editor]        - Complete setup (settings + extensions)"
    echo "  apply-cursor-rules    - Apply global Cursor AI rules from dotfiles"
    echo "  backup-cursor-rules   - Backup current Cursor AI rules"
    echo "  cursor-rules-status   - Show status of Cursor AI rules configuration"
    echo ""
    echo "Options:"
    echo "  -h, --help            - Show this help"
    echo "  -v, --verbose         - Verbose output (show all command output)"
    echo "  -f, --force           - Force operations (skip confirmations)"
    echo ""
    echo "Examples:"
    echo "  $argv[1] setup cursor           # Complete setup for Cursor"
    echo "  $argv[1] install-extensions all # Install extensions for all editors"
    echo "  $argv[1] diff-extensions cursor # Compare extension versions"
    echo "  $argv[1] sync-extensions cursor # Sync Cursor extensions (clean output)"
    echo "  $argv[1] -v sync-extensions cursor # Sync with verbose output"
    echo "  $argv[1] remove-missing-extensions cursor # Clean up missing extensions"
    echo "  $argv[1] apply all              # Apply settings to all editors"
end

function check_dependencies
    set missing_deps

    if not command -v jq >/dev/null
        set missing_deps $missing_deps jq
    end

    if not command -v chezmoi >/dev/null
        set missing_deps $missing_deps chezmoi
    end

    if test (count $missing_deps) -gt 0
        error "Missing dependencies: "(string join ", " $missing_deps)
        echo "Install with: brew install "(string join " " $missing_deps)
        return 1
    end

    return 0
end

function get_editor_command
    set editor $argv[1]

    switch $editor
        case cursor
            if command -v cursor >/dev/null
                echo cursor
            else
                error "Cursor command not found. Make sure Cursor is installed and in PATH"
                return 1
            end
        case codium
            if command -v codium >/dev/null
                echo codium
            else
                error "Codium command not found. Make sure VSCodium is installed and in PATH"
                return 1
            end
        case '*'
            error "Unknown editor: $editor"
            return 1
    end
end

function validate_json_files
    info "Validating JSON syntax..."

    set invalid_files
    for file in $settings_dir/*.json
        # Strip comments and validate JSON
        if not cat $file | sed 's|//.*||g' | sed '/^\s*$/d' | jq empty >/dev/null 2>&1
            set invalid_files $invalid_files (basename $file)
        end
    end

    if test (count $invalid_files) -gt 0
        error "Invalid JSON files: "(string join ", " $invalid_files)
        return 1
    else
        success "All JSON files are valid"
        return 0
    end
end

function list_modules
    info "Available setting modules:"
    for file in $settings_dir/*.json
        set basename (basename $file .json)
        echo "  - $basename"
    end

    echo ""
    info "Available extension lists:"
    for file in $settings_dir/*-extensions.txt
        set basename (basename $file .txt)
        echo "  - $basename"
    end
end

function get_extensions_list
    set editor $argv[1]
    set shared_extensions $settings_dir/shared-extensions.txt
    set editor_extensions $settings_dir/$editor-extensions.txt

    set all_extensions

    # Add shared extensions
    if test -f $shared_extensions
        set shared (grep -v '^#' $shared_extensions | grep -v '^$')
        set all_extensions $all_extensions $shared
    end

    # Add editor-specific extensions
    if test -f $editor_extensions
        set specific (grep -v '^#' $editor_extensions | grep -v '^$')
        set all_extensions $all_extensions $specific
    end

    # Remove duplicates and return
    printf '%s\n' $all_extensions | sort -u
end

function install_extensions
    set editor $argv[1]

    if test -z "$editor"
        set editor all
    end

    info "Installing extensions for: $editor"

    switch $editor
        case cursor
            install_extensions_for_editor cursor
        case codium
            install_extensions_for_editor codium
        case all
            install_extensions_for_editor cursor
            install_extensions_for_editor codium
        case '*'
            error "Unknown editor: $editor. Use cursor, codium, or all"
            return 1
    end
end

function install_extensions_for_editor
    set editor $argv[1]
    set cmd (get_editor_command $editor)

    if test $status -ne 0
        warning "Skipping $editor - not available"
        return 0
    end

    info "Installing extensions for $editor..."

    set extensions (get_extensions_list $editor)
    set installed_count 0
    set failed_count 0

    for ext in $extensions
        if test -n "$ext"
            set ext_id (string split "@" "$ext")[1]
            echo "  Installing: $ext_id"
            if $cmd --install-extension $ext 2>/dev/null
                set installed_count (math $installed_count + 1)
                echo "    ✅ Installed $ext"
            else
                echo "    ⚠️  Failed with specific version, trying latest..."
                # Try installing without version if the versioned install failed
                if $cmd --install-extension $ext_id 2>/dev/null
                    set installed_count (math $installed_count + 1)
                    echo "    ✅ Installed $ext_id (latest)"
                else
                    echo "    ❌ Failed to install $ext_id"
                    set failed_count (math $failed_count + 1)
                end
            end
        end
    end

    success "Installed $installed_count extensions for $editor"
    if test $failed_count -gt 0
        warning "$failed_count extensions failed to install"
    end
end

function list_installed_extensions
    set editor $argv[1]

    if test -z "$editor"
        set editor all
    end

    switch $editor
        case cursor
            list_extensions_for_editor cursor
        case codium
            list_extensions_for_editor codium
        case all
            list_extensions_for_editor cursor
            list_extensions_for_editor codium
        case '*'
            error "Unknown editor: $editor. Use cursor, codium, or all"
            return 1
    end
end

function list_extensions_for_editor
    set editor $argv[1]
    set cmd (get_editor_command $editor)

    if test $status -ne 0
        warning "Skipping $editor - not available"
        return 0
    end

    info "Installed extensions for $editor:"
    $cmd --list-extensions 2>/dev/null | sort
end

function sync_extensions
    set editor $argv[1]

    if test -z "$editor"
        set editor all
    end

    info "Syncing extensions for: $editor"

    switch $editor
        case cursor
            sync_extensions_for_editor cursor
        case codium
            sync_extensions_for_editor codium
        case all
            sync_extensions_for_editor cursor
            sync_extensions_for_editor codium
        case '*'
            error "Unknown editor: $editor. Use cursor, codium, or all"
            return 1
    end
end

function sync_extensions_for_editor
    set editor $argv[1]
    set cmd (get_editor_command $editor)

    if test $status -ne 0
        warning "Skipping $editor - not available"
        return 0
    end

    info "Syncing extensions for $editor..."

    # Get expected extensions
    set expected_extensions (get_extensions_list $editor)

    # Get currently installed extensions WITH versions
    if test $VERBOSE_MODE -eq 1
        set installed_extensions_with_versions ($cmd --list-extensions --show-versions; echo $status)
    else
        set installed_extensions_with_versions ($cmd --list-extensions --show-versions 2>/dev/null; echo $status)
    end

    set cmd_exit_code $installed_extensions_with_versions[-1]
    if test $cmd_exit_code -ne 0
        error "Failed to get installed extensions for $editor"
        return 1
    end

    # Remove the exit code from the list
    set installed_extensions_with_versions $installed_extensions_with_versions[1..-2]

    # Create associative arrays for installed extensions
    set installed_ids
    set installed_versions

    for ext in $installed_extensions_with_versions
        if test -n "$ext"
            set id (string split "@" "$ext")[1]
            set ext_version (string split "@" "$ext")[2]
            set installed_ids $installed_ids $id
            set installed_versions $installed_versions $ext_version
        end
    end

    set installed_count 0
    set updated_count 0
    set failed_count 0
    set updated_versions
    set failed_extensions

    # Process each expected extension
    for ext in $expected_extensions
        if test -n "$ext"
            # Parse expected extension
            if string match -q "*@*" "$ext"
                set ext_id (string split "@" "$ext")[1]
                set expected_version (string split "@" "$ext")[2]
            else
                set ext_id "$ext"
                set expected_version "latest"
            end

            # Check if extension is installed
            set found_index 0
            for i in (seq (count $installed_ids))
                if test "$installed_ids[$i]" = "$ext_id"
                    set found_index $i
                    break
                end
            end

            if test $found_index -eq 0
                # Extension not installed - install it
                echo "  Installing: $ext"

                if test $VERBOSE_MODE -eq 1
                    set install_result ($cmd --install-extension $ext; echo $status)
                else
                    set install_result ($cmd --install-extension $ext 2>/dev/null; echo $status)
                end

                set install_exit_code $install_result[-1]
                if test $install_exit_code -eq 0
                    set installed_count (math $installed_count + 1)
                    echo "    ✅ Installed $ext"
                else
                    echo "    ⚠️  Failed with specific version, trying latest..."
                    # Try installing without version if the versioned install failed
                    if test $VERBOSE_MODE -eq 1
                        set fallback_result ($cmd --install-extension $ext_id; echo $status)
                    else
                        set fallback_result ($cmd --install-extension $ext_id 2>/dev/null; echo $status)
                    end

                    set fallback_exit_code $fallback_result[-1]
                    if test $fallback_exit_code -eq 0
                        set installed_count (math $installed_count + 1)
                        # Get the actual installed version and queue for update
                        if test $VERBOSE_MODE -eq 1
                            set actual_version ($cmd --list-extensions --show-versions | grep "^$ext_id@" | string split "@")[2]
                        else
                            set actual_version ($cmd --list-extensions --show-versions 2>/dev/null | grep "^$ext_id@" | string split "@")[2]
                        end
                        if test -n "$actual_version"
                            set updated_versions $updated_versions "$ext_id@$actual_version"
                            echo "    ✅ Installed $ext_id@$actual_version (will update config)"
                        else
                            echo "    ✅ Installed $ext_id (latest)"
                        end
                    else
                        echo "    ❌ Failed to install $ext_id"
                        set failed_count (math $failed_count + 1)
                        set failed_extensions $failed_extensions $ext
                    end
                end
            else
                # Extension is installed - check version
                set installed_version $installed_versions[$found_index]
                if test "$expected_version" != "latest"; and test "$installed_version" != "$expected_version"
                    # Version mismatch - update it
                    echo "  Updating: $ext_id ($installed_version → $expected_version)"

                    if test $VERBOSE_MODE -eq 1
                        set update_result ($cmd --install-extension $ext; echo $status)
                    else
                        set update_result ($cmd --install-extension $ext 2>/dev/null; echo $status)
                    end

                    set update_exit_code $update_result[-1]
                    if test $update_exit_code -eq 0
                        set updated_count (math $updated_count + 1)
                        echo "    ✅ Updated to $expected_version"
                    else
                        echo "    ❌ Failed to update $ext_id"
                        set failed_count (math $failed_count + 1)
                        set failed_extensions $failed_extensions $ext
                    end
                else
                    echo "  ✅ $ext_id: $installed_version (up to date)"
                end
            end
        end
    end

    # Update extension files with actual installed versions
    if test (count $updated_versions) -gt 0
        update_extension_versions $editor $updated_versions
    end

    # Handle failed extensions
    if test (count $failed_extensions) -gt 0
        echo ""
        warning "The following extensions could not be installed/updated:"
        for ext in $failed_extensions
            echo "  - $ext"
        end
        echo ""
        echo "Options to handle missing extensions:"
        echo "  1. Clean up config files: ./bin/manage-vscode-settings.fish remove-missing-extensions $editor"
        echo "  2. Comment them out manually in the extension files"
        echo "  3. Find alternative extensions with similar functionality"
    end

    # Summary
    if test $failed_count -gt 0
        warning "Extensions sync completed with $failed_count failures for $editor"
    else
        if test $updated_count -gt 0
            success "Extensions synced for $editor ($installed_count installed, $updated_count updated)"
        else
            success "Extensions synced for $editor ($installed_count installed)"
        end
    end
end

function export_extensions
    set editor $argv[1]

    if test -z "$editor"
        set editor all
    end

    switch $editor
        case cursor
            export_extensions_for_editor cursor
        case codium
            export_extensions_for_editor codium
        case all
            export_extensions_for_editor cursor
            export_extensions_for_editor codium
        case '*'
            error "Unknown editor: $editor. Use cursor, codium, or all"
            return 1
    end
end

function export_extensions_for_editor
    set editor $argv[1]
    set cmd (get_editor_command $editor)

    if test $status -ne 0
        warning "Skipping $editor - not available"
        return 0
    end

    set output_file $settings_dir/$editor-extensions-exported.txt

    info "Exporting extensions for $editor to: $output_file"

    echo "# Exported extensions for $editor on "(date) >$output_file
    $cmd --list-extensions 2>/dev/null | sort >>$output_file

    success "Extensions exported to $output_file"
end

function update_extension_versions
    set editor $argv[1]
    set updated_versions $argv[2..-1]

    info "Updating extension versions in configuration files..."

    set shared_extensions $settings_dir/shared-extensions.txt
    set editor_extensions $settings_dir/$editor-extensions.txt

    for updated_ext in $updated_versions
        set ext_id (string split "@" "$updated_ext")[1]
        set new_version (string split "@" "$updated_ext")[2]

        # Check shared-extensions.txt first
        if test -f $shared_extensions
            set updated_shared 0
            # Create a temporary file for the update
            set temp_file (mktemp)
            while read -l line
                if string match -q "*$ext_id@*" "$line"
                    # Replace the version in this line
                    set old_ext (string match -r "$ext_id@[0-9a-zA-Z.-]+" "$line")
                    if test -n "$old_ext"
                        set new_line (string replace "$old_ext" "$updated_ext" "$line")
                        echo "$new_line" >>$temp_file
                        info "Updated $old_ext → $updated_ext in shared-extensions.txt"
                        set updated_shared 1
                    else
                        echo "$line" >>$temp_file
                    end
                else
                    echo "$line" >>$temp_file
                end
            end <$shared_extensions

            if test $updated_shared -eq 1
                mv $temp_file $shared_extensions
            else
                rm $temp_file
            end
        end

        # Check editor-specific extensions.txt
        if test -f $editor_extensions
            set updated_editor 0
            set temp_file (mktemp)
            while read -l line
                if string match -q "*$ext_id@*" "$line"
                    # Replace the version in this line
                    set old_ext (string match -r "$ext_id@[0-9a-zA-Z.-]+" "$line")
                    if test -n "$old_ext"
                        set new_line (string replace "$old_ext" "$updated_ext" "$line")
                        echo "$new_line" >>$temp_file
                        info "Updated $old_ext → $updated_ext in $editor-extensions.txt"
                        set updated_editor 1
                    else
                        echo "$line" >>$temp_file
                    end
                else
                    echo "$line" >>$temp_file
                end
            end <$editor_extensions

            if test $updated_editor -eq 1
                mv $temp_file $editor_extensions
            else
                rm $temp_file
            end
        end
    end
end

function remove_missing_extensions
    set editor $argv[1]

    if test -z "$editor"
        error "Please specify an editor: cursor, codium, or all"
        return 1
    end

    switch $editor
        case cursor
            remove_missing_extensions_for_editor cursor
        case codium
            remove_missing_extensions_for_editor codium
        case all
            remove_missing_extensions_for_editor cursor
            remove_missing_extensions_for_editor codium
        case '*'
            error "Unknown editor: $editor. Use cursor, codium, or all"
            return 1
    end
end

function remove_missing_extensions_for_editor
    set editor $argv[1]

    info "This command helps you clean up extensions that failed to install."
    echo ""
    echo "Recommended workflow:"
    echo "1. First run: ./bin/manage-vscode-settings.fish sync-extensions $editor"
    echo "2. Check the output for failed extensions"
    echo "3. Then use this command to remove them from your config files"
    echo ""
    echo "Manual cleanup options:"
    echo "- Edit shared-extensions.txt to remove/comment out problematic extensions"
    echo "- Edit $editor-extensions.txt for editor-specific extensions"
    echo "- Use '#' to comment out extensions instead of deleting them"
    echo ""

    # List current extension files for reference
    echo "Current extension files:"
    set shared_extensions $settings_dir/shared-extensions.txt
    set editor_extensions $settings_dir/$editor-extensions.txt

    if test -f $shared_extensions
        echo "  - shared-extensions.txt ("(grep -v '^#' $shared_extensions | grep -c '^[^[:space:]]*$')" extensions)"
    end

    if test -f $editor_extensions
        echo "  - $editor-extensions.txt ("(grep -v '^#' $editor_extensions | grep -c '^[^[:space:]]*$')" extensions)"
    end

    echo ""
    echo "Would you like to:"
    echo "1. View shared-extensions.txt"
    echo "2. View $editor-extensions.txt"
    echo "3. Edit shared-extensions.txt"
    echo "4. Edit $editor-extensions.txt"
    echo "5. Exit"
    echo ""
    echo -n "Choose an option (1-5): "
    read -l choice

    switch $choice
        case 1
            if test -f $shared_extensions
                info "Contents of shared-extensions.txt:"
                cat $shared_extensions
            else
                warning "shared-extensions.txt not found"
            end
        case 2
            if test -f $editor_extensions
                info "Contents of $editor-extensions.txt:"
                cat $editor_extensions
            else
                warning "$editor-extensions.txt not found"
            end
        case 3
            if test -f $shared_extensions
                info "Opening shared-extensions.txt in editor..."
                $EDITOR $shared_extensions
            else
                warning "shared-extensions.txt not found"
            end
        case 4
            if test -f $editor_extensions
                info "Opening $editor-extensions.txt in editor..."
                $EDITOR $editor_extensions
            else
                warning "$editor-extensions.txt not found"
            end
        case 5
            info "Exiting without changes"
        case '*'
            warning "Invalid choice"
    end
end



function diff_extensions
    set editor $argv[1]

    if test -z "$editor"
        set editor all
    end

    info "Comparing extension versions for: $editor"

    switch $editor
        case cursor
            diff_extensions_for_editor cursor
        case codium
            diff_extensions_for_editor codium
        case all
            diff_extensions_for_editor cursor
            echo ""
            diff_extensions_for_editor codium
        case '*'
            error "Unknown editor: $editor. Use cursor, codium, or all"
            return 1
    end
end

function diff_extensions_for_editor
    set editor $argv[1]
    set cmd (get_editor_command $editor)

    if test $status -ne 0
        warning "Skipping $editor - not available"
        return 0
    end

    info "Extension version comparison for $editor:"

    # Get expected extensions with versions
    set expected_extensions (get_extensions_list $editor)

    # Get installed extensions with versions
    set installed_extensions_with_versions ($cmd --list-extensions --show-versions 2>/dev/null)

    # Create associative arrays (using fish arrays)
    set expected_ids
    set expected_versions
    set installed_ids
    set installed_versions

    # Parse expected extensions
    for ext in $expected_extensions
        if test -n "$ext"
            if string match -q "*@*" "$ext"
                set id (string split "@" "$ext")[1]
                set ext_version (string split "@" "$ext")[2]
            else
                set id "$ext"
                set ext_version "latest"
            end
            set expected_ids $expected_ids $id
            set expected_versions $expected_versions $ext_version
        end
    end

    # Parse installed extensions
    for ext in $installed_extensions_with_versions
        if test -n "$ext"
            set id (string split "@" "$ext")[1]
            set ext_version (string split "@" "$ext")[2]
            set installed_ids $installed_ids $id
            set installed_versions $installed_versions $ext_version
        end
    end

    set differences_found 0

    # Check for version mismatches and missing extensions
    for i in (seq (count $expected_ids))
        set expected_id $expected_ids[$i]
        set expected_ext_version $expected_versions[$i]

        # Find this extension in installed list
        set found_index 0
        for j in (seq (count $installed_ids))
            if test "$installed_ids[$j]" = "$expected_id"
                set found_index $j
                break
            end
        end

        if test $found_index -eq 0
            echo "  ❌ Missing: $expected_id (expected: $expected_ext_version)"
            set differences_found 1
        else
            set installed_ext_version $installed_versions[$found_index]
            if test "$expected_ext_version" != "latest"; and test "$installed_ext_version" != "$expected_ext_version"
                echo "  ⚠️  Version mismatch: $expected_id"
                echo "      Expected: $expected_ext_version"
                echo "      Installed: $installed_ext_version"
                set differences_found 1
            else if test "$expected_ext_version" = "latest"
                echo "  ✅ $expected_id: $installed_ext_version (latest)"
            else
                echo "  ✅ $expected_id: $installed_ext_version"
            end
        end
    end

    # Check for extra extensions (installed but not expected)
    for i in (seq (count $installed_ids))
        set installed_id $installed_ids[$i]
        if not contains $installed_id $expected_ids
            echo "  ➕ Extra: $installed_id@$installed_versions[$i] (not in extension list)"
            set differences_found 1
        end
    end

    if test $differences_found -eq 0
        success "All extensions match expected versions for $editor"
    else
        warning "Found differences in extension versions for $editor"
    end

    return $differences_found
end

function assemble_settings
    set editor $argv[1]

    if test -z "$editor"
        set editor all
    end

    info "Assembling settings for: $editor"

    if not validate_json_files
        return 1
    end

    switch $editor
        case cursor
            chezmoi apply "$HOME/Library/Application Support/Cursor/User/settings.json"
        case codium
            chezmoi apply "$HOME/Library/Application Support/VSCodium/User/settings.json"
        case all
            chezmoi apply "$HOME/Library/Application Support/Cursor/User/settings.json"
            chezmoi apply "$HOME/Library/Application Support/VSCodium/User/settings.json"
        case '*'
            error "Unknown editor: $editor. Use cursor, codium, or all"
            return 1
    end

    success "Settings assembled for $editor"
end

function show_diff
    set editor $argv[1]

    if test -z "$editor"
        set editor all
    end

    info "Showing differences for: $editor"

    switch $editor
        case cursor
            chezmoi diff "$HOME/Library/Application Support/Cursor/User/settings.json"
        case codium
            chezmoi diff "$HOME/Library/Application Support/VSCodium/User/settings.json"
        case all
            echo "=== Cursor Differences ==="
            chezmoi diff "$HOME/Library/Application Support/Cursor/User/settings.json"
            echo ""
            echo "=== Codium Differences ==="
            chezmoi diff "$HOME/Library/Application Support/VSCodium/User/settings.json"
        case '*'
            error "Unknown editor: $editor. Use cursor, codium, or all"
            return 1
    end
end

function show_status
    info "Checking status of all editors..."

    echo "=== Chezmoi Status ==="
    chezmoi status | grep -E "(Cursor|VSCodium|settings\.json)" || echo "No changes detected"

    echo ""
    echo "=== Editor Installations ==="

    # Check Cursor
    if test -d "$HOME/Library/Application Support/Cursor"
        success "Cursor: Installed"
        if command -v cursor >/dev/null
            echo "  Command: Available"
            set cursor_extensions (cursor --list-extensions 2>/dev/null | wc -l | string trim)
            echo "  Extensions: $cursor_extensions installed"
        else
            warning "  Command: Not in PATH"
        end
    else
        warning "Cursor: Not installed"
    end

    echo ""

    # Check Codium
    if test -d "$HOME/Library/Application Support/VSCodium"
        success "Codium: Installed"
        if command -v codium >/dev/null
            echo "  Command: Available"
            set codium_extensions (codium --list-extensions 2>/dev/null | wc -l | string trim)
            echo "  Extensions: $codium_extensions installed"
        else
            warning "  Command: Not in PATH"
        end
    else
        warning "Codium: Not installed"
    end
end

function backup_settings
    set backup_dir "$HOME/.config/vscode-settings-backup/"(date +%Y%m%d_%H%M%S)

    info "Creating backup in: $backup_dir"
    mkdir -p "$backup_dir"

    # Backup Cursor settings and extensions
    if test -d "$HOME/Library/Application Support/Cursor"
        if test -f "$HOME/Library/Application Support/Cursor/User/settings.json"
            cp "$HOME/Library/Application Support/Cursor/User/settings.json" "$backup_dir/cursor-settings.json"
        end
        if command -v cursor >/dev/null
            cursor --list-extensions 2>/dev/null >"$backup_dir/cursor-extensions.txt"
        end
        success "Backed up Cursor settings and extensions"
    end

    # Backup Codium settings and extensions
    if test -d "$HOME/Library/Application Support/VSCodium"
        if test -f "$HOME/Library/Application Support/VSCodium/User/settings.json"
            cp "$HOME/Library/Application Support/VSCodium/User/settings.json" "$backup_dir/codium-settings.json"
        end
        if command -v codium >/dev/null
            codium --list-extensions 2>/dev/null >"$backup_dir/codium-extensions.txt"
        end
        success "Backed up Codium settings and extensions"
    end

    success "Backup completed: $backup_dir"
end

function restore_settings
    set backup_dir (find "$HOME/.config/vscode-settings-backup" -type d -name "20*" | sort | tail -1)

    if test -z "$backup_dir"
        error "No backup found"
        return 1
    end

    info "Restoring from: $backup_dir"

    # Restore Cursor
    if test -f "$backup_dir/cursor-settings.json"
        cp "$backup_dir/cursor-settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
        success "Restored Cursor settings"
    end

    if test -f "$backup_dir/cursor-extensions.txt"; and command -v cursor >/dev/null
        info "Restoring Cursor extensions..."
        while read -l ext
            cursor --install-extension $ext 2>/dev/null
        end <"$backup_dir/cursor-extensions.txt"
        success "Restored Cursor extensions"
    end

    # Restore Codium
    if test -f "$backup_dir/codium-settings.json"
        cp "$backup_dir/codium-settings.json" "$HOME/Library/Application Support/VSCodium/User/settings.json"
        success "Restored Codium settings"
    end

    if test -f "$backup_dir/codium-extensions.txt"; and command -v codium >/dev/null
        info "Restoring Codium extensions..."
        while read -l ext
            codium --install-extension $ext 2>/dev/null
        end <"$backup_dir/codium-extensions.txt"
        success "Restored Codium extensions"
    end
end

function apply_cursor_rules
    set rules_file "$settings_dir/cursor-global-rules.txt"

    if not test -f "$rules_file"
        error "Global rules file not found: $rules_file"
        return 1
    end

    info "Applying Cursor global rules..."

    # Read rules content (excluding comments and empty lines)
    set rules_content (grep -v '^#' "$rules_file" | grep -v '^$')

    if test (count $rules_content) -eq 0
        warning "No rules found in $rules_file"
        return 0
    end

    # Check if cursor command is available
    if not command -v cursor >/dev/null
        error "Cursor command not found. Please ensure Cursor is installed and in PATH."
        return 1
    end

    # Create a temporary file with the rules
    set temp_rules (mktemp)
    printf '%s\n' $rules_content > "$temp_rules"

    echo "Rules to apply:"
    echo "─────────────────────────────────────────────"
    cat "$temp_rules"
    echo "─────────────────────────────────────────────"
    echo ""

    warning "Note: Currently, Cursor doesn't provide a command-line way to set global rules."
    warning "You'll need to manually copy these rules to Cursor Settings > General > Rules for AI"
    warning "Alternatively, create project-specific .cursorrules files."

    # Offer to create a project rules file
    echo ""
    echo "Would you like to create a .cursorrules file with these rules for a specific project? (y/N)"
    read -n 1 response
    echo ""

    if test "$response" = "y" -o "$response" = "Y"
        set project_rules_file "$settings_dir/project-cursorrules.txt"
        cp "$temp_rules" "$project_rules_file"
        success "Created project rules file at: $project_rules_file"
        echo "You can copy this to any project as .cursorrules"
        echo "For structured project templates, use: $settings_dir/cursorrules-template.txt"
    end

    rm -f "$temp_rules"
    success "Cursor rules processing completed"
end

function backup_cursor_rules
    set backup_dir "$HOME/.config/vscode-settings-backup/"(date +%Y%m%d_%H%M%S)
    mkdir -p "$backup_dir"

    info "Backing up Cursor rules to: $backup_dir"

    # Try to extract rules from Cursor's database
    set cursor_db "$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb"

    if test -f "$cursor_db"
        if command -v sqlite3 >/dev/null
            # Try to extract global rules
            set extracted_rules (sqlite3 "$cursor_db" "SELECT value FROM ItemTable WHERE key = 'aicontext.personalContext';" 2>/dev/null)

            if test -n "$extracted_rules" -a "$extracted_rules" != "0"
                echo "$extracted_rules" > "$backup_dir/cursor-global-rules-extracted.txt"
                success "Extracted global rules from Cursor database"
            else
                warning "No global rules found in Cursor database (may be stored in cloud)"
            end
        else
            warning "sqlite3 not available - cannot extract rules from database"
        end
    else
        warning "Cursor database not found"
    end

    # Copy current rules file if it exists
    if test -f "$settings_dir/cursor-global-rules.txt"
        cp "$settings_dir/cursor-global-rules.txt" "$backup_dir/cursor-global-rules-dotfiles.txt"
        success "Backed up dotfiles rules configuration"
    end

    success "Cursor rules backup completed: $backup_dir"
end



function show_cursor_rules_status
    info "Cursor Rules Status"
    echo ""

    # Where Cursor actually looks for rules
    set cursor_rules_dir "$HOME/.config/cursor/rules"
    # Where dotfiles store rules
    set dotfiles_rules_dir "$settings_dir/../cursor/rules"

    # Check dotfiles rules directory (source)
    if test -d "$dotfiles_rules_dir"
        success "Dotfiles rules directory: $dotfiles_rules_dir"

        set core_rules (find "$dotfiles_rules_dir/core" -name "*.mdc" 2>/dev/null | wc -l)
        set dev_rules (find "$dotfiles_rules_dir/development" -name "*.mdc" 2>/dev/null | wc -l)

        echo "  ├── Core rules: $core_rules files"
        if test -d "$dotfiles_rules_dir/core"
            for rule in $dotfiles_rules_dir/core/*.mdc
                if test -f "$rule"
                    echo "  │   └── "(basename "$rule")
                end
            end
        end

        echo "  └── Development rules: $dev_rules files"
        if test -d "$dotfiles_rules_dir/development"
            for rule in $dotfiles_rules_dir/development/*.mdc
                if test -f "$rule"
                    echo "      └── "(basename "$rule")
                end
            end
        end
    else
        warning "Dotfiles rules directory not found: $dotfiles_rules_dir"
    end

    echo ""

    # Check actual Cursor rules directory (destination)
    if test -d "$cursor_rules_dir"
        success "Cursor rules directory: $cursor_rules_dir"

        set cursor_core_rules (find "$cursor_rules_dir/core" -name "*.mdc" 2>/dev/null | wc -l)
        set cursor_dev_rules (find "$cursor_rules_dir/development" -name "*.mdc" 2>/dev/null | wc -l)

        echo "  ├── Core rules: $cursor_core_rules files (deployed)"
        if test -d "$cursor_rules_dir/core"
            for rule in $cursor_rules_dir/core/*.mdc
                if test -f "$rule"
                    echo "  │   └── "(basename "$rule")
                end
            end
        end

        echo "  └── Development rules: $cursor_dev_rules files (deployed)"
        if test -d "$cursor_rules_dir/development"
            for rule in $cursor_rules_dir/development/*.mdc
                if test -f "$rule"
                    echo "      └── "(basename "$rule")
                end
            end
        end

        # Check if rules are in sync
        if test -d "$dotfiles_rules_dir"
            set total_dotfiles (math $core_rules + $dev_rules)
            set total_cursor (math $cursor_core_rules + $cursor_dev_rules)

            if test $total_dotfiles -ne $total_cursor
                echo ""
                warning "Rules are OUT OF SYNC! Dotfiles have $total_dotfiles rules, Cursor has $total_cursor rules"
                info "Run: chezmoi apply ~/.config/cursor/rules/"
            else
                echo ""
                success "Rules are in sync ($total_cursor rules deployed)"
            end
        end
    else
        warning "Cursor rules directory not found: $cursor_rules_dir"
        if test -d "$dotfiles_rules_dir"
            info "Run: chezmoi apply ~/.config/cursor/"
        end
    end

    echo ""

    # Check legacy rules file (keep for migration)
    set legacy_rules_file "$settings_dir/cursor-global-rules.txt"
    if test -f "$legacy_rules_file"
        set line_count (wc -l < "$legacy_rules_file")
        set rule_count (grep -v '^#' "$legacy_rules_file" | grep -v '^$' | wc -l)
        warning "Legacy rules file found: $legacy_rules_file ($rule_count rules, $line_count total lines)"
        echo "  Consider removing after confirming rules are migrated to .mdc format"
    end

    # Check for .cursorrules template
    set template_file "$settings_dir/cursorrules-template.txt"
    if test -f "$template_file"
        success "Project rules template: $template_file"
    else
        info "No project rules template found"
    end

    # Check if Cursor is installed
    if command -v cursor >/dev/null
        success "Cursor CLI: Available"
    else
        warning "Cursor CLI: Not found in PATH"
    end

    echo ""
    info "Cursor automatically loads global rules from: $cursor_rules_dir"
    info "Use 'alwaysApply: true' in .mdc frontmatter for always-active rules"
    info "Deploy changes with: chezmoi apply ~/.config/cursor/"
    info "Legacy commands: apply-cursor-rules, backup-cursor-rules"
end

function complete_setup
    set editor $argv[1]

    if test -z "$editor"
        set editor all
    end

    info "Complete setup for: $editor"

    # Backup existing settings
    backup_settings

    # Install extensions
    install_extensions $editor

    # Apply settings
    assemble_settings $editor

    success "Complete setup finished for $editor"
    info "Restart your editor(s) to see all changes"
end

# Main script logic
if not check_dependencies
    exit 1
end

# Parse arguments and flags
set verbose_mode 0
set force_mode 0
set command ""
set editor ""

# Parse flags first
set args $argv
for i in (seq (count $args))
    switch $args[$i]
        case -v --verbose
            set verbose_mode 1
        case -f --force
            set force_mode 1
        case '-*'
            # Ignore other flags for now
            continue
        case '*'
            # First non-flag argument is command
            if test -z "$command"
                set command $args[$i]
            else if test -z "$editor"
                set editor $args[$i]
            end
    end
end

# Make verbose_mode available to functions
set -g VERBOSE_MODE $verbose_mode

switch $command
    case setup
        complete_setup $editor
    case assemble
        assemble_settings $editor
    case diff
        show_diff $editor
    case apply
        assemble_settings $editor
    case install-extensions
        install_extensions $editor
    case list-extensions
        list_installed_extensions $editor
    case diff-extensions
        diff_extensions $editor
    case sync-extensions
        sync_extensions $editor
    case export-extensions
        export_extensions $editor
    case remove-missing-extensions
        remove_missing_extensions $editor
    case status
        show_status
    case validate
        validate_json_files
    case backup
        backup_settings
    case restore
        restore_settings
    case list
        list_modules
    case apply-cursor-rules
        apply_cursor_rules
    case backup-cursor-rules
        backup_cursor_rules
    case cursor-rules-status
        show_cursor_rules_status
    case -h --help help ''
        usage (basename (status --current-filename))
    case '*'
        error "Unknown command: $command"
        usage (basename (status --current-filename))
        exit 1
end
