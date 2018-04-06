" Plug Bundle Configuration {{{
call plug#begin('~/.config/nvim/plugged')

" the tpope section {{{

Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-endwise'

" Considering
" Plug 'tpope/vim-speeddating'

" }}}

" colour schemes {{{
Plug 'w0ng/vim-hybrid'
Plug 'chriskempson/tomorrow-theme', { 'rtp': 'vim'}
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline-themes'
Plug 'jacoborus/tender'
Plug 'ajh17/Spacegray.vim'
Plug 'fenetikm/falcon'
" }}}

" syntax {{{
Plug 'sheerun/vim-polyglot'
Plug 'vim-perl/vim-perl', { 'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny', 'branch': 'dev' }
" }}}

Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'Shougo/deoplete.nvim'
Plug 'rking/ag.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'michaeljsmith/vim-indent-object'
Plug 'wellle/targets.vim'
Plug 'hotwatermorning/auto-git-diff'
Plug 'itchyny/lightline.vim'
Plug 'cocopon/lightline-hybrid.vim'
Plug 'w0rp/ale'
Plug 'sbdchd/neoformat'
Plug 'machakann/vim-highlightedyank'

" Considering
" Plug 'svermeulen/vim-easyclip'
Plug 'wellle/visual-split.vim'
Plug 'mbbill/undotree'
Plug 'ddrscott/vim-side-search'
Plug 'junegunn/vim-easy-align'
Plug 'ssoriche/perl_environment.vim'
Plug 'SirVer/ultisnips'
Plug 'whatyouhide/vim-gotham'
Plug 'frioux/vim-lost'

Plug 'Shougo/denite.nvim'
Plug 'chemzqm/vim-easygit'
Plug 'chemzqm/denite-git'

call plug#end()
" }}}

let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'
let g:spacegray_use_italics = 1

set termguicolors
set background=dark
colorscheme falcon
set hidden                 " Allow unsaved buffers to be put in the background

" Mouse
set mouse=a " at some point this changed from being the default and my scroll wheel stopped working.

" Leader
let mapleader = " "
let localleader = "\\"

" Toggle line numbering
set number
set relativenumber
nnoremap <silent> <F7> :exe'se'&nu+&rnu?'rnu!':'nu'<CR>

" 2 spaces indent.
set softtabstop=2
set shiftwidth=2
set expandtab

" Hate wrapping, never do it
set nowrap

" Do not change location to first non-whitespace character when jumping
" with block selection
set nosol

" Searching. {{{
" Use sane regexes
autocmd VimEnter * nnoremap / /\v
vnoremap / /\v

set ignorecase  " Case-insensitive…
set smartcase   " …unless phrase includes uppercase.

" Un-highlight search matches
nnoremap <leader>/ :noh<CR>
" }}}

" Tab completion
set wildmode=longest,list,full
set wildmenu

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

" Spelling, because I need it
set spell
autocmd FileType gitcommit setlocal spell

" Highlight trailing whitespace {{{
highlight ExtraWhitespace guibg=DarkCyan ctermbg=Blue
au ColorScheme * highlight ExtraWhitespace guibg=DarkCyan ctermbg=Blue
au BufWinEnter * match ExtraWhitespace /\s\+$\| \+\ze\t/
au BufWrite * match ExtraWhitespace /\s\+$\| \+\ze\t/
" }}}

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
" let g:airline_powerline_fonts = 1
" let g:airline_theme='hybrid'
" }}}

" Lightline {{{
so ~/.config/nvim/status.vim
let g:falcon_lightline = 1
let g:lightline.colorscheme='falcon'
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

" Convienence Remaps {{{
" make ' jump to row and column
nnoremap ' `
" make ` jump to row
nnoremap ` '
" }}}

" FileType specific settings {{{
" Vim {{{
augroup ft_vim
    au!

    au FileType vim setlocal foldmethod=marker
    au FileType help setlocal textwidth=78
augroup END
autocmd FileType perl PerlSetEnvironment
" }}}
" }}}

" ctrlp settings {{{
let g:ctrlp_cmd = 'CtrlPBuffer'
let g:ctrlp_match_window = 'top,order:ttb,min:1,max:20,results:20'
let g:ctrlp_map = '<leader><space>'
let g:ctrlp_mruf_relative = 1
let g:ctrlp_custom_ignore = {
  \ 'dir': 'build\|target\|bin\|worktree'
  \ }

autocmd BufEnter,BufUnload * call ctrlp#mrufiles#list(expand('<abuf>', 1)) " sort the buffer list by last entered
nnoremap <leader>. :CtrlPBufTag<cr>

function! CtrlpSeed()
  :let g:ctrlp_default_input = substitute(tolower(expand('<cword>')),'::','/','g')
  :CtrlP
  :let g:ctrlp_default_input = ''
endfunction

nnoremap <silent> <leader>g :call CtrlpSeed()<cr>
let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
      \ -g ""'
" }}}

" undotree {{{
nnoremap <F5> :UndotreeToggle<cr>
" }}}

" GitGutter {{{
  set updatetime=250
" }}}

" EasyAlign {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)<Paste>
" }}}

" {{{ Neoformat
nmap = :Neoformat<CR>
vmap = :Neoformat<CR>
" }}}

" {{{ ale
let g:ale_set_highlights = 0
" For iTerm2 requires that `Use Unicode Version 9 Widths` be enabled
let g:ale_sign_error = '💩'
let g:ale_sign_warning = '🔥'
let g:ale_linters = {'perl': ['perl', 'perlcritic']}
highlight clear ALEErrorSign
highlight clear ALEWarningSign
" hi clear SignColumn
" }}}

" {{{ perl
let g:perl_no_subprototype_error = 1
let g:perl_sub_signatures        = 1
let g:perl_fold                  = 1
let g:perl_nofold_packages       = 1
let g:perl_no_subprototype_error = 1
let g:deoplete#enable_at_startup = 1
" }}}

" tmux will only forward escape sequences to the terminal if surrounded by a DCS sequence
" http://sourceforge.net/mailarchive/forum.php?thread_name=AANLkTinkbdoZ8eNR1X2UobLTeww1jFrvfJxTMfKSq-L%2B%40mail.gmail.com&forum_name=tmux-users

if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
