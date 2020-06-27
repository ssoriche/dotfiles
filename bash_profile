source ~/.bash/path.sh
source ~/.bash/env.sh
source ~/.bash/prompt.sh
source ~/.bash/aliases.sh
source ~/.bash/functions.sh

 if [ -f $(brew --prefix)/etc/bash_completion ]; then
 . $(brew --prefix)/etc/bash_completion
 fi
