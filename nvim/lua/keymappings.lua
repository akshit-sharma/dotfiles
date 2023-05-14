
vim.g.mapleader = '\\'

local key_mapper = function(mode, key, result, map_dict)
  map_dict = map_dict or NOREMAP_SILENT
  vim.api.nvim_set_keymap(mode, key, result, map_dict)
end

key_mapper('n', vim.g.mapleader, '<NOP>')
key_mapper('n', '<Leader>e', ':Lexplore<CR>')
--key_mapper('n', 'j', 'gj')
--key_mapper('n', 'k', 'gk')

key_mapper('i', '<C-j>', 'copilot#Accept("<CR>")', { silent=true, expr=true })
local function suggestOneWord()
  local suggestion = vim.fn['copilot#Accept']("")
  local bar = vim.fn['copilot#TextQueuedForInsertion']()
  return vim.fn.split(bar, '[ .]\zs')[0]
end
--[[
vim.keymap.set('i', '<C-a>', function()
  require('copilot.suggestion').accept_word()
end, { silent=true, expr=true })

--]]

vim.g.copilot_no_tab_map = true

key_mapper('n', '<Leader><C-t>', ':lua TerminalOnce()<CR>', NOREMAP_SILENT)
key_mapper('n', '<Leader>t', ':botright 20new | terminal<CR>', NOREMAP_SILENT)
key_mapper('n', '<Leader>T', '<cmd>tabnew | terminal<CR>', NOREMAP_SILENT)
key_mapper('t', '<C-\\><Esc>', '<C-\\><C-n>', {noremap=true, silent=true})
-- use ALT+HJKL to move between windows and terminals
key_mapper('t', '<C-w>h', '<C-\\><C-n><C-w>h', NOREMAP_SILENT)
key_mapper('t', '<C-w>j', '<C-\\><C-n><C-w>j', NOREMAP_SILENT)
key_mapper('t', '<C-w>k', '<C-\\><C-n><C-w>k', NOREMAP_SILENT)
key_mapper('t', '<C-w>l', '<C-\\><C-n><C-w>l', NOREMAP_SILENT)
--key_mapper('i', '<A-h>', '<C-\\><C-n><C-w>h', NOREMAP_SILENT)
--key_mapper('i', '<A-j>', '<C-\\><C-n><C-w>j', NOREMAP_SILENT)
--key_mapper('i', '<A-k>', '<C-\\><C-n><C-w>k', NOREMAP_SILENT)
--key_mapper('i', '<A-l>', '<C-\\><C-n><C-w>l', NOREMAP_SILENT)
--key_mapper('n', '<A-h>', '<C-w>h', NOREMAP_SILENT)
--key_mapper('n', '<A-j>', '<C-w>j', NOREMAP_SILENT)
--key_mapper('n', '<A-k>', '<C-w>k', NOREMAP_SILENT)
--key_mapper('n', '<A-l>', '<C-w>l', NOREMAP_SILENT)

--key_mapper('n', '<Leader>ca', ':CodeActionMenu<CR>')
--key_mapper('n', '<Tab>', ':BufferNext<CR>')
--key_mapper('n', '<S-Tab>', ':BufferPrevious<CR>')
--key_mapper('n', '<C-Tab>', ':tabnext<CR>')
--key_mapper('n', '<C-S-Tab>', ':tabprevious<CR>')
key_mapper('n', '<Leader>o', ':Navbuddy<CR>')
key_mapper('n', '<Leader>v', ':Vista!!<CR>')

--[[

----- mapping for barbar -----
-- Move to previous/next
key_mapper('n', '<A-,>', '<Cmd>BufferPrevious<CR>', NOREMAP_SILENT)
key_mapper('n', '<A-.>', '<Cmd>BufferNext<CR>', NOREMAP_SILENT)
-- Re-order to previous/next
key_mapper('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', NOREMAP_SILENT)
key_mapper('n', '<A->>', '<Cmd>BufferMoveNext<CR>', NOREMAP_SILENT)
-- Goto buffer in position...
key_mapper('n', '<C-1>', '<Cmd>BufferGoto 1<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-2>', '<Cmd>BufferGoto 2<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-3>', '<Cmd>BufferGoto 3<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-4>', '<Cmd>BufferGoto 4<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-5>', '<Cmd>BufferGoto 5<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-6>', '<Cmd>BufferGoto 6<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-7>', '<Cmd>BufferGoto 7<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-8>', '<Cmd>BufferGoto 8<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-9>', '<Cmd>BufferGoto 9<CR>', NOREMAP_SILENT)
key_mapper('n', '<C-0>', '<Cmd>BufferLast<CR>', NOREMAP_SILENT)
-- Pin/unpin buffer
key_mapper('n', '<A-p>', '<Cmd>BufferPin<CR>', NOREMAP_SILENT)
-- Close buffer
key_mapper('n', '<A-c>', '<Cmd>BufferClose<CR>', NOREMAP_SILENT)
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
key_mapper('n', '<C-p>', '<Cmd>BufferPick<CR>', NOREMAP_SILENT)
-- Sort automatically by...
key_mapper('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', NOREMAP_SILENT)
key_mapper('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', NOREMAP_SILENT)
key_mapper('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', NOREMAP_SILENT)
key_mapper('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', NOREMAP_SILENT)

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used

--]]
