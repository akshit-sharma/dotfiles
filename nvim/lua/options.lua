local vimopt = vim.opt

vimopt.belloff = "all"

vim.wildmode = { "full", "longest", "lastused" }

vim.wildoptions = "pum"

vim.backup = false

vimopt.encoding = "utf-8"
vimopt.fileencoding = "utf-8"
vimopt.fileencodings = "utf-8"

vimopt.hlsearch = true
vimopt.ignorecase = false
vimopt.smartcase = true

vimopt.wildignore = { "*.o", "*~", "*.pyc", "*pycache*" }

vimopt.pumblend = 20
vimopt.pumheight = 5

vimopt.foldenable = false

vimopt.fillchars = {
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋",
}

vimopt.termguicolors = true

vimopt.updatetime = 300

vimopt.tabstop = 2
vimopt.shiftwidth = 2
vimopt.softtabstop = 2
vimopt.expandtab = true
vimopt.autoindent = true
vimopt.copyindent = true

vimopt.number = true
vimopt.relativenumber = true

vimopt.signcolumn = "yes"

vimopt.cmdheight = 2

vimopt.backspace = { "eol", "start", "indent" }

vimopt.list = true

vimopt.listchars = {
    tab = "»·",
    trail = "·",
    extends = "↪",
    precedes = "↩",
}

vimopt.termguicolors = true

vimopt.background = "dark"

--vim.cmd 'colorscheme darcula-solid'
--vim.cmd 'set termguicolors'
