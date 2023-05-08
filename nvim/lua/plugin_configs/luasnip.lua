local ok, ls = pcall(require, "luasnip")
if not ok then
  vim.notify("Failed to load luasnip" .. ls, vim.log.levels.ERROR)
  return
end

local ok_types, types = pcall(require, "luasnip.util.types")
if not ok_types then
  vim.notify("Failed to load luasnip types" .. types, vim.log.levels.ERROR)
  return
end

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
  if ls.expand_or_jumpable() then
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

local ok_loader, lua_loader = pcall(require, "luasnip.loaders.from_lua")
if not ok_loader then
  vim.notify("Failed to load luasnip loader" .. lua_loader, vim.log.levels.ERROR)
  return
end

ls.filetype_extend("js", {"ejs"})
lua_loader.load({paths = '~/.config/nvim/snippets/'})

