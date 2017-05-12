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
alias vim nvim
alias vi nvim
