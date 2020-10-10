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
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-eunuch'

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
Plug 'arcticicestudio/nord-vim'
Plug 'rakr/vim-one'
" }}}

" syntax {{{
Plug 'sheerun/vim-polyglot'
Plug 'vim-perl/vim-perl', { 'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny', 'branch': 'dev' }
Plug 'fatih/vim-go', {'do':':GoInstallBinaries'}
" }}}

Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'rking/ag.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'michaeljsmith/vim-indent-object'
Plug 'wellle/targets.vim'
Plug 'hotwatermorning/auto-git-diff'
Plug 'itchyny/lightline.vim'
Plug 'cocopon/lightline-hybrid.vim'
Plug 'w0rp/ale'
Plug 'skaji/syntax-check-perl'
Plug 'sbdchd/neoformat'
Plug 'machakann/vim-highlightedyank'

" Displays git messages under the cursor for the highlighted
" item. Requires 0.40 of Neovim that can be installed via:
" brew install neovim --HEAD
Plug 'rhysd/git-messenger.vim'

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
Plug 'Scuilion/markdown-drawer'
Plug 'mzlogin/vim-markdown-toc'


Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --no-bash' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/gv.vim'
Plug 'pbogut/fzf-mru.vim'
Plug 'vimwiki/vimwiki'

" An ack/ag/pt/rg powered code search and view tool, takes advantage of Vim
" 8's power to support asynchronous searching, and lets you edit file in-place
" with Edit Mode.
Plug 'dyng/ctrlsf.vim'

" Plugin to do diffs recursively on directories
Plug 'will133/vim-dirdiff'

" For displaying CSV files in columns
Plug 'chrisbra/csv.vim'

" Sends selected text to carbon.now.sh to make a pretty
" image of source code from
Plug 'kristijanhusak/vim-carbon-now-sh'

" Completion framework and language server client, smarter tab completion.
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" Adds ALE support to lightline status line
Plug 'maximbaz/lightline-ale'

call plug#end()
" }}}

let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'

set hidden                 " Allow unsaved buffers to be put in the background

" Using a variable to set the colorscheme at the top of the file, because I
" change this often, also syntax folding of the plugins really does make this
" the top of the file. Color scheme option settings are now at the very
" bottom.
set termguicolors
let my_colorscheme = 'jellybeans'

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

" auto-git-diff {{{
" The auto update takes forever to scroll through. Instead set to manual
" update and when enter is pressed, update the git diff
let g:auto_git_diff_disable_auto_update=1
autocmd FileType gitrebase nmap <buffer> <cr> <Plug>(auto_git_diff_manual_update) :<C-u>call auto_git_diff#show_git_diff()<CR>
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
autocmd BufNewFile,BufRead *.tt setf tt2html
" }}}
" }}}

" ctrlp settings {{{
let g:ctrlp_cmd = 'CtrlPBuffer'
let g:ctrlp_match_window = 'top,order:ttb,min:1,max:20,results:20'
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

" fzf {{{
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

function! s:fzf_statusline()
  " Override statusline as you like
  highlight fzf1 ctermfg=161 ctermbg=251
  highlight fzf2 ctermfg=23 ctermbg=251
  highlight fzf3 ctermfg=237 ctermbg=251
  setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
endfunction

" autocmd! User FzfStatusLine call <SID>fzf_statusline()
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
let g:ale_linters = {
      \  'perl' : ['syntax-check'],
      \  'ansible' : ['ansible-lint']
      \ }

let b:ale_sh_shellcheck_exclusions = 'SC1090,SC1091'

highlight clear ALEErrorSign
highlight clear ALEWarningSign
" hi clear SignColumn
" Mappings in the style of unimpaired-next
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous)
nmap <silent> ]w <Plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)
" }}}

" {{{ CoC
let g:coc_global_extensions = [
  \ 'coc-lists',
  \ 'coc-marketplace',
  \ 'coc-go',
  \ 'coc-yaml',
  \ 'coc-lua',
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-emoji',
  \ 'coc-snippets',
  \ 'coc-docker'
  \ ]

  " \ 'coc-git',

let g:coc_node_path='/usr/local/bin/node'

" }}}

" {{{ perl
let g:perl_no_subprototype_error = 1
let g:perl_sub_signatures        = 1
let g:perl_fold                  = 1
let g:perl_nofold_packages       = 1
let g:perl_no_subprototype_error = 1
let g:deoplete#enable_at_startup = 1
" }}}

" {{{ golang
let g:go_fmt_experimental = 1
let g:go_fmt_command = "gofumports"
let g:go_fmt_options = {'gofumports': '-local go.zr.org'}
let g:go_highlight_string_spellcheck = 1
" The lack of syntax highlighting was driving me nuts
" https://github.com/fatih/vim-go/wiki/Tutorial#beautify-it
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4
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

command! -range -nargs=* Figlet     <line1>,<line2>! figlet -w 75 -p

" Dealing with colorscheme here. Discovered that by setting the variables
" after the color scheme was set that italic comments didn't always work right
" and also things like highlighting the current line background. Moving all
" color scheme settings to the bottom alleviates this problem.

" ColorScheme Space Gray {{{
if my_colorscheme == 'spaygray'
  let g:spacegray_use_italics = 1
  let g:lightline.colorscheme = 'jellybeans'
  " colorscheme spacegray
endif
" }}}

" ColorScheme Jellybeans {{{
if my_colorscheme == 'jellybeans'
  let g:jellybeans_use_term_italics = 1
  let g:lightline.colorscheme = 'jellybeans'
  " colorscheme jellybeans
endif
" }}}

" ColorScheme Nord {{{
if my_colorscheme == 'nord'
  set cursorline
  let g:nord_italic = 1
  let g:nord_underline = 1
  let g:nord_italic_comments = 1
  " let g:nord_comment_brightness = 15
  let g:nord_cursor_line_number_background = 1
  let g:lightline.colorscheme = 'nord'
  " colorscheme nord
endif
" }}}

" ColorScheme one {{{
if my_colorscheme == 'one'
  let g:one_allow_italics = 1
  let g:lightline.colorscheme = 'one'
endif
" }}}

" slight kludge to get it so the variable `my_colorscheme` can be reused
" to set the actual color scheme and not repeat myself.
exe 'colorscheme ' . my_colorscheme

function! s:fzf_next(idx)
  let commands = ['Buffers', 'GFiles?', 'Files', 'History']
  execute commands[a:idx]
  let next = (a:idx + 1) % len(commands)
  let previous = (a:idx - 1) % len(commands)
  execute 'tnoremap <buffer> <silent> <c-f> <c-\><c-n>:close<cr>:sleep 100m<cr>:call <sid>fzf_next('.next.')<cr>'
  execute 'tnoremap <buffer> <silent> <c-b> <c-\><c-n>:close<cr>:sleep 100m<cr>:call <sid>fzf_next('.previous.')<cr>'
endfunction

command! Cycle call <sid>fzf_next(0)
nnoremap <silent> <leader><space> :Cycle<cr>
