## .zshrc
## $Id: zshrc,v 1.2 2005/05/20 13:25:32 rjbs Exp $

# The following lines were added by compinstall
_compdir=/usr/share/zsh/${ZSH_VERSION}/functions
[[ -z $fpath[(r)$_compdir] ]] && fpath=($fpath $_compdir)

autoload -U compinit
compinit

zstyle ':completion:*' completer _expand _complete # _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=5
# End of lines added by compinstall

## stop history searches at beginning/end of list
zstyle ':completion:*:history-words' stop verbose

## Ignore directories named CVS
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS' 
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS' 

## Make sure modules are loaded
zmodload -i zsh/zutil
zmodload -i zsh/compctl
zmodload -i zsh/complete
zmodload -i zsh/complist
zmodload -i zsh/computil
zmodload -i zsh/main
zmodload -i zsh/zle
zmodload -i zsh/rlimits
zmodload -i zsh/parameter

## setup predicting completer
autoload -U predict-on
zle -N predict-on
zle -N predict-off

autoload -U zrecompile

bindkey -v
bindkey "" history-incremental-search-backward
bindkey -s "^?" "^H"
bindkey "^[[3~" delete-char
bindkey "^W" backward-delete-word
unsetopt CORRECT CORRECT_ALL # diable spllchecking
unsetopt CDABLE_VARS         # disable cd to homedir
# unsetopt BANG_HIST           # "foo!" should not be special

local _myhosts
_myhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
zstyle ':completion:*' hosts $_myhosts
