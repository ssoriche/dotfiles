set nocompatible    " Don't sacrifice anything for Vi compatibility.
set encoding=utf-8  " In case $LANG doesn't have a sensible value.

" pathogem.vim lets us keep plugins etc in their own folders under ~/.vim/bundle.
" http://www.vim.org/scripts/script.php?script_id=2332
" filetype off and then on again afterwards for ftdetect files to work properly.
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

filetype plugin indent on  " Load plugin and indent settings for the detected filetype.
syntax on                  " Syntax highlighting.
set number                 " Show gutter with line numbers.
set ruler                  " Show line, column and scroll info in status line.
set laststatus=2           " Always show status bar.
set modelines=10           " Use modeline overrides.
set showcmd                " Show partially typed command sequences.
set scrolloff=3            " Minimal number of lines to always show above/below the caret.
set hidden                 " Allow unsaved buffers to be put in the background

" set up colorscheme
colorscheme solarized      " Default color scheme.
let g:solarized_visibility='low'
let g:solarized_hitrail = 1
set background=dark

" Statusline.
" %< truncation point
" \  space
" %f relative path to file
" %m modified flag [+] (modified), [-] (unmodifiable) or nothing
" %r readonly flag [RO]
" %y filetype [ruby]
" %= split point for left and right justification
" %-14.( %)  block of fixed width 14 characters
" %l current line
" %c current column
" %V current virtual column as -{num} if different from %c
" %P percentage through buffer
set statusline=%<\ %f\ %m%r%y\ %=%-14.(%l,%c%V%)\ %P\ 

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

" Set completion configration
set completeopt=menu,longest

" NERDTree configuration
let NERDTreeIgnore=['\.rbc$', '\~$']
map <leader>n :NERDTreeToggle<CR>
map <leader>N :NERDTreeFind<CR>" Reveal current file

" Supertab configuration
let g:SuperTabLongestEnchanced=1

" SQLUtil configuration
let g:sqlutil_align_where = 0     " don't align operators in the WHERE clause
let g:sqlutil_keyword_case = '\U' " change SQL keywords to upper case
let g:sqlutil_align_comma = 1
vmap <silent>sf <Plug>SQLU_Formatter<CR>

" Command-T configuration
let g:CommandTMaxHeight=20
let g:CommandTMatchWindowAtTop=1

" Gundo configuration
nnoremap <F5> :GundoToggle<CR>

" Extradite configuration
nnoremap <F4> :Extradite<CR>

" Easier buffer swapping
nnoremap ` <C-^>

" Configure leader for easymotion
let g:EasyMotion_leader_key = '<Leader>m'

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

function! OpenURI()
  :ruby open_uri
endfunction

if has("autocmd")
  " make and python use real tabs
  au FileType make                                     set noexpandtab
  au FileType python                                   set noexpandtab

  " Thorfile, Rakefile and Gemfile are Ruby
  au BufRead,BufNewFile {Gemfile,Rakefile,Thorfile,config.ru}    set ft=ruby

  " md, markdown, and mk are markdown and define buffer-local preview
  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn} call s:setupMarkup()

  " Uncomment to have txt files hard-wrap automatically.
  "au BufRead,BufNewFile *.txt call s:setupWrapping()
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

" Make Y behave like C or D
nnoremap Y y$

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

" Directories for swp files
set backupdir=~/.vim/backup
set directory=~/.vim/backup

" Configure Tags
set tags=./.vimtags;
let Tlist_GainFocus_On_ToggleOpen = 1      " taglist window has focus when opened
let Tlist_Use_Horiz_Window=1               " Horizontal Tag list window
let Tlist_Show_One_File=1                  " Only show the current buffers tags
let Tlist_Sort_Type = 'name'               " Sort tags by name
let Tlist_Ctags_Cmd='/usr/local/bin/ctags' " Don't use OS X ctags
let g:easytags_cmd = '/usr/local/bin/ctags'
let g:eastags_dynamic_files = 1
let g:easytags_file='./.vimtags'


" Un-highlight search matches
nnoremap <leader><leader> :noh<CR>

" Print highlighting scope at the current position.
" http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
map <leader>S :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

map <leader>T :CommandTFlush<CR>

" Open URL from this line (OS X only).
map <leader>u :call OpenURI()<CR>

" AlignMap default for <leader>w= interferes with CamelCaseMotion
autocmd VimEnter * unmap <leader>w=

" Ack/Quickfix windows
map <leader>q :cclose<CR>
" Previous fix and center line.
map - :cprev<CR> zz
" Next fix and center line.
map + :cnext<CR> zz

" Opens an edit command with the path of the currently edited file filled in
map <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Create a split on the given side.
" From http://technotales.wordpress.com/2010/04/29/vim-splits-a-guide-to-doing-exactly-what-you-want/ via joakimk.
nmap <leader><left>   :leftabove  vsp<CR>
nmap <leader><right>  :rightbelow vsp<CR>
nmap <leader><up>     :leftabove  sp<CR>
nmap <leader><down>   :rightbelow sp<CR>

" Get rid of all NERDCommenter mappings except one.
let g:NERDCreateDefaultMappings=0
autocmd VimEnter * map # <Plug>NERDCommenterToggle

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

" Configuration to highlight and strip end of line whitespace
" http://sartak.org/2011/03/end-of-line-whitespace-in-vim.html
autocmd InsertEnter * syn clear EOLWS | syn match EOLWS excludenl /\s\+\%#\@!$/
autocmd InsertLeave * syn clear EOLWS | syn match EOLWS excludenl /\s\+$/
highlight EOLWS ctermbg=red guibg=red

" <C-r> to trigger and also to close the scratch buffer.
" TODO: <LocalLeader>r? Reuse split? Pluginize? Handle gets if possible?

function! RubyRun()
  redir => m
  silent w ! ruby
  redir END
  new
  put=m
" Fix Ctrl+M linefeeds.
  silent %s///
" Fix extraneous leading blank lines.
  1,2d
  " Set a filetype so we can define a 'close' mapping with the 'run' mapping.
  set ft=ruby-runner
  " Make it a scratch (temporary) buffer.
  set buftype=nofile
  set bufhidden=hide
  setlocal noswapfile
endfunction


function! <SID>StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
nmap <silent> <Leader><space> :call <SID>StripTrailingWhitespace()<CR>

if has("autocmd") && has("gui_macvim")
  au FileType ruby map <buffer> <D-r> :call RubyRun()<CR>
  au FileType ruby imap <buffer> <D-r> <Esc>:call RubyRun()<CR>
  au FileType ruby-runner map <buffer> <D-r> ZZ
endif

au BufNewFile,BufRead *.gradle setf groovy
au BufNewFile,BufRead *.spl setf sql
