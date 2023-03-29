local ok, navbuddy = pcall(require, 'nvim-navbuddy')
if not ok then
  vim.notify('nvim-navbuddy not found', vim.log.levels.ERROR)
  return
end

local _, actions = pcall(require, 'nvim-navbuddy.actions')
if not ok then
  vim.notify('nvim-navbuddy.actions not found', vim.log.levels.ERROR)
  return
end

navbuddy.setup()
