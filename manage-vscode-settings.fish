#!/usr/bin/env fish

set script_dir (dirname (status --current-filename))
set settings_dir "$script_dir/private_dot_config/vscode-settings"
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
    echo "  sync-extensions [editor]    - Sync extensions (install missing, remove extra)"
    echo "  export-extensions [editor]  - Export currently installed extensions"
    echo "  status                - Show status of all editors"
    echo "  validate              - Validate JSON syntax in all setting files"
    echo "  backup                - Backup current editor settings and extensions"
    echo "  restore               - Restore from backup"
    echo "  list                  - List all setting modules"
    echo "  setup [editor]        - Complete setup (settings + extensions)"
    echo ""
    echo "Options:"
    echo "  -h, --help            - Show this help"
    echo "  -v, --verbose         - Verbose output"
    echo "  -f, --force           - Force operations (skip confirmations)"
    echo ""
    echo "Examples:"
    echo "  $argv[1] setup cursor           # Complete setup for Cursor"
    echo "  $argv[1] install-extensions all # Install extensions for all editors"
    echo "  $argv[1] sync-extensions cursor # Sync Cursor extensions"
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
        if not jq empty $file >/dev/null 2>&1
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
            echo "  Installing: $ext"
            if $cmd --install-extension $ext >/dev/null 2>&1
                set installed_count (math $installed_count + 1)
            else
                warning "Failed to install: $ext"
                set failed_count (math $failed_count + 1)
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
    $cmd --list-extensions | sort
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

    # Get currently installed extensions
    set installed_extensions ($cmd --list-extensions)

    # Install missing extensions
    for ext in $expected_extensions
        if not contains $ext $installed_extensions
            echo "  Installing missing: $ext"
            $cmd --install-extension $ext >/dev/null 2>&1
        end
    end

    # Optionally remove extra extensions (commented out for safety)
    # for ext in $installed_extensions
    #     if not contains $ext $expected_extensions
    #         echo "  Removing extra: $ext"
    #         $cmd --uninstall-extension $ext >/dev/null 2>&1
    #     end
    # end

    success "Extensions synced for $editor"
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
    $cmd --list-extensions | sort >>$output_file

    success "Extensions exported to $output_file"
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
            set cursor_extensions (cursor --list-extensions | wc -l | string trim)
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
            set codium_extensions (codium --list-extensions | wc -l | string trim)
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
            cursor --list-extensions >"$backup_dir/cursor-extensions.txt"
        end
        success "Backed up Cursor settings and extensions"
    end

    # Backup Codium settings and extensions
    if test -d "$HOME/Library/Application Support/VSCodium"
        if test -f "$HOME/Library/Application Support/VSCodium/User/settings.json"
            cp "$HOME/Library/Application Support/VSCodium/User/settings.json" "$backup_dir/codium-settings.json"
        end
        if command -v codium >/dev/null
            codium --list-extensions >"$backup_dir/codium-extensions.txt"
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
            cursor --install-extension $ext >/dev/null 2>&1
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
            codium --install-extension $ext >/dev/null 2>&1
        end <"$backup_dir/codium-extensions.txt"
        success "Restored Codium extensions"
    end
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

# Parse arguments
set command $argv[1]
set editor $argv[2]

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
    case sync-extensions
        sync_extensions $editor
    case export-extensions
        export_extensions $editor
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
    case -h --help help ''
        usage (basename (status --current-filename))
    case '*'
        error "Unknown command: $command"
        usage (basename (status --current-filename))
        exit 1
end
