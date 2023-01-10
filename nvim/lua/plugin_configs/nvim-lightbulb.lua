local ok, nvim_lightbulb = pcall(require, 'nvim-lightbulb')
if not ok then
  vim.notify("nvim-lightbulb not found")
  return
end

nvim_lightbulb.setup()
