local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
if not ok_lspconfig then
  vim.notify('"neovim/nvim-lspconfig" not available', 'error')
  return
end

local ok_mason, mason = pcall(require, "mason")
if not ok_mason then
  vim.notify('"williamboman/mason.nvim" not available', 'error')
  return
end

local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
if not ok_mason_lspconfig then
  vim.notify('"williamboman/mason-lspconfig" not available', 'error')
  return
end

local ok_coq, coq = pcall(require, "coq")
if not ok_coq then
  vim.notify('"ms-jpq/coq_nvim" not available', 'error')
  return
end

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  },
  pip = {
    upgrade_pip = true,
  }
})

mason_lspconfig.setup({
  ensure_installed = { "clangd" },
  automatic_installation = true
})

local diagnostics = require("lsp_configs.diagnostics")
diagnostics.setup()

require("lsp_configs.servers.clangd").setup()
-- require("lsp_configs.servers.sumneko_lua").setup()


local setup_lsps = function()
  local lsp_handlers = require("lsp_configs.lsp_handlers")
  lsp_handlers.setup()

  local opts = {
    on_attach = function(client, bufnr)
      lsp_handlers.set_mappings(client, bufnr)
      lsp_handlers.set_autocmds(client, bufnr)
      lsp_handlers.set_additional_plugins(client, bufnr)
      diagnostics.set_mappings(client, bufnr)
    end,
    capabilities = lsp_handlers.capabilities,
  }

  for _, server in ipairs({
    "cmake",
    "dotls",
    "jsonls",
    "pyright",
    "rust_analyzer",
    "sumneko_lua",
    "tsserver",
    "vimls",
  }) do
    lspconfig[server].setup(opts)
  end
end

setup_lsps()
