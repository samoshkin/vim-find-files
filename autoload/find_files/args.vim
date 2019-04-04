" Get list of files stored in argslist
function find_files#args#get()
  let i = 0
  let files = []
  while i < argc()
    call add(l:files, argv(i))
    let i = i + 1
  endwhile

  return l:files
endfunction

" Set argslist with a list of files
function find_files#args#set(files, should_edit_first_arg)
  %argdelete
  for l:file in a:files
    exe "argadd " . l:file
  endfor

  if a:should_edit_first_arg
    argument 1
  else
    echo "Args list is set"
  endif
endfunction
