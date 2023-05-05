local ok, ls = pcall(require, "luasnip")

if not ok then
  vim.notify("Failed to load luasnip" .. ls, vim.log.levels.ERROR)
  return
end

ls.snippets = {
  all = {
  },
  tex = {

  }
}
