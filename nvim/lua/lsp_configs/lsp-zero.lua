local ok, lsp = pcall(require, 'lsp-zero')
if not ok then
  vim.notify('lsp-zero not found', vim.log.levels.ERROR)
  return
end

lsp.preset('recommended')

lsp.ensure_installed({
  'clangd',
  'cmake',
  'pyright',
  'vimls',
  'rust_analyzer'
})

local ok_cmp, cmp = pcall(require, 'cmp')
if not ok_cmp then
  vim.notify('cmp not found', vim.log.levels.ERROR)
  return
end

local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mapping = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.close(),
  ['<M-k>'] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Replace,
    select = true
  }),
  ['<C-k>'] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Insert,
    select = true
  }),
})

-- disable completion with table
cmp_mapping['<CR>'] = nil
cmp_mapping['<C-j>'] = nil
cmp_mapping['<Tab>'] = nil
cmp_mapping['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  sources = {
    {name = 'copilot', max_item_count = 10},

    {name = 'nvim_lsp', keyword_length = 3, max_item_count = 10},
    {name = 'path', keyword_length = 2, max_item_count = 5},
    {name = 'buffer', keyword_length = 2, max_item_count = 5},
    {name = 'luasnip', keyword_length = 2, max_item_count = 5},
  },
  mapping = cmp_mapping,
})

lsp.set_preferences({
  sign_icons ={
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})

local navbuddy = require('nvim-navbuddy')
local navic = require('nvim-navic')

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  if client.name == "eslint" then
      vim.cmd.LspStop('eslint')
      return
  end

  navbuddy.attach(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  -- print offset_encoding
--  print(client.offset_encoding)

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<C-h>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format { async = true } end, opts)
  vim.keymap.set("v", "<leader>fm", function() vim.lsp.buf.format { async = true } end, opts)
end)

lsp.setup()

vim.diagnostic.config({
  virtual_text = true
})
