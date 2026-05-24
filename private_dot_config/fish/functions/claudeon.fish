function claudeon --description "Switch between and run multiple Claude Code accounts"
    __claudeon_init

    if test (count $argv) -eq 0
        __claudeon_launch
        return
    end

    set -l first $argv[1]

    switch "$first"
        case help -h --help
            __claudeon_help
            return 0
    end

    if contains -- $first add list ls remove rm rename mv default which map unmap mappings run resync
        set -l rest $argv[2..-1]
        switch $first
            case add
                __claudeon_add $rest
            case ls list
                __claudeon_list
            case rm remove
                __claudeon_remove $rest
            case rename mv
                __claudeon_rename $rest
            case default
                __claudeon_default $rest
            case which
                __claudeon_which
            case map
                __claudeon_map $rest
            case unmap
                __claudeon_unmap $rest
            case mappings
                __claudeon_mappings
            case resync
                __claudeon_resync $rest
            case run
                __claudeon_launch $rest
        end
        return
    end

    # Not a subcommand: bare alias or pass-through claude args
    if string match -q -- '-*' $first
        __claudeon_launch -- $argv
    else if __claudeon_account_exists $first
        __claudeon_launch -a $first -- $argv[2..-1]
    else
        echo "claudeon: unknown subcommand or account '$first'" >&2
        __claudeon_help >&2
        return 1
    end
end

function __claudeon_dir
    if set -q CLAUDEON_DIR
        echo $CLAUDEON_DIR
    else
        echo $HOME/.local/share/claudeon
    end
end

function __claudeon_init
    set -l d (__claudeon_dir)
    mkdir -p $d/accounts
    chmod 700 $d $d/accounts 2>/dev/null
end

function __claudeon_help
    echo "claudeon — Claude Code account switcher"
    echo
    echo "Usage:"
    echo "  claudeon                         Launch claude with resolved account"
    echo "  claudeon <alias> [claude args]   Launch claude with that account"
    echo "  claudeon add <alias>             Create a new account"
    echo "  claudeon list                    List all accounts"
    echo "  claudeon remove <alias> [-f]     Delete an account and its data"
    echo "  claudeon rename <old> <new>      Rename an account"
    echo "  claudeon default [<alias>]       Show or set the default account"
    echo "  claudeon map <path> <alias>      Map a directory to an account"
    echo "  claudeon unmap <path>            Remove a directory mapping"
    echo "  claudeon mappings                List directory mappings"
    echo "  claudeon which                   Show which account would be used here"
    echo "  claudeon resync [<alias>]        Re-link shared files (CLAUDE.md, plugins, skills, …)"
    echo "  claudeon run [-a alias] [-- claude args...]"
    echo "                                   Explicit launch (same as bare form)"
    echo
    echo "Resolution: -a flag → \$CLAUDEON_ACCOUNT → directory mapping → default"
    echo "Storage:    "(__claudeon_dir)
    echo "Shared:     CLAUDE.md, settings.json, skills/, plugins/, agents/  (symlinked to ~/.claude/)"
end

function __claudeon_validate_alias
    set -l alias $argv[1]
    if not string match -qr '^[a-zA-Z][a-zA-Z0-9_-]{0,31}$' -- $alias
        return 1
    end
    if contains -- $alias add list ls remove rm rename mv default which map unmap mappings run resync help
        return 1
    end
    return 0
end

function __claudeon_shared_paths
    # Items relative to ~/.claude/ symlinked into every account so they're shared.
    # Per-account state (projects/, sessions/, history.jsonl, credentials, …) is not listed.
    echo CLAUDE.md
    echo settings.json
    echo skills
    echo plugins
    echo agents
end

function __claudeon_link_shared
    set -l account_path $argv[1]
    set -l src $HOME/.claude
    test -d $src; or return 0
    for item in (__claudeon_shared_paths)
        set -l target $src/$item
        set -l link $account_path/$item
        test -e $target; or continue
        # Don't clobber anything already there (real file/dir or existing link)
        test -e $link -o -L $link; and continue
        ln -s $target $link
    end
end

function __claudeon_resync
    set -l aliases
    if test (count $argv) -gt 0
        set aliases $argv
    else
        set aliases (__claudeon_aliases)
    end
    if test (count $aliases) -eq 0
        echo "claudeon: no accounts to resync"
        return 0
    end
    for alias in $aliases
        if not __claudeon_account_exists $alias
            echo "claudeon: no such account '$alias'" >&2
            continue
        end
        __claudeon_link_shared (__claudeon_account_path $alias)
        echo "claudeon: re-linked shared files for '$alias'"
    end
end

function __claudeon_account_path
    echo (__claudeon_dir)/accounts/$argv[1]
end

function __claudeon_account_exists
    test -d (__claudeon_account_path $argv[1])
end

function __claudeon_aliases
    set -l accounts_dir (__claudeon_dir)/accounts
    test -d $accounts_dir; or return 0
    for entry in $accounts_dir/*
        test -d $entry; and basename $entry
    end
end

function __claudeon_default_alias
    set -l f (__claudeon_dir)/default
    test -e $f; or return 1
    read -l alias <$f
    __claudeon_account_exists $alias; and echo $alias
end

function __claudeon_add
    set -l alias $argv[1]
    if not __claudeon_validate_alias $alias
        echo "claudeon: alias must start with a letter, then [A-Za-z0-9_-], max 32 chars, and not collide with a subcommand" >&2
        return 1
    end
    if __claudeon_account_exists $alias
        echo "claudeon: account '$alias' already exists" >&2
        return 1
    end
    set -l path (__claudeon_account_path $alias)
    mkdir -p $path
    chmod 700 $path
    __claudeon_link_shared $path
    echo "claudeon: added '$alias' → $path"
    if not __claudeon_default_alias >/dev/null
        echo $alias >(__claudeon_dir)/default
        echo "claudeon: set as default (first account)"
    end
    echo "Run 'claudeon $alias' to authenticate."
end

function __claudeon_list
    set -l default (__claudeon_default_alias)
    set -l aliases (__claudeon_aliases)
    if test (count $aliases) -eq 0
        echo "claudeon: no accounts yet — try 'claudeon add <alias>'"
        return 0
    end
    for alias in $aliases
        if test "$alias" = "$default"
            printf "  %s  (default)\n" $alias
        else
            printf "  %s\n" $alias
        end
    end
end

function __claudeon_remove
    argparse f/force -- $argv; or return 1
    set -l alias $argv[1]
    if not __claudeon_account_exists $alias
        echo "claudeon: no such account '$alias'" >&2
        return 1
    end
    set -l path (__claudeon_account_path $alias)
    if not set -q _flag_force
        read -P "Delete account '$alias' and all data at $path? [y/N] " -l ans
        if not string match -qi y $ans
            echo "claudeon: cancelled"
            return 0
        end
    end
    set -l current_default (__claudeon_default_alias)
    rm -rf $path
    if test "$current_default" = "$alias"
        rm -f (__claudeon_dir)/default
    end
    __claudeon_mappings_remove_alias $alias
    echo "claudeon: removed '$alias'"
end

function __claudeon_rename
    set -l old $argv[1]
    set -l new $argv[2]
    if not __claudeon_account_exists $old
        echo "claudeon: no such account '$old'" >&2
        return 1
    end
    if not __claudeon_validate_alias $new
        echo "claudeon: invalid new alias" >&2
        return 1
    end
    if __claudeon_account_exists $new
        echo "claudeon: '$new' already exists" >&2
        return 1
    end
    set -l current_default (__claudeon_default_alias)
    mv (__claudeon_account_path $old) (__claudeon_account_path $new)
    if test "$current_default" = "$old"
        echo $new >(__claudeon_dir)/default
    end
    __claudeon_mappings_rename_alias $old $new
    echo "claudeon: renamed '$old' → '$new'"
end

function __claudeon_default
    set -l alias $argv[1]
    if test -z "$alias"
        set -l current (__claudeon_default_alias)
        if test -n "$current"
            echo $current
            return 0
        else
            echo "claudeon: no default set" >&2
            return 1
        end
    end
    if not __claudeon_account_exists $alias
        echo "claudeon: no such account '$alias'" >&2
        return 1
    end
    echo $alias >(__claudeon_dir)/default
    echo "claudeon: default → $alias"
end

function __claudeon_abs_path
    set -l p $argv[1]
    if string match -q '~*' $p
        set p (string replace -r '^~' $HOME $p)
    end
    if not string match -q '/*' $p
        set p $PWD/$p
    end
    if command -q realpath
        realpath -m $p 2>/dev/null; or echo $p
    else
        echo $p
    end
end

function __claudeon_map
    set -l path $argv[1]
    set -l alias $argv[2]
    if test -z "$path" -o -z "$alias"
        echo "claudeon: usage: claudeon map <path> <alias>" >&2
        return 1
    end
    if not __claudeon_account_exists $alias
        echo "claudeon: no such account '$alias'" >&2
        return 1
    end
    set -l abs (__claudeon_abs_path $path)
    set -l mappings_file (__claudeon_dir)/mappings
    touch $mappings_file
    set -l kept
    while read -l line
        test -z "$line"; and continue
        set -l parts (string split \t $line)
        test "$parts[1]" = "$abs"; or set -a kept $line
    end <$mappings_file
    set -a kept "$abs"\t"$alias"
    printf '%s\n' $kept >$mappings_file
    echo "claudeon: mapped $abs → $alias"
end

function __claudeon_unmap
    set -l path $argv[1]
    set -l abs (__claudeon_abs_path $path)
    set -l mappings_file (__claudeon_dir)/mappings
    if not test -e $mappings_file
        echo "claudeon: no mappings" >&2
        return 1
    end
    set -l kept
    set -l found 0
    while read -l line
        test -z "$line"; and continue
        set -l parts (string split \t $line)
        if test "$parts[1]" = "$abs"
            set found 1
        else
            set -a kept $line
        end
    end <$mappings_file
    if test $found -eq 0
        echo "claudeon: no mapping for $abs" >&2
        return 1
    end
    printf '%s\n' $kept >$mappings_file
    echo "claudeon: unmapped $abs"
end

function __claudeon_mappings
    set -l mappings_file (__claudeon_dir)/mappings
    if not test -s $mappings_file
        echo "claudeon: no directory mappings"
        return 0
    end
    while read -l line
        test -z "$line"; and continue
        set -l parts (string split \t $line)
        printf "  %s → %s\n" $parts[1] $parts[2]
    end <$mappings_file
end

function __claudeon_mappings_remove_alias
    set -l alias $argv[1]
    set -l mappings_file (__claudeon_dir)/mappings
    test -e $mappings_file; or return 0
    set -l kept
    while read -l line
        test -z "$line"; and continue
        set -l parts (string split \t $line)
        test "$parts[2]" = "$alias"; or set -a kept $line
    end <$mappings_file
    printf '%s\n' $kept >$mappings_file
end

function __claudeon_mappings_rename_alias
    set -l old $argv[1]
    set -l new $argv[2]
    set -l mappings_file (__claudeon_dir)/mappings
    test -e $mappings_file; or return 0
    set -l updated
    while read -l line
        test -z "$line"; and continue
        set -l parts (string split \t $line)
        if test "$parts[2]" = "$old"
            set -a updated "$parts[1]"\t"$new"
        else
            set -a updated $line
        end
    end <$mappings_file
    printf '%s\n' $updated >$mappings_file
end

function __claudeon_resolve_by_dir
    set -l mappings_file (__claudeon_dir)/mappings
    test -s $mappings_file; or return 1
    set -l pwd_abs (__claudeon_abs_path $PWD)
    set -l best_len 0
    set -l best_alias
    while read -l line
        test -z "$line"; and continue
        set -l parts (string split \t $line)
        set -l path $parts[1]
        set -l alias $parts[2]
        test -z "$path" -o -z "$alias"; and continue
        set -l plen (string length $path)
        set -l prefix (string sub -l (math $plen + 1) $pwd_abs)
        if test "$pwd_abs" = "$path" -o "$prefix" = "$path/"
            if test $plen -gt $best_len
                set best_len $plen
                set best_alias $alias
            end
        end
    end <$mappings_file
    test -n "$best_alias"; and echo $best_alias
end

function __claudeon_resolve
    set -l explicit $argv[1]
    if test -n "$explicit"
        if __claudeon_account_exists $explicit
            echo $explicit\tflag
            return 0
        else
            echo "claudeon: no such account '$explicit'" >&2
            return 1
        end
    end
    if set -q CLAUDEON_ACCOUNT; and test -n "$CLAUDEON_ACCOUNT"
        if __claudeon_account_exists $CLAUDEON_ACCOUNT
            echo $CLAUDEON_ACCOUNT\t'$CLAUDEON_ACCOUNT'
            return 0
        else
            echo "claudeon: \$CLAUDEON_ACCOUNT='$CLAUDEON_ACCOUNT' but no such account" >&2
            return 1
        end
    end
    set -l mapped (__claudeon_resolve_by_dir)
    if test -n "$mapped"
        echo $mapped\t"directory mapping"
        return 0
    end
    set -l default (__claudeon_default_alias)
    if test -n "$default"
        echo $default\tdefault
        return 0
    end
    echo "claudeon: no account specified and no default set" >&2
    return 1
end

function __claudeon_which
    set -l resolved (__claudeon_resolve "")
    or return 1
    set -l parts (string split \t $resolved)
    printf "Account: %s  (via %s)\n" $parts[1] $parts[2]
    printf "Config:  %s\n" (__claudeon_account_path $parts[1])
end

function __claudeon_launch
    argparse 'a/account=' -- $argv; or return 1
    set -l explicit $_flag_account
    set -l resolved (__claudeon_resolve "$explicit")
    or return 1
    set -l parts (string split \t $resolved)
    set -l alias $parts[1]
    set -l reason $parts[2]
    set -l path (__claudeon_account_path $alias)
    if not command -q claude
        echo "claudeon: 'claude' not found on PATH" >&2
        return 127
    end
    printf "[%s] launching claude (via %s)\n" $alias $reason
    CLAUDE_CONFIG_DIR=$path exec claude $argv
end
