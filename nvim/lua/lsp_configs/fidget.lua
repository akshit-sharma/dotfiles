-- https://github.com/j-hui/fidget.nvim
local ok, fidget = pcall(require, "fidget")
if not ok then
  vim.notify('fidget not found','error')
  return
end
fidget.setup()
