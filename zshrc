# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set to the name theme to load.
# Look in ~/.oh-my-zsh/themes/
export ZSH_THEME="steeef"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git osx vi-mode cpanm brew perl autojump git-extras gradle npm node)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
source $HOME/.profile

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

# https://github.com/yanyingwang/antibody
if which antibody > /dev/null; then
  source <(antibody init)

  antibody bundle zsh-users/zsh-syntax-highlighting
  antibody bundle lukechilds/zsh-nvm
fi
