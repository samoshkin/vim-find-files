# vim-find-files

Search for files and show results in a quickfix list, a new buffer, or populate the Vim's argument list.

## Overview
`vim-find-files` plugin allows you to search for files in a directory hierarchy. This is same to using GNU `find` in a shell, but now you don't have to leave Vim.

Out of the box, Vim has `grepprg` setting and accompanying `:grep` command to search for a text matching a pattern in multiple files. `vim-find-files` plugin brings `findprg` setting and `:Find` command to search for file names matching a pattern.


**Features**:
- Show matching files in different views: quickfix list (default), new buffer, argument list, custom user-defined view. Buffer option is useful, when you want to further edit the file list.
- Convert between views. For example, you can start with a quickfix list to review matches, convert to a buffer to remove some files from a list, and finally convert to the argument list to execute `:grep` command next against it.
- Open and preview files from the file list buffer using predefined mappings
- Search relative to the `cwd` or to the current file's directory.
- Filter any quickfix list to keep unique files only. See files with at least one match. Useful when you run `:grep` command and want to see list of matched files, instead of individual matches. This is similar to running `grep --files-with-matches` in a shell.

## Example

Use your favorite Vim plugin manager to install the plugin.

Specify find backend in your `vimrc`. Either use GNU `find`, or some advanced tools like [fd](https://github.com/sharkdp/fd). Make sure to define `$*` and `$d` placeholders for search pattern and starting directory respectively.
```vim
let g:find_files_findprg = 'find $d ! -type d $*'

" Or Use sharkdp/fd as a backend
" let g:find_files_findprg = 'fd --hidden $* $d'
```
Use `:Find {args}` command to search for files and show them in a quickfix list. Note, that `args` value depends on the selected `findprg` backend. For example, `:Find -name *.vim` is the valid command when using GNU `find`, whereas simple `:Find .vim` is the valid choice for [fd](https://github.com/sharkdp/fd). The rule of thumb is to respect underlying find program interface.

Use `:FindA {args}` or `:FindB {args}` command variants to show results in the argument list or in a new buffer respectively.

Use one of `:Buf2Qf`, `:Buf2Args`, `:Qf2Buf`, `:Qf2Args`, `:Args2Qf`, `:Args2Buf` commands to convert between views on the fly: `quickfix <---> buffer <---> argslist`.


## Features and customization

### Find command

By default following commands are exported:
- `:Find {args}`, search for files and show results in a quickfix list
- `:FindA {args}`, populate Vim's argument list with the found files
- `:FindB {args}`, show search results in a new buffer

If you don't like the default command name, you can override it. In the example below, `Search`, `SearchA`, `SearchB` commands would be exported respectively.
```vim
let g:find_files_command_name = 'Search'
```
If you don't want any commands exported at all, set the command name to an empty string.

```vim
let g:find_files_command_name = ''
```

In the latter case, you can define your own commands by referring to `find_files#execute()` function.

```vim
command! -nargs=* -bang MyCommand :call find_files#execute(<q-args>, 'qf', <bang>0)
```

Signature of the `find_files#execute(args, view, is_relative)` function:

1. `args`, arguments passed to the `findprg` backend
2. `view`, how to show search results. Valid values: `qf`, `buf`, `args`, or user-defined `funcref`.
2. `is_relative`, whether search should be relative to the current file's directory or to the `cwd`.


### File list buffer
When you're using `:FindB` command, search results are shown in a new buffer. 

By default, `enew` command is used to open the buffer. If you want to open a buffer in a new split, or in a new tab:

```vim
" or 'new', 'tabnew'
let g:find_files_buf_view_command = "vnew"
```

Extra buffer-local mappings are defined:

- `o`, open file under the cursor in the same window
- `O`, open file under the cursor in a new split and focus it
- `p`, preview file under the cursor in a new split, and keep focus in the file list buffer
- `q`, close buffer with search results and any preview windows

You can override mappings, if they hide default Vim's behavior:

```vim
let g:find_files_filelist_mappings = {
  \ 'open': '<CR>',
  \ 'preview': '<F2>',
  \ }
```

Or you can disable mappings completely:

```vim
let g:find_files_define_mappings = 0
```

When file is opened with `O` or `p` shortcuts, vertical split is used by default. You can override this behavior:

```vim
" Default is 'vsplit'
let g:find_files_preview_command = "split"
```

By default, the buffer has following settings: `nowrap`, `nospell`, `nofoldenable`, `norelativenumber`. Note, that the buffer has dedicated `filetype=filelist`, so you can apply own buffer-local customizations using `FileType` auto command:
 
```vim
augroup my_find_files_customization
  au!

  " Custom mappings
  au FileType filelist nnoremap <silent> <buffer> <CR> gf

  " Custom settings
  au FileType filelist setlocal wrap
augroup END
```


### Convert between views

You're not limited to a single view only. You can convert between views back and forth as you go.

The example workflow can look as follows:

1. Run `:Find {args}` command. Review search results in a quickfix list.
2. Run `:Qf2Buf` command. Open in a new buffer. Remove some files from the list.
3. Run `:Buf2Args` command. Populate Vim's argument list with the filtered files list from the buffer.
4. Run `:grep {pattern} ##` to search for text matching a pattern, but only within a files from the argument list.

Workflow #2:

1. Run `:gpep {pattern}` command. Review individual matches using a quickfix list.
2. Run `:Qf2Buf` command. Show only matched unique files in a new buffer.

Following commands are exported. Compose them as you need:
- `Buf2Args`, populate the arguments list with files from the buffer
- `Buf2Qf`, populate the quickfix list with files from the buffer
- `Qf2Buf`, get unique files from the quickfix list and show in a new buffer
- `Qf2Args`, populate the arguments list with unique files from the quickfix list
- `Args2Qf`, convert arguments list to quickfix list
- `Args2Buf`, get files from the arguments list and show in a new buffer


### Search relative to current file

By default, when you run `:Find` command, search is relative to current `cwd`. You can suffix the command with a bang (`!`) to force search relative to the directory of the current file. Useful, when you want to limit a search to directory of the current file or any nested directories.

```vim
: Find! {pattern}
```

### Keep files only in a quickfix list

You can process any quickfix list to keep only files with at least one match, instead of focusing on individual matches. This is somewhat similar to running `grep --files-with-matches` in a shell.

Run `:FilesOnly` command, which is available in the quickfix window only. It will create a new quickfix list. If you want to get back to the original list, use `:colder` Vim command.


### Show search results in a custom view
 
If you're not satisfied with predefined views (quickfix, buffer, arguments list) and looking for a custom way to render search results, you can provide your own implementation.

First, define custom function responsible for showing search results.

```vim
" Arguments:
" - list of files
" - underlying 'find' command that yield search results
function s:show_files(files, command)
  " Your own implementation
  " Show files however you like
endfunction
```

Second, declare custom `Find` command, and pass the function above as a callback to `find_files#execute()` call.
```vim
" Define custom 'Find' command
command! -nargs=* -bang FindX :call find_files#execute(<q-args>, function('s:show_files'), <bang>0)
```
