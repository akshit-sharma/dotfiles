local ok, navic = pcall(require, "nvim-navic")
if not ok then
  vim.notify("navic not found", vim.log.levels.ERROR)
  return
end

navic.setup({
})
