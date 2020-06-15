# Dirs
alias o="open ."  # OS X, open in Finder

# Management
alias dots="nvim ~/.dotfiles"
alias reload='source ~/.bash_profile && echo "sourced ~/.bash_profile"'
alias redot='cd ~/.dotfiles && gpp && rake install; cd -'

# Shell
alias c='clear'
alias la='ls -alh'
alias cdd='cd -'  # back to last directory
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Portable ls with colors
if ls --color -d . >/dev/null 2>&1; then
  alias ls='ls --color=auto'  # Linux
elif ls -G -d . >/dev/null 2>&1; then
  alias ls='ls -G'  # BSD/OS X
fi

# Git
alias g="git"
alias gl="git log"
alias gs="git status"
alias gw="git show"
alias gd="git diff"  # What's changed but not yet added?
alias gdc="git diff --cached"  # What's added but not yet committed?
alias gc="git commit -a -m"
alias gco="git commit -m"  # "only"
alias gca="git add . && git commit -a -m"  # "all"
alias gp='git push'
alias gpp='git pull && git push'
alias go="git checkout"
alias gb="git checkout -b"
alias got="git checkout -"
alias gom="git checkout master"
alias gr="git branch -d"
alias grr="git branch -D"
alias gcp="git cherry-pick"
alias gam="git commit --amend"

# Xcode versioning
# http://www.blog.montgomerie.net/easy-iphone-application-versioning-with-agvtool
alias xv="agvtool what-version; agvtool what-marketing-version"  # Show versions.
alias xvbump="agvtool bump -all"  # Bump build number.
alias xvset="agvtool new-marketing-version"  # Set user-visible version: xvset 2.0

# Servers
alias grace='sudo apachectl graceful'
alias rst="touch tmp/restart.txt && echo touched tmp/restart.txt"  # Passenger

alias hosts='sudo vim /etc/hosts'

# Home network
# On gf's computer, quiet music and disconnect Airfoil from speakers (to free them up for me).
alias hush="cat ~/.bash/lib/hush.scpt | ssh heli osascript; echo hushed."

# Work

alias akdb='mysqladmin -u root -f drop auktion_development create auktion_development && mysql -u root auktion_development < ~/Downloads/auction_clean.sql && rake db:migrate'
alias akdbg='scp www-data@sdb:/var/data/auktion/auction_clean.sql ~/Downloads/ && akdb'
# Use with autologin Greasemonkey script: http://gist.github.com/raw/487186/ccf2c203741c1e39eb45416d02bc58b2728427fc/basefarm_auto.user.js
alias vpn='open -a Firefox "https://ssl-vpn.sth.basefarm.net/ssl"'
alias stage='OLD=true BRANCH=master cap staging deploy:migrations'
alias stagedb='OLD=true BRANCH=master cap staging deploy:import_db'

# Testbot
alias cpu2='pushd ~/Sites/auktion; rake testbot:runner:set_cpu_cores[2]; popd'
alias cpu1='pushd ~/Sites/auktion; rake testbot:runner:set_cpu_cores[1]; popd'
alias cpu0='pushd ~/Sites/auktion; rake testbot:runner:stop; popd'

# LiveReload
alias lr="nohup /usr/bin/rake livereload &> /dev/null &"

alias vim="nvim"
