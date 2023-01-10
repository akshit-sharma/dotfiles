
highlight TooMuchChars cterm=underline
au BufWinEnter * let w:m1=matchadd('TooMuchChars', '\%>80v.\+', -1)

