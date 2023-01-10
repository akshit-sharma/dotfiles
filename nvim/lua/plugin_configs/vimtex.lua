vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_view_general_viewer = 'zathura'
vim.g.vimtex_view_forward_search_on_start = false
vim.g.vimtex_compiler_latexmk = {
  build_dir = 'build',
  options = {
    '-shell-escape',
    '-verbose',
    '-file-line-error',
    '-synctex=1',
    '-interaction=nonstopmode',
  },
}

-- vim.g.vimtex_latexmk_options = "-shell-escape -verbose -file-line-error -synctex=1 -interaction=nonstopmode"
-- vim.g.vimtex_compiler_latexmk = "lualatex"
-- vim.cmd([[ syntax enable ]])
-- vim.g.vimtex_compiler_latexmk_engines = {
-- 	_        = '-lualatex',
-- 	pdflatex = '-pdf',
-- 	dvipdfex = '-pdfdvi',
-- 	lualatex = '-lualatex',
-- 	xelatex  = '-xelatex'
-- }
