local ok, feline = pcall(require, 'feline')
if not ok then
  vim.notify('"feline.config" not found', vim.log.levels.ERROR)
  return
end

feline.winbar.setup {

}
