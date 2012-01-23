# My dotfiles

This started off as a fork from Janus, but I've continued to modify and adapt it to my own needs.

## Install

Checkout this repo into `~/.dotfiles`. Then install the dotfiles:

    rake install

This rake task will not replace existing files, but it will replace existing symlinks.

The dotfiles will be symlinked, e.g. `~/.bash_profile` symlinked to `~/.dotfiles/bash_profile`.

### <.replace>

If e.g. `~/.dotfiles/gitconfig` contains `<.replace github-token>` then

 * that bit will be replaced with the contents of `~/.github-token`
 * the resulting file will be written to `~/.dotfiles/gitconfig` directly, not symlinked
 
So if you want to make changes to that file, make them in `~/dotfiles/gitconfig` and then run `rake install` again.

Changes to symlinked files without `<.replace>` bits do not require a `rake install` on every change as they're symlinked.


## Vim

I'm assuming MacVim (`brew install macvim`) and at least Vim 7.

Vim plugins are each their own directory under vim/bundles thanks to [Pathogen](http://www.vim.org/scripts/script.php?script_id=2332).

Most are included in this repository as git submodules, so you need to fetch them after cloning this repository:

    git submodule update --init

## Extras

The `extras` directory contains additional configuration files that are not dotfiles:

