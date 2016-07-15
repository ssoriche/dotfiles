## generic boring crap
export EDITOR=vi
export LESS="-M -x 2 -R"
if [ -x /usr/local/bin/src-hilite-lesspipe.sh ]; then
  export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'
fi

export MANPAGER="/bin/sh -c \"unset PAGER;col -b -x | \
    vim -R -c 'set ft=man nomod nolist' -c 'map q :q<CR>' \
    -c 'map <SPACE> <C-D>' -c 'map b <C-U>' \
    -c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' -\""

export PAGER=less
#export PAGER="view -"
export VISUAL=vi
export CLICOLOR=1

## load all my custom functions
#for i in ~/.sh/functions/*; do
# . $i
#done

#eval `dircolors -b ~/.dir_colors | grep LS_COLORS`

export COPYFILE_DISABLE=1
export COPYFILE_EXTENDED_ATTRIBUTES_DISABLE=1
export GROOVY_HOME=/usr/local/opt/groovy/libexec
export GRADLE_HOME=/usr/local/gradle
export PATH=/Applications/Postgres.app/Contents/Versions/9.3/bin:$HOME/bin:/usr/local/bin:$PATH:$GROOVY_HOME/bin:$GRADLE_HOME/bin
export NODE_PATH=/usr/local/lib/node_modules

if [[ -e "/usr/local/instantclient_11_2" ]]; then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/instantclient_11_2
  export PATH=$PATH:/usr/local/instantclient_11_2
fi

set -o vi
[[ -s "$HOME/perl5/perlbrew/etc/bashrc" ]] && source ~/perl5/perlbrew/etc/bashrc
if which plenv > /dev/null; then eval "$(plenv init -)"; fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
[[ -s "/Users/ssoriche/.rvm/scripts/rvm" ]] && source "/Users/ssoriche/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -r "$HOME/.smartcd_config" ] && ( [ -n $BASH_VERSION ] || [ -n $ZSH_VERSION ] ) && source ~/.smartcd_config
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

if which brew > /dev/null; then
  if [ -x `brew --prefix git`/share/git-core/contrib/diff-highlight/diff-highlight ]; then
    export PATH=`brew --prefix git`/share/git-core/contrib/diff-highlight/:$PATH
  fi
fi

if which nvim > /dev/null; then
  alias vim="nvim"
  alias vi="nvim"
  alias vimdiff='nvim -d'
  export EDITOR=nvim
fi
