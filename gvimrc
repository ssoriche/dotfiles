" set screen size
set lines=50 columns=136

if has("gui_macvim")
  " Command-T for CommandT
  macmenu &File.New\ Tab key=<nop>
  map <D-t> :CommandT<CR>
  macmenu &File.Open\ Tab\.\.\.<Tab>:tabnew key=<nop>
  map <D-T> :CommandTBuffer<CR>

  " Command-Shift-F for Ack
  macmenu Window.Toggle\ Full\ Screen\ Mode key=<nop>
  map <D-F> :Ack<space>

  " Command-e for ConqueTerm
  map <D-e> :call StartTerm()<CR>

  function! TabClose()
    try
      :tabclose
    catch /E784/  " Can't close last tab.
      :qa  " Close it anyway (quit all).
    endtry
  endfunction

  " Command+w closes tab, not file.
  macmenu &File.Close key=<nop>
  map <D-w> :call TabClose()<CR>

  " Accordion splits
  " http://www.reddit.com/r/vim/comments/eiolp/accordion_hopping_through_splits/
  set winminheight=0
  map <D-Up> <c-w>k<c-w>_
  map <D-Down> <c-w>j<c-w>_

endif


" Setup GUI configuration
"
" set guifont=Menlo\ Regular:h11
set guifont=Menlo\ for\ Powerline:h11
let g:Powerline_symbols = 'fancy'
set antialias anti

" GUI Options
" e - Add tab pages
" m - menu bar is present
" g - menu items that aren't active grey
" r - right hand scroll bar is always present
" t - include tearoff menu items (doesn't work in OS X)
set guioptions=egmrt

" Default gui color scheme
set background=dark
" colorscheme solarized
colorscheme distinguished    " Default color scheme.
set transparency=4

" Highlight the current line
set cursorline

" Project Tree
autocmd VimEnter * call s:CdIfDirectory(expand("<amatch>"))

" Folding preferences
autocmd VimEnter * set foldmethod=syntax 
autocmd VimEnter * set foldcolumn=0 

" If the parameter is a directory, cd into it
function! s:CdIfDirectory(directory)
  let explicitDirectory = isdirectory(a:directory)
  let directory = explicitDirectory || empty(a:directory)

  if explicitDirectory
    exe "cd " . a:directory
  endif

  if directory
    NERDTree
    wincmd p
    bd
  endif

  if explicitDirectory
    wincmd p
  endif

endfunction

" NERDTree utility function
function! s:UpdateNERDTree(...)
  let stay = 0

  if(exists("a:1"))
    let stay = a:1
  end

  if exists("t:NERDTreeBufName")
    let nr = bufwinnr(t:NERDTreeBufName)
    if nr != -1
      exe nr . "wincmd w"
      exe substitute(mapcheck("R"), "<CR>", "", "")
      if !stay
        wincmd p
      end
    endif
  endif

  if exists("CommandTFlush")
    CommandTFlush
  endif
endfunction

" Utility functions to create file commands
function! s:CommandCabbr(abbreviation, expansion)
  execute 'cabbrev ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
endfunction

function! s:FileCommand(name, ...)
  if exists("a:1")
    let funcname = a:1
  else
    let funcname = a:name
  endif

  execute 'command -nargs=1 -complete=file ' . a:name . ' :call ' . funcname . '(<f-args>)'
endfunction

function! s:DefineCommand(name, destination)
  call s:FileCommand(a:destination)
  call s:CommandCabbr(a:name, a:destination)
endfunction

" Public NERDTree-aware versions of builtin functions
function! ChangeDirectory(dir, ...)
  execute "cd " . a:dir
  let stay = exists("a:1") ? a:1 : 1

  NERDTree

  if !stay
    wincmd p
  endif
endfunction

function! Touch(file)
  execute "!touch " . a:file
  call s:UpdateNERDTree()
endfunction

function! Remove(file)
  let current_path = expand("%")
  let removed_path = fnamemodify(a:file, ":p")

  if (current_path == removed_path) && (getbufvar("%", "&modified"))
    echo "You are trying to remove the file you are editing. Please close the buffer first."
  else
    execute "!rm " . a:file
  endif

  call s:UpdateNERDTree()
endfunction

function! Mkdir(file)
  execute "!mkdir -p " . a:file
  call s:UpdateNERDTree()
endfunction

" ConqueTerm wrapper
function! StartTerm()
  execute 'ConqueTerm ' . $SHELL . ' --login'
  setlocal listchars=tab:\ \ 
endfunction


function! Edit(file)
  if exists("b:NERDTreeRoot")
    wincmd p
  endif

  execute "e " . a:file

ruby << RUBY
  destination = File.expand_path(VIM.evaluate(%{system("dirname " . a:file)}))
  pwd         = File.expand_path(Dir.pwd)
  home        = pwd == File.expand_path("~")

  if home || Regexp.new("^" + Regexp.escape(pwd)) !~ destination
    VIM.command(%{call ChangeDirectory(system("dirname " . a:file), 0)})
  end
RUBY
endfunction

" Define the NERDTree-aware aliases
call s:DefineCommand("cd", "ChangeDirectory")
call s:DefineCommand("touch", "Touch")
call s:DefineCommand("rm", "Remove")
call s:DefineCommand("e", "Edit")
call s:DefineCommand("mkdir", "Mkdir")
