local ok, luasnip = pcall(require, "luasnip")
if not ok then
  vim.notify("Failed to load luasnip" .. luasnip, vim.log.levels.ERROR)
  return
end

local ok, vs_code_loader = pcall(require, "luasnip.loaders.from_vscode")
if not ok then
  vim.notify("Failed to load luasnip loader" .. vs_code_loader, vim.log.levels.ERROR)
  return
end

local ok, ls = pcall(require, "luasnip")
local ok, types = pcall(require, "luasnip.util.types")

ls.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true,
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = {
          { "choiceNode", "Comment" },
          { "<-", "Error" },
                    },
      },
    },
  },
})

vim.keymap.set({"i", "s"}, "<C-k>", function()
  if ls.expand_or_jumpable() then
    return ls.expand_or_jump()
  end
end, { noremap = true, silent = true })

vim.keymap.set({"i", "s"}, "<C-z>", function()
  if ls.jumpable(-1) then
   return ls.jump(-1)
  end
end, { noremap = true, silent = true })

vim.keymap.set({"i"}, "<C-l>", function()
  if ls.choice_active() then
    return ls.change_choice(1)
  end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/snippets/luasnip.lua<CR>")

vs_code_loader.lazy_load()
