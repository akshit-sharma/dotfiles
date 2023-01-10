local ok, themer = pcall(require, "themer")
if not ok then
  vim.notify('"themer.configs" not available', 'error')
  return
end

themer.setup({
  colorscheme = "monokai_pro",
  -- colorscheme = "dracula",
  styles = {
    functionbuiltin = { style = 'italic' },
    variableBuiltIn = { style = 'italic' },
  }
})
