## generic boring crap
export EDITOR=vi
export LESS="-M -x 2 -R"
if [ -x /usr/local/bin/src-hilite-lesspipe.sh ]; then
  export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'
fi
export MANPAGER="col -b | view -c 'set ft=man nomod nolist' -"
export PAGER=less
#export PAGER="view -"
export VISUAL=vi
export CLICOLOR=1

# Create aliases so that console vi/vim uses MacVim
if [[ -e "$HOME/Applications/MacVim.app/Contents/MacOS/Vim" ]]; then
  alias vi=$HOME/Applications/MacVim.app/Contents/MacOS/Vim 
  alias vim=$HOME/Applications/MacVim.app/Contents/MacOS/Vim 
fi


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

set -o vi
[[ -s "$HOME/perl5/perlbrew/etc/bashrc" ]] && source ~/perl5/perlbrew/etc/bashrc
if which plenv > /dev/null; then eval "$(plenv init -)"; fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
[[ -s "/Users/ssoriche/.rvm/scripts/rvm" ]] && source "/Users/ssoriche/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -r "$HOME/.smartcd_config" ] && ( [ -n $BASH_VERSION ] || [ -n $ZSH_VERSION ] ) && source ~/.smartcd_config
