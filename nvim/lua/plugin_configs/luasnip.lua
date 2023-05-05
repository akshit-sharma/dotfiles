local ok, luasnip = pcall(require, "luasnip")
if not ok then
  vim.notify("Failed to load luasnip" .. luasnip, vim.log.levels.ERROR)
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
                    },
      },
    },
  },
})

vim.keymap.set({"n", "i", "s"}, "<A-k>", function()
  vim.notify("inside expand_or_jumpable")
  if ls.expand_or_jumpable() then
    vim.notify("expand_or_jumpable")
    return ls.expand_or_jump()
  end
end, { noremap = true, silent = true })

vim.keymap.set({"i", "s"}, "<A-j>", function()
  if ls.jumpable(-1) then
   return ls.jump(-1)
  end
end, { noremap = true, silent = true })

vim.keymap.set({"i"}, "<A-l>", function()
  if ls.choice_active() then
    return ls.change_choice(1)
  end
end, { noremap = true, silent = true })

vim.keymap.set({"i"}, "<A-h>", function()
  if ls.choice_active() then
    return ls.change_choice(-1)
  end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/snippets/luasnip.lua<CR>")

local ok, lua_loader = pcall(require, "luasnip.loaders.from_lua")
if not ok then
  vim.notify("Failed to load luasnip loader" .. lua_loader, vim.log.levels.ERROR)
  return
end

lua_loader.load({paths = '~/.config/nvim/snippets/'})

