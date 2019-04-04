" Set flag to detect if we are in a location list or a quickfix list
let b:find_files_qf_list_type = empty(getloclist(0)) ? 'qf' : 'loc'

" Quickfix-local commands
command! -buffer -nargs=0 FilesOnly call find_files#qf#set_files_only(b:find_files_qf_list_type)
