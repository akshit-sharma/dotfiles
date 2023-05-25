local ok, refactoring = pcall(require, 'refactoring')
if not ok then
  vim.notify('"refactoring" not found', vim.log.levels.ERROR)
  return
end

refactoring.setup({})
