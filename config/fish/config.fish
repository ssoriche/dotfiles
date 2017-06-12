# THEME PURE #
set fish_function_path $HOME/.config/fish/functions/theme-pure $fish_function_path

function fish_mode_prompt
# Turn off mode indictor
end

function custom_key_binds
    fish_vi_key_bindings

    bind -M insert \ca beginning-of-line
    bind -M insert \ce end-of-line
    bind -M insert \cf accept-autosuggestion
end
set -g fish_key_bindings custom_key_binds

# Add some aliases I use often
alias g git

# Configure editor depending on what's installed.
if command -s nvim > /dev/null
  alias vim nvim
  alias vi nvim
  alias vimdiff 'nvim -d'
  set -g -x EDITOR nvim
  set -q -x GIT_EDITOR nvim
  set -q -x VISUAL nvim
else if command -s vim
  set -g -x EDITOR vim
  set -q -x GIT_EDITOR vim
  set -q -x VISUAL vim
end

# Set path
function prepend_to_path -d "Prepend the given dir to PATH if it exists and is not already in it"
    if test -d $argv[1]
        if not contains $argv[1] $PATH
            set -gx PATH "$argv[1]" $PATH
        end
    end
end

set -gx PATH "/sbin"
prepend_to_path "/bin"
prepend_to_path "/usr/sbin"
prepend_to_path "/usr/bin"
prepend_to_path "/usr/local/bin"
prepend_to_path "/usr/local/opt/git/share/git-core/contrib/diff-highlight"
prepend_to_path "/usr/local/opt/groovy/libexec/bin"
prepend_to_path "/usr/local/gradle/bin"
prepend_to_path "/usr/local/MacGPG2/bin"
prepend_to_path "$HOME/bin"

# Configure plenv
# The following line throws an error:
# setenv: Too many arguments
# with how the environment is being set up within fish
# as a work around set the environment using fish style syntax
# status --is-interactive; and . (plenv init -|psub)
set -q PLENV_ROOT; or set -l PLENV_ROOT $HOME/.plenv

prepend_to_path $PLENV_ROOT/shims
