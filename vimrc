set nocompatible    " Don't sacrifice anything for Vi compatibility.
set encoding=utf-8  " In case $LANG doesn't have a sensible value.

" pathogem.vim lets us keep plugins etc in their own folders under ~/.vim/bundle.
" http://www.vim.org/scripts/script.php?script_id=2332
" filetype off and then on again afterwards for ftdetect files to work properly.
filetype off
call pathogen#infect()

filetype plugin indent on  " Load plugin and indent settings for the detected filetype.
syntax on                  " Syntax highlighting.
set number                 " Show gutter with line numbers.
set ruler                  " Show line, column and scroll info in status line.
set laststatus=2           " Always show status bar.
set modelines=10           " Use modeline overrides.
set showcmd                " Show partially typed command sequences.
set scrolloff=3            " Minimal number of lines to always show above/below the caret.
set hidden                 " Allow unsaved buffers to be put in the background
set shellcmdflag=-lc " Shell is to act as a login shell thus setting the evironment properly


" set up colorscheme
colorscheme jellybeans    " Default color scheme.
set background=dark

" 2 spaces indent.
set softtabstop=2
set shiftwidth=2
set expandtab

" No pipes in vertical split separators.
set fillchars=vert:\ 

" Searching.
set hlsearch    " Highlight results.
set incsearch   " Search-as-you-type.
set ignorecase  " Case-insensitive…
set smartcase   " …unless phrase includes uppercase.

set nojoinspaces                " 1 space, not 2, when joining sentences.
set backspace=indent,eol,start  " Allow backspacing over everything in insert mode.

set nowrap   " don't wrap for anything

" Leader
let mapleader = ","
let localleader = "\\"

" Set completion configration
set completeopt=menu,longest

" SQLUtil configuration
let g:sqlutil_align_where = 0     " don't align operators in the WHERE clause
let g:sqlutil_keyword_case = '\U' " change SQL keywords to upper case
let g:sqlutil_align_comma = 1
vmap <silent>sf <Plug>SQLU_Formatter<CR>

set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,tmp,public/uploads,.vimtags,*.class

" Gundo configuration
nnoremap <F5> :GundoToggle<CR>

" Extradite configuration
nnoremap <F2> :Extradite<CR>

" Toggle paste
set pastetoggle=<F8>

" Move to the last change
nnoremap gl `.

" Easier buffer swapping
nnoremap <bs> <C-^>

" Quickreturn
inoremap <c-cr> <esc>A<cr>
inoremap <s-cr> <esc>A:<cr>

" Configure leader for easymotion
let g:EasyMotion_leader_key = '<Leader>m'

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

" Remember last location in file, but not for commit messages.
if has("autocmd")
  au BufReadPost * if &filetype !~ 'commit\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

" OS X only due to use of `open`. Adapted from
" http://vim.wikia.com/wiki/Open_a_web-browser_with_the_URL_in_the_current_line
" Uses John Gruber's URL regexp: http://daringfireball.net/2010/07/improved_regex_for_matching_urls

if has("ruby")
ruby << EOF
  def open_uri
    re = %r{(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\((?:[^\s()<>]+|(?:\([^\s()<>]+\)))*\))+(?:\((?:[^\s()<>]+|(?:\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))}

    line = VIM::Buffer.current.line
    urls = line.scan(re).flatten

    if urls.empty?
      VIM::message("No URI found in line.")
    else
      system("open", *urls)
      VIM::message(urls.join(" and "))
    end
  end
EOF
endif

" Hit S in command mode to save, as :w<CR> is a mouthful and MacVim
" Command-S is a bad habit when using terminal Vim.
" We overload a command, but use 'cc' instead anyway.
noremap S :w<CR>

" Make Y consistent with C and D - yank to end of line, not full line.
nnoremap Y y$

" Map Q to something useful (e.g. QQ to hard-break current line).
" Otherwise Q enters the twilight zone of the 'Ex' mode.
noremap Q gq

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Select (linewise) the text you just pasted (handy for modifying indentation):
nnoremap <leader>v V`]

" Move by screen lines instead of file lines.
" http://vim.wikia.com/wiki/Moving_by_screen_lines_instead_of_file_lines
noremap <Up> gk
noremap <Down> gj
noremap k gk
noremap j gj
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" Save a file as root.
cabbrev w!! w !sudo tee % > /dev/null<CR>:e!<CR><CR>

" Bubble single lines
nmap <C-Up> [e
nmap <C-Down> ]e
" Bubble multiple lines
vmap <C-Up> [egv
vmap <C-Down> ]egv

" Tab/shift-tab to indent/outdent in visual mode.
vmap <Tab> >gv
vmap <S-Tab> <gv

" Use sane regexes
:nnoremap / /\v " this conflicts with the mapping from IndexedSearch, need to fix
vnoremap / /\v

" Remap H & L for begging and end of line
noremap H ^
noremap L g_

" Directories for swp files
set backupdir=~/.vim/backup/
set directory=~/.vim/backup//

" Configure Tags {{{
set tags=.vimtags;
let Tlist_GainFocus_On_ToggleOpen = 1      " taglist window has focus when opened
let Tlist_Use_Horiz_Window=1               " Horizontal Tag list window
let Tlist_Show_One_File=1                  " Only show the current buffers tags
let Tlist_Sort_Type = 'name'               " Sort tags by name
let Tlist_Ctags_Cmd='/usr/local/bin/ctags' " Don't use OS X ctags
let g:autotagTagsFile='.vimtags'
let g:autotagCtagsCmd='/usr/local/bin/ctags'

map <F3> :Tlist<CR>
nnoremap <leader><cr> :silent !/usr/local/bin/ctags -R -f .vimtags .<cr>
" }}}


" Un-highlight search matches
nnoremap <leader><space> :noh<CR>

" Print highlighting scope at the current position.
" http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
map <leader>S :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Open URL from this line (OS X only).
map <leader>u :call OpenURI()<CR>

" AlignMap default for <leader>w= interferes with CamelCaseMotion
autocmd VimEnter * unmap <leader>w=

" Ack settings {{{

" Ack for the last search.
nnoremap <silent> <leader>? :execute "Ack! '" . substitute(substitute(substitute(@/, "\\\\<", "\\\\b", ""), "\\\\>", "\\\\b", ""), "\\\\v", "", "") . "'"<CR>"'"'"
" }}}

" Ack/Quickfix windows
map <leader>q :cclose<CR>
" Previous fix and center line.
map - :cprev<CR> zz
" Next fix and center line.
map + :cnext<CR> zz

" Opens an edit command with the path of the currently edited file filled in
map <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Use the current word under the cursor in a substitution.
:nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" Create a split on the given side.
" From http://technotales.wordpress.com/2010/04/29/vim-splits-a-guide-to-doing-exactly-what-you-want/ via joakimk.
nmap <leader><left>   :leftabove  vsp<CR>
nmap <leader><right>  :rightbelow vsp<CR>
nmap <leader><up>     :leftabove  sp<CR>
nmap <leader><down>   :rightbelow sp<CR>

" Invisible characters
set listchars=trail:.,tab:>-,eol:$
set nolist
:noremap <leader>i :set list!<CR> " Toggle invisible chars"

" Remove octal from number formats so numbers with leading 0s increment
" properly
set nrformats=hex

" Configure Java Syntax
let java_highlight_java_lang_ids=1
let java_highlight_java_io=1

" Settings for VimClojure
let vimclojure#HighlightBuiltins=1      " Highlight Clojure's builtins
let vimclojure#ParenRainbow=1           " Rainbow parentheses'!

" Setup folding {{{
set foldmethod=syntax
set foldcolumn=0
nnoremap <leader>z zMzvzz
" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za
" }}}

" Change Case
inoremap <C-u> <esc>gUiwea

" Clean trailing whitespace
nnoremap <leader>w :%s/\s\+$//<cr>:let @/=''<cr>

" Send visual selection to gist.github.com as a private, filetyped Gist
" Requires the gist command line too (brew install gist)
vnoremap <leader>G :w !gist -p -t %:e \| pbcopy<cr>

" Set preferences for Perl {{{
augroup ft_vim
    au!

    :let perl_fold=1
    :let perl_include_pod=1
    nnoremap <silent> _t :%!perltidy -q<Enter>
    vnoremap <silent> _t :!perltidy -q<Enter>
augroup END
" }}}

if has("autocmd") && has("gui_macvim")
  au FileType ruby map <buffer> <D-r> :call RubyRun()<CR>
  au FileType ruby imap <buffer> <D-r> <Esc>:call RubyRun()<CR>
  au FileType ruby-runner map <buffer> <D-r> ZZ
endif

au BufNewFile,BufRead *.gradle setf groovy
au BufNewFile,BufRead *.spl setf sql
au BufRead,BufNewFile *.t set filetype=perl | compiler perlprove

" Syntastic Settings {{{
let g:syntastic_perl_efm_program='~/.vim/tools/efm_perl.pl'
run SyntasticEnable perl
" }}}

let g:Powerline_symbols = 'fancy'

" CtrlP Settings {{{
let g:ctrlp_match_window_bottom = 0
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_map = '<leader>,'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_split_window = 0
let g:ctrlp_max_height = 20
let g:ctrlp_mruf_relative = 1
let g:ctrlp_mruf_last_entered = 1
let g:ctrlp_mruf_exclude = 'tmp/.*\|temp/.*\|\.git/.*'
let g:ctrlp_prompt_mappings = {
\ 'PrtSelectMove("j")':   ['<c-j>', '<down>', '<s-tab>'],
\ 'PrtSelectMove("k")':   ['<c-k>', '<up>', '<tab>'],
\ 'PrtHistory(-1)':       ['<c-n>'],
\ 'PrtHistory(1)':        ['<c-p>'],
\ 'ToggleFocus()':        ['<c-tab>'],
\ }
let g:ctrlp_extensions = ['tag']
let g:ctrlp_root_markers = ['.lvimrc'] " add the local lvimrc to to top of root markers
let g:ctrlp_custom_ignore = {
  \ 'dir': 'build\|target\|bin'
  \ }

nnoremap <leader>. :CtrlPBufTag<cr>
autocmd BufEnter,BufUnload * call ctrlp#mrufiles#list(expand('<abuf>', 1)) " sort the buffer list by last entered
" }}}

" Next and Last {{{

" Motion for "next/last object".  "Last" here means "previous", not "final".
" Unfortunately the "p" motion was already taken for paragraphs.
"
" Next acts on the next object of the given type in the current line, last acts
" on the previous object of the given type in the current line.
"
" Currently only works for (, [, {, b, r, B, ', and ".
"
" Some examples (C marks cursor positions, V means visually selected):
"
" din'  -> delete in next single quotes                foo = bar('spam')
"                                                      C
"                                                      foo = bar('')
"                                                                C
"
" canb  -> change around next parens                   foo = bar('spam')
"                                                      C
"                                                      foo = bar
"                                                               C
"
" vil"  -> select inside last double quotes            print "hello ", name
"                                                                        C
"                                                      print "hello ", name
"                                                             VVVVVV

onoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
xnoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
onoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>
xnoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>

onoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
xnoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
onoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>
xnoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>

function! s:NextTextObject(motion, dir)
  let c = nr2char(getchar())

  if c ==# "b"
      let c = "("
  elseif c ==# "B"
      let c = "{"
  elseif c ==# "r"
      let c = "["
  endif

  exe "normal! ".a:dir.c."v".a:motion.c
endfunction

" }}}

" Vim {{{
augroup ft_vim
    au!

    au FileType vim setlocal foldmethod=marker
    au FileType help setlocal textwidth=78
augroup END
" }}}

" Error toggles ----------------------------------------------------------- {{{
command! ErrorsToggle call ErrorsToggle()
function! ErrorsToggle() " {{{
  if exists("w:is_error_window")
    unlet w:is_error_window
    exec "q"
  else
    exec "Errors"
    lopen
    let w:is_error_window = 1
  endif
endfunction " }}}

nmap <silent> <f4> :ErrorsToggle<cr>

" }}}
