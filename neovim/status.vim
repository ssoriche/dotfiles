" ViM Lightline
""""""""""""""""""""""""""""""""
set laststatus=2 " Always show status line
let g:lightline = {
      \ 'colorscheme': 'tenderplus',
      \ 'mode_map': { 'n': 'NORMAL' },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"⭤":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}'
      \ },
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'filename' ], ['ctrlpmark'] ],
      \   'right': [ [ 'percent' ], ['fugitive'] ]
      \ },
      \ 'inactive': {
      \   'right': [ [ 'percent' ] ]
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))'
      \ },
      \ 'component_function': {
      \   'modified': 'MyModified',
      \   'readonly': 'MyReadonly',
      \   'fugitive': 'MyFugitive',
      \   'fileformat': 'MyFileFormat',
      \   'filename': 'MyFilename',
      \   'filetype': 'MyFiletype',
      \   'fileencoding': 'MyFileencoding',
      \   'ctrlpmark': 'CtrlPMark',
      \   'mode': 'MyMode',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

let g:lightline.component = {
  \ 'filename': '%{expand("%:t") == "ControlP" ? g:lightline.ctrlp_item : expand("%:p")}'
  \ }

function! MyModified()
  let fname = expand('%:t')
  return (fname =~ 'NERD_tree' ? '' :
       \ &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-')
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? '' : ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
       \ (&ft == 'unite' ? unite#get_status_string() :
       \  fname =~ 'NERD_tree' ? '' :
       \  &ft == 'vimfiler' ? vimfiler#get_status_string() :
       \  &ft == 'vimshell' ? vimshell#get_status_string() :
       \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
       \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  if winwidth(0) > 70
    if &ft !~? 'vimfiler\|gundo' && exists("*fugitive#head")
      let _ = fugitive#head()
      return strlen(_) ? ' '._ : ''
    endif
  endif
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 50 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 40 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return ''
  " return winwidth(0) > 100 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  let fname = expand('%:t')
  return fname =~ 'NERD_tree' ? 'TREE' :
        \ &ft == 'help' ? 'HELP' :
        \ &ft == 'unite' ? 'UNITE' :
        \ &ft == 'vimfiler' ? '' :
        \ &ft == 'ControlP' ? 'CtrlP' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP' && has_key(g:lightline, 'ctrlp_item')
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction
