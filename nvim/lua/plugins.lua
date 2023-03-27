local fresh_install = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local getConfig = function(name)
  return string.format('require(\'plugin_configs/%s\')', name)
end

local isModified = function(git_file, local_file)

  local lastModified = function(file)
    local file_stream = io.popen("stat -c %Y " .. file)
    if file_stream == nil then
      return 0
    end
    local last_modified = file_stream:read("*a")
    file_stream:close()
    return last_modified
  end

  local git_file_date = lastModified(git_file)
  local local_file_date = lastModified(local_file)
  if git_file_date > local_file_date then
    return true
  end
  return false
end

local python3_latest = function()
  return 'python3'
end

local venv_install = function()
  local fn = vim.fn
  local venv_path = fn.expand('$HOME') .. '/venv'
  local virtualenv = 'virtualenv'

  local virtualenv_stream = io.popen(virtualenv .. " --version")
  if virtualenv_stream == nil then
    print("Installing virtualenv")
    local install_stream = io.popen("pip3 install --user virtualenv")
    install_stream:close()
  else
    virtualenv_stream:close()
  end

  if fn.empty(fn.glob(venv_path)) > 0 then
    print("Installing venv")
    local install_stream = io.popen(virtualenv .. " " .. venv_path)
    install_stream:close()
  end

  if fn.executable(venv_path..'bin/python') == 0 then
    fn.system(virtualenv..' -p '..python3_latest()..venv_path)
    fn.system(
      venv_path..'bin/python -m pip install --upgrade pynvim'
    )
  end
end

local pluginUpdate = function()
  local fn = vim.fn
  local plugin_date = fn.stdpath('data')..'/plugins.date'

  local update_required = function(this_week)
    local file = io.open(plugin_date, "r")
    if file == nil then return true end

    local file_week = file:read("*all")
    file:close()

    if this_week > file_week then return true end

    return false
  end

  local write_date = function(file_name, this_week)
    local file = io.open(file_name, "w")
    if file == nil then print("Error writing to "..file_name) return end
    file:write(this_week)
    file:close()
  end

  local this_week = os.date("%Y-%V")

  local current_path = string.sub(debug.getinfo(1).source, 2)

  if update_required(this_week) or isModified(current_path, plugin_date) then
    -- venv_install()
    write_date(plugin_date, this_week)
    return true
  end

  return false
end

fresh_install()

-- fresh_install or needs update
local packer_bootstrap = pluginUpdate()

--require('plugin_configs.themer')
--require('plugin_configs.nvim-notify')

require('plugin_configs.nvim-notify')

local packer = require('packer')
packer.startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'nvim-lua/plenary.nvim'

    use 'ryanoasis/vim-devicons'

    use { 'hrsh7th/cmp-nvim-lsp' }

    use { 'rcarriga/nvim-notify' }
    use { 'vigoux/notifier.nvim' }

    use {
      'weilbith/nvim-code-action-menu',
      cmd = 'CodeActionMenu'
    }

    use {
      'j-hui/fidget.nvim',
      'kosayoda/nvim-lightbulb'
    }

    use {
      'p00f/clangd_extensions.nvim'
    }

    use {
      'ms-jpq/coq_nvim'
    }

--    use 'rstacruz/vim-closer'

    -- Diagnostics
    use 'folke/trouble.nvim'
    use 'folke/todo-comments.nvim'

    use {
      'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }

  use 'ray-x/lsp_signature.nvim'

  use { 'github/copilot.vim', branch = 'release' }

  --use { "briones-gabriel/darcula-solid.nvim", requires = "rktjmp/lush.nvim" }
  use{
    'themercorp/themer.lua',
  }

  use { 'stevearc/aerial.nvim' }
  use { 'simrat39/symbols-outline.nvim' }

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use({
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
  })
  use("nvim-telescope/telescope-file-browser.nvim")
  use("benfowler/telescope-luasnip.nvim")
  use("nvim-telescope/telescope-symbols.nvim")
  use("nvim-telescope/telescope-packer.nvim")

  -- Packer
  use({
    "jackMort/ChatGPT.nvim",
      requires = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim"
      },
      config = function()
        require("chatgpt").setup({
          question_sign = "🤔",
          answer_sign = "🤖",
          chat_input = {
            prompt = "👉",
          },
          keymaps = {
            close = { "<C-c>", "<Esc>" },
            submit = "<C-w>",
            yank_last = "<C-y>",
            scroll_up = "<C-u>",
            scroll_down = "<C-d>",
            toggle_settings = "<C-o>",
            cycle_windows = "<Tab>",

            new_session = "<C-n>",
            select_session = "<Space>",
            rename_session = "<C-r>",
            delete_session = "<C-d>",
          },
        })
      end,
  })

  use { 'lervag/vimtex', config = getConfig('vimtex') }

  use { 'ojroques/nvim-hardline' }

--  use { 'romgrk/barbar.nvim', config = getConfig('barbar'), requires = 'nvim-tree/nvim-web-devicons' }

  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    }
  }

  use {
    'zbirenbaum/copilot.lua',
    event = 'VimEnter',
    config = function()
      vim.defer_fn(function()
        require('copilot').setup()
      end, 100)
    end,
  }

  use {
    'zbirenbaum/copilot-cmp',
    after = {'copilot.lua'},
    config = function ()
      require('copilot_cmp').setup()
    end,
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)


