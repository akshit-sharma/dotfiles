function! s:MakeToCC()
  exe "!compiledb"
  exe "!compiledb -n make"
endfunction
com! MakeToCC call s:MakeToCC()
