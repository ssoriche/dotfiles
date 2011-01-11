## generic boring crap
export EDITOR=vi
export LESS="-M -x 2 -R"
#export LESSOPEN='| /opt/local/bin/lesspipe.sh %s'
export MANPAGER="col -b | view -c 'set ft=man nomod nolist' -"
export PAGER=less
#export PAGER="view -"
export PATH=$HOME/bin:/usr/local/bin:$PATH
export VISUAL=vi
export CLICOLOR=1

## load all my custom functions
#for i in ~/.sh/functions/*; do
# . $i
#done

#eval `dircolors -b ~/.dir_colors | grep LS_COLORS`

export COPYFILE_DISABLE=1
export COPYFILE_EXTENDED_ATTRIBUTES_DISABLE=1

set -o vi
