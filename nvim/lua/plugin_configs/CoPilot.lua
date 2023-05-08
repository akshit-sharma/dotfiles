--[[
local ok, copilot = pcall(require, 'copilot')
if not ok then
  vim.notify('error loading copilot: ' .. copilot, vim.log.levels.ERROR)
  return
end

copilot.setup({
  suggestion = {
    keymap = {
      accept="<C-E>",
      accept_word="<M-W>",
      accept_line="<M-L>",
      dismiss="<C-]>",
      next="<M-]>",
      prev="<M-[>",
    }
  },
  filetype={
    ["*"] = true
  }
})
]]--
