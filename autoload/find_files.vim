" Execute findprg command and render results in selected view
" View is one of:
" - args, set args list
" - buf, show in a new buffer
" - qf, show in quickfix list
" - funcref, custom callback to render results
function find_files#execute(args, view, is_relative)
  if (empty(a:args))
    call s:echo_warning("Seach text is not specified")
    return
  endif

  " Set global mark to easily get back after we're done with a search
  normal mF

  " Resolve directory to search relative to
  let dir = a:is_relative ? expand("%:.:h") : "."

  " Composing "findprg" command
  let command = g:find_files_findprg
  let command = substitute(command, "\\$\\*", a:args, "")
  let command = substitute(command, "\\$d", dir, "")

  " Execute command and parse into list of files
  let output = system(command)
  if v:shell_error
    call s:echo_warning("Find backend failed")

    echom "$ " . l:command
    echom output
    return
  endif

  if output =~ '^\s*$'
    call s:echo_warning("No matching files")
    return
  endif

  " Show found files in a selected view
  let files = split(output, "\n")
  if a:view ==# 'qf'
    call find_files#qf#set('qf', l:files, "$ " . command)
  endif

  if a:view ==# 'buf'
    call find_files#buf#new(l:files, "$ " . command)
  endif

  if a:view ==# 'args'
    call find_files#args#set(l:files, 1)
  endif

  " When a view is a callback function
  if type(a:view) == v:t_func
    call a:view(l:files, command)
  endif
endfunction

function s:echo_warning(message)
  echohl WarningMsg
  echo a:message
  echohl None
endfunction
