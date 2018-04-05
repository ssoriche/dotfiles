# THEME PURE #
set fish_function_path $HOME/.config/fish/functions/theme-pure $fish_function_path

function fish_mode_prompt
# Turn off mode indictor
end

function custom_key_binds
    fish_vi_key_bindings

    bind -M insert \ca beginning-of-line
    bind -M insert \ce end-of-line
    bind -M insert \cn accept-autosuggestion
end
set -g fish_key_bindings custom_key_binds

# Add some aliases I use often
alias g git

# Configure editor depending on what's installed.
if command -s nvim > /dev/null
  alias vim nvim
  alias vi nvim
  alias vimdiff 'nvim -d'
  set -gx EDITOR nvim
  set -gx GIT_EDITOR nvim
  set -gx VISUAL nvim
else if command -s vim
  set -gx EDITOR vim
  set -gx GIT_EDITOR vim
  set -gx VISUAL vim
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
prepend_to_path "/usr/local/sbin"
prepend_to_path "/usr/local/bin"
prepend_to_path "/usr/local/opt/git/share/git-core/contrib/diff-highlight"
prepend_to_path "/usr/local/opt/groovy/libexec/bin"
prepend_to_path "/usr/local/gradle/bin"
prepend_to_path "/usr/local/MacGPG2/bin"
prepend_to_path "$HOME/bin"

set -gx LESS "-F -X -R"
if command -s /usr/local/bin/src-hilite-lesspipe.sh > /dev/null
  set -gx LESSOPEN '| /usr/local/bin/src-hilite-lesspipe.sh %s'
end
if command -s /usr/local/bin/highlight > /dev/null
  set -gx LESSOPEN '| /usr/local/bin/highlight --out-format=xterm256 %s'
end

# Configure plenv
# The following line throws an error:
# setenv: Too many arguments
# with how the environment is being set up within fish
# as a work around set the environment using fish style syntax
# status --is-interactive; and . (plenv init -|psub)
set -q PLENV_ROOT; or set -lx PLENV_ROOT $HOME/.plenv

prepend_to_path $PLENV_ROOT/shims

status --is-interactive; and source (rbenv init -|psub)
