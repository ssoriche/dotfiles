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

# Create aliases so that console vi/vim uses MacVim
if [[ -e "/usr/local/Cellar/macvim/v7.3-53/MacVim.app/Contents/MacOS/Vim" ]]; then
  alias vi=/usr/local/Cellar/macvim/v7.3-53/MacVim.app/Contents/MacOS/Vim 
  alias vim=/usr/local/Cellar/macvim/v7.3-53/MacVim.app/Contents/MacOS/Vim 
fi


## load all my custom functions
#for i in ~/.sh/functions/*; do
# . $i
#done

#eval `dircolors -b ~/.dir_colors | grep LS_COLORS`

export COPYFILE_DISABLE=1
export COPYFILE_EXTENDED_ATTRIBUTES_DISABLE=1

set -o vi
