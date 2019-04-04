" Buf options
setlocal buftype=nofile bufhidden=hide nobuflisted noswapfile hidden

" Don't wrap lines, no folding, no spell checking
setlocal nowrap textwidth=0 nospell nofoldenable

" Relative line numbers don't make sense
setlocal norelativenumber
setlocal number

" Define local buffer filelist-specific mappings
if g:find_files_define_mappings
  let s:mappings = g:find_files_buf_mappings

  exe "nnoremap <silent> <buffer> " . s:mappings['open'] . " gf"
  exe "nnoremap <silent> <buffer> " . s:mappings['open_in_split'] . " :call <SID>open_file(0)<CR>"
  exe "nnoremap <silent> <buffer> " . s:mappings['preview'] . " :call <SID>open_file(1)<CR>"
  exe "nnoremap <silent> <buffer> " . s:mappings['close'] . " :call <SID>close_filelist()<CR>"
endif

" Open file under the cursor in a new split
" When is_preview, keep focus in filelist window
function s:open_file(is_preview)
  " First, close all preview windows, so there's only one preview window in a tab
  call s:close_preview_windows()

  " Remember win number of filelist buffer
  let curwin = winnr()

  " Opew a new split, and file under the cursor in the split
  exe g:find_files_buf_preview_command
  norm gf
  let w:find_files_is_preview_win = 1

  " If opened in a preview mode, keep focus in filelist window
  if a:is_preview
    exe curwin . "wincmd w"
  endif
endfunction

" Close any opened filelist preview windows
function s:close_preview_windows()
  let windows = filter(range(1, winnr('$')), 'getwinvar(v:val, "find_files_is_preview_win")')

  for l:win in reverse(windows)
    exe l:win . "wincmd c"
  endfor
endfunction

" Close filelist buffer/window, including any opened preview windows
function s:close_filelist()
  call s:close_preview_windows()
  bdelete
endfunction
