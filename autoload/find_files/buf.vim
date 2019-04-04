" Create a new buffer and show list of files
function find_files#buf#new(content, ...)
  let title = get(a:, "1", "[Scratch]")

  " Create new buffer with filetype=findfiles
  exe g:find_files_buf_command
  let w:scratch = 1
  setlocal filetype=findfiles
  silent! exe "file! " . fnameescape(title)

  " Populate buffer with a content
  if type(a:content) == type([])
    call setline(1, a:content)
  else
    call setline(1, split(a:content, "\n"))
  endif
endfunction
