" Plug Bundle Configuration {{{
call plug#begin('~/.config/nvim/plugged')

" the tpope section {{{

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'

" Considering
" Plug 'tpope/vim-speeddating'

" }}}

Plug 'w0ng/vim-hybrid'
Plug 'bling/vim-airline'
Plug 'airblade/vim-gitgutter'

" Considering
" Plug 'svermeulen/vim-easyclip'

Plug 'Valloric/YouCompleteMe', { 'for': 'cpp', 'do': './install.sh' }
autocmd! User YouCompleteMe call youcompleteme#Enable()

call plug#end()
" }}}

let g:python_host_prog = '/usr/local/bin/python'

set background=dark
colorscheme hybrid
set hidden                 " Allow unsaved buffers to be put in the background

" Leader
let mapleader = " "
let localleader = "\\"

" Toggle line numbering
set nonumber
set relativenumber
nnoremap <silent> <F7> :exe'se'&nu+&rnu?'rnu!':'nu'<CR>

" 2 spaces indent.
set softtabstop=2
set shiftwidth=2
set expandtab

" {{{ Leader shortcuts for system clipboard
vmap <leader>y "+y
vmap <leader>d "+d
nmap <leader>y "+y
nmap <leader>d "+d
nmap <leader>p "+p
nmap <leader>P "+P
vmap <leader>p "+p
vmap <leader>P "+P
" }}}

" Airline Settings {{{
let g:airline_powerline_fonts = 1
let g:airline_theme='tomorrow'
" }}}

" Setup folding {{{
set foldmethod=syntax
set foldcolumn=0
nnoremap <leader>z zMzvzz

" Enter to toggle folds, unless in Quickfix
nnoremap <silent> <CR> za
vnoremap <silent> <CR> za

autocmd CmdwinEnter * nnoremap <buffer> <cr> <cr>
autocmd FileType qf nnoremap <buffer> <cr> <cr>
" }}}

" FileType specific settings {{{
" Vim {{{
augroup ft_vim
    au!

    au FileType vim setlocal foldmethod=marker
    au FileType help setlocal textwidth=78
augroup END
" }}}
" }}}

