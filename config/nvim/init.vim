" Plug Bundle Configuration {{{
call plug#begin('~/.config/nvim/plugged')

" the tpope section {{{

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'

" Considering
" Plug 'tpope/vim-speeddating'

" }}}

Plug 'ctrlpvim/ctrlp.vim'
Plug 'w0ng/vim-hybrid'
Plug 'bling/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'Shougo/deoplete.nvim'
Plug 'wincent/ferret'
Plug 'Raimondi/delimitMate'
Plug 'chriskempson/tomorrow-theme', { 'rtp': 'vim'}

" Considering
" Plug 'svermeulen/vim-easyclip'

call plug#end()
" }}}

let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

set background=dark
colorscheme Tomorrow-Night-Bright
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

" Hate wrapping, never do it
set nowrap

" Searching. {{{
" Use sane regexes
autocmd VimEnter * nnoremap / /\v
vnoremap / /\v

set ignorecase  " Case-insensitive…
set smartcase   " …unless phrase includes uppercase.

" Un-highlight search matches
nnoremap <leader>/ :noh<CR>
" }}}

" Easier buffer swapping
nnoremap <bs> <C-^>

" Easy Macro Application
nnoremap Q @q
vnoremap Q :norm @q<cr>

" Proper command mode navigation
cnoremap <c-k> <up>
cnoremap <c-j> <down>

" Toggle paste
set pastetoggle=<F8>

" Set iTerm title
set title

" Help File speedups, <enter> to follow tag, delete for back {{{
au filetype help nnoremap <buffer><cr> <c-]>
au filetype help nnoremap <buffer><bs> <c-T>
au filetype help nnoremap <buffer>q :q<CR>
au filetype help set nonumber
" }}}

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

" ctrlp settings {{{
let g:ctrlp_cmd = 'CtrlPBuffer'
let g:ctrlp_match_window = 'top,order:ttb,min:1,max:20,results:20'
let g:ctrlp_map = '<leader><space>'
let g:ctrlp_mruf_relative = 1
let g:ctrlp_custom_ignore = {
  \ 'dir': 'build\|target\|bin'
  \ }

autocmd BufEnter,BufUnload * call ctrlp#mrufiles#list(expand('<abuf>', 1)) " sort the buffer list by last entered
nnoremap <leader>. :CtrlPBufTag<cr>

function! CtrlpSeed()
  :let g:ctrlp_default_input = tolower(expand('<cword>'))
  :CtrlP
  :let g:ctrlp_default_input = ''
endfunction

nnoremap <silent> <leader>g :call CtrlpSeed()<cr>
let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
      \ -g ""'
" }}}

let g:deoplete#enable_at_startup = 1
