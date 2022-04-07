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
    bind -M insert \cf nextd-or-forward-word
end
set -g fish_key_bindings custom_key_binds

# Add some aliases I use often
alias g git
alias fig docker-compose
alias d docker
if command -s kubecolor > /dev/null
  alias kc kubecolor
else
  alias kc kubectl
end

# Configure editor depending on what's installed.
if command -s nvim > /dev/null
  alias vim nvim
  alias vi nvim
  alias vimdiff 'nvim -d'
  set -gx EDITOR nvim
  set -gx GIT_EDITOR nvim
  set -gx VISUAL nvim
else if command -s vim > /dev/null
  set -gx EDITOR vim
  set -gx GIT_EDITOR vim
  set -gx VISUAL vim
end

fish_add_path "/sbin"
fish_add_path "/bin"
fish_add_path "/usr/sbin"
fish_add_path "/usr/bin"
fish_add_path "/usr/local/sbin"
fish_add_path "/usr/local/bin"
fish_add_path "/usr/local/opt/git/share/git-core/contrib/diff-highlight"
fish_add_path "/usr/local/opt/groovy/libexec/bin"
fish_add_path "/usr/local/gradle/bin"
fish_add_path "/usr/local/MacGPG2/bin"
fish_add_path "$HOME/.krew/bin"
fish_add_path "$HOME/bin"
fish_add_path "$HOME/.pgenv/bin"
fish_add_path "$HOME/.pgenv/pgsql/bin"
fish_add_path "$HOME/go/bin"

set -gx LESS "-F -X -R"
if command -s /usr/local/bin/bat > /dev/null
  set -gx BAT_THEME 'TwoDark'
  set -gx LESSOPEN '|/usr/local/bin/bat --theme TwoDark --color always %s'
else if command -s /usr/local/bin/src-hilite-lesspipe.sh > /dev/null
  set -gx LESSOPEN '| /usr/local/bin/src-hilite-lesspipe.sh %s'
else if command -s /usr/local/bin/highlight > /dev/null
  set -gx LESSOPEN '| /usr/local/bin/highlight --out-format=xterm256 %s'
end

eval (direnv hook fish)

kitty + complete setup fish | source
if command -v anyenv > /dev/null
  fish_add_path $HOME/.anyenv/bin
  source (anyenv init - fish|psub)
end

set -gx	FZF_DEFAULT_OPTS '--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a'
if test -e /usr/local/opt/asdf/asdf.fish
  source /usr/local/opt/asdf/asdf.fish
end

set -gx XDG_CONFIG_HOME $HOME/.config
