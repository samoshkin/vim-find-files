" Get list of file names from a quickfix or location list
function find_files#qf#get(list_type)
  let list = a:list_type ==# 'qf' ? getqflist() : getloclist(0)
  return map(l:list, 'bufname(v:val["bufnr"])')
endfunction

" Create new quickfix/location list with a list of files
function find_files#qf#set(list_type, files, title)
  " Map file names to format, as understood by 'errorformat' (similar to grepformat)
  let filenames = map(a:files, 'v:val . ":1:" . fnamemodify(v:val, ":t")')

  if a:list_type ==# 'qf'
    cexpr l:filenames

    " Set QF window title
    if !empty(a:title)
      call setqflist([], 'r', { 'title': a:title })
    endif
  else
    lexpr l:filenames

    " Set location list window title
    if !empty(a:title)
      call setloclist(0, [], 'r', { 'title': a:title })
    endif
  endif
endfunction

" Extract unique file names from qf list and show in a new qf list
function find_files#qf#set_files_only(list_type)
  let files = uniq(find_files#qf#get(a:list_type))
  call find_files#qf#set(a:list_type, files, 'Files Only')
  cfirst
endfunction
