local ok, symbols_outline = pcall(require, "symbols-outline.config")
if not ok then
  vim.notify('"symbols-outline" not installed', 'error')
  return
end

symbols_outline.setup()
