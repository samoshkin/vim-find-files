" Loaded guard
if exists("g:loaded_find_files_plugin")
  finish
endif
let g:loaded_find_files_plugin = 1

" Public Settings
" Prefix for export commands
if !exists('g:find_files_command_name')
  let g:find_files_command_name = 'Find'
endif

" Default findprg (same to grepprg)
if !exists('g:find_files_findprg')
  let g:find_files_findprg = 'find .'
endif

" How to open new buffer when find results are shown in a "filelist" buffer
if !exists('g:find_files_buf_view_command')
  let g:find_files_buf_view_command = "enew"
endif

" Should the plugin define mappings for "filelist" buffer
if !exists('g:find_files_define_mappings')
  let g:find_files_define_mappings = 1
endif

" Declares default mappings for "filelist" buffer
if !exists('g:find_files_filelist_mappings')
  let g:find_files_filelist_mappings = {}
endif
call extend(g:find_files_filelist_mappings, {
      \ 'open': 'o',
      \ 'open_in_split': 'O',
      \ 'preview': 'p',
      \ 'close': 'q',
      \ }, 'keep')

" How to open preview from "filelist" buffer
if !exists('g:find_files_preview_command')
  let g:find_files_preview_command = "vsplit"
endif

" Define global "FindXXX" commands
if !empty(g:find_files_command_name)
  exe "command! -nargs=* -bang " . g:find_files_command_name . " :call find_files#execute(<q-args>, 'qf', <bang>0)"
  exe "command! -nargs=* -bang " . g:find_files_command_name . "A :call find_files#execute(<q-args>, 'args', <bang>0)"
  exe "command! -nargs=* -bang " . g:find_files_command_name . "B :call find_files#execute(<q-args>, 'buf', <bang>0)"
endif

" Conversion between:
" - quickfix list
" - buffer
" - args list
command! -nargs=0 Buf2Qf call <SID>convert_buffer_to_quickfix()
command! -nargs=0 Buf2Args call <SID>convert_buffer_to_args()

command! -nargs=0 Qf2Buf call <SID>convert_quickfix_to_buffer()
command! -nargs=0 Qf2Args call <SID>convert_quickfix_to_args()

command! -nargs=0 Args2Qf call <SID>convert_args_to_quickfix()
command! -nargs=0 Args2Buf call <SID>convert_args_to_buffer()


" Buffer -> X conversion
function s:convert_buffer_to_quickfix()
  let lines = getline(1, '$')
  let title = bufname('%')
  bdelete
  call find_files#qf#set('qf', lines, title)
endfunction

function s:convert_buffer_to_args()
  let lines = getline(1, '$')
  bdelete
  call find_files#args#set(lines, 0)
endfunction

" Quickfix -> X conversion
function s:convert_quickfix_to_buffer()
  let files = uniq(find_files#qf#get('qf'))
  call find_files#buf#new(files, 'From Quickfix')
  cclose
endfunction

function s:convert_quickfix_to_args()
  let files = uniq(find_files#qf#get('qf'))
  call find_files#args#set(files, 0)
endfunction

" Args -> X conversion
function s:convert_args_to_buffer()
  let files = find_files#args#get()
  call find_files#buf#new(files, 'From Args')
endfunction

function s:convert_args_to_quickfix()
  let files = find_files#args#get()
  call find_files#qf#set('qf', files, 'From Args')
endfunction
