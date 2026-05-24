function __claudeon_complete_aliases
    set -l accounts_dir
    if set -q CLAUDEON_DIR
        set accounts_dir $CLAUDEON_DIR/accounts
    else
        set accounts_dir $HOME/.local/share/claudeon/accounts
    end
    test -d $accounts_dir; or return 0
    for entry in $accounts_dir/*
        test -d $entry; and basename $entry
    end
end

function __claudeon_using_subcommand
    set -l tokens (commandline -opc)
    test (count $tokens) -ge 2; and test "$tokens[2]" = "$argv[1]"
end

function __claudeon_no_subcommand
    set -l tokens (commandline -opc)
    test (count $tokens) -eq 1
end

set -l subcommands add list ls remove rm rename mv default which map unmap mappings run help

# Subcommand names (first position only)
complete -c claudeon -n __claudeon_no_subcommand -f -a add -d "Create a new account"
complete -c claudeon -n __claudeon_no_subcommand -f -a list -d "List all accounts"
complete -c claudeon -n __claudeon_no_subcommand -f -a remove -d "Delete an account"
complete -c claudeon -n __claudeon_no_subcommand -f -a rename -d "Rename an account"
complete -c claudeon -n __claudeon_no_subcommand -f -a default -d "Show or set default account"
complete -c claudeon -n __claudeon_no_subcommand -f -a which -d "Show resolved account here"
complete -c claudeon -n __claudeon_no_subcommand -f -a map -d "Map a directory to an account"
complete -c claudeon -n __claudeon_no_subcommand -f -a unmap -d "Remove a directory mapping"
complete -c claudeon -n __claudeon_no_subcommand -f -a mappings -d "List directory mappings"
complete -c claudeon -n __claudeon_no_subcommand -f -a run -d "Explicit launch"
complete -c claudeon -n __claudeon_no_subcommand -f -a resync -d "Re-link shared files"
complete -c claudeon -n __claudeon_no_subcommand -f -a help -d "Show help"

# Account aliases as first arg (bare launch form)
complete -c claudeon -n __claudeon_no_subcommand -f -a '(__claudeon_complete_aliases)' -d Account

# Aliases for subcommands that take one
complete -c claudeon -n '__claudeon_using_subcommand remove' -f -a '(__claudeon_complete_aliases)'
complete -c claudeon -n '__claudeon_using_subcommand rm' -f -a '(__claudeon_complete_aliases)'
complete -c claudeon -n '__claudeon_using_subcommand rename' -f -a '(__claudeon_complete_aliases)'
complete -c claudeon -n '__claudeon_using_subcommand mv' -f -a '(__claudeon_complete_aliases)'
complete -c claudeon -n '__claudeon_using_subcommand default' -f -a '(__claudeon_complete_aliases)'
complete -c claudeon -n '__claudeon_using_subcommand resync' -f -a '(__claudeon_complete_aliases)'

# remove flag
complete -c claudeon -n '__claudeon_using_subcommand remove' -s f -l force -d "Skip confirmation"
complete -c claudeon -n '__claudeon_using_subcommand rm' -s f -l force -d "Skip confirmation"

# run flag
complete -c claudeon -n '__claudeon_using_subcommand run' -s a -l account -x -a '(__claudeon_complete_aliases)' -d Account

# map: 2nd token is a path, 3rd token is an alias
complete -c claudeon -n '__claudeon_using_subcommand map' -F
complete -c claudeon -n '__claudeon_using_subcommand unmap' -F
