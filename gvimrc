" set screen size
set lines=50 columns=136

if has("gui_macvim")
  " Command-Shift-F for Ag
  macmenu Window.Toggle\ Full\ Screen\ Mode key=<nop>
  map <D-F> :Ag<space>

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

  nmap <silent> <leader>h <Plug>DashSearch
  nmap <silent> <leader>H <Plug>DashGlobalSearch
endif


" Setup GUI configuration
"
" set guifont=Menlo\ Regular:h11
set guifont=Menlo\ for\ Powerline:h11
set antialias anti

" {{{ Airline Configuration
let g:Powerline_symbols = 'fancy'
let g:airline_theme='tomorrow'
" }}}

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
colorscheme hybrid  " Default color scheme.
set transparency=4

" Highlight the current line
set cursorline

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

" ConqueTerm wrapper
function! StartTerm()
  execute 'ConqueTerm ' . $SHELL . ' --login'
  setlocal listchars=tab:\ \ 
endfunction
