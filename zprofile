source ~/.profile

autoload -U colors
export HISTFILE=~/.zhistory
export HISTSIZE=3000
export SAVEHIST=2000

# export PS1='%m!%n:%~%(!.#.$) '
#export PS1="%~$(print '%{\e[1m%}%(!.%{\e[31m%}#.%{\e[32m%}$)%{\e[0m%}') "
export PS1="[%n@%m:%~]%# "
# export RPS1="%m@%D{%H%M%S}:%h"
unsetopt nomatch
#export GIT_EXTERNAL_DIFF=$HOME/bin/gitchdiff
export LC_CTYPE=en_US.UTF-8
