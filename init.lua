-- {{{ Leader Keys and Core Settings

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.foldlevel = 0
vim.o.foldmethod = "marker"

-- ------------------------------------------------------------------------- }}}
-- {{{ Bootstrap lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system(
    { "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lazy.nvim.git",
      lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- ------------------------------------------------------------------------- }}}
-- {{{ Load lazy.nvim and Setup Plugins

require("lazy").setup({
  spec = {
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      event = { "BufReadPost", "BufNewFile" },
      opts = { highlight = { enable = true } },
    },
    {
      'williamboman/mason.nvim',
      build = ':MasonUpdate',
      config = true,
    },
    {
      'williamboman/mason-lspconfig.nvim',
      dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
      config = true,
    },
    {
      'neovim/nvim-lspconfig',
      event = { "BufReadPost", "BufNewFile" },
    },
    {
      'mfussenegger/nvim-dap',
      event = { "BufReadPost", "BufNewFile" },
    },
  },

  build = { warn_on_override = true, },

  checker = { enabled = false },

  change_detection = {
    enable = false,
    notify = false,
  },

  defaults = {
    lazy = true,
    version = false,
    autocmds = true,
    keymaps = false,
  },

  install = {
    missing = true,
    colorscheme = { "tokyonight", "darkplus", "default" }
  },

  performance = {
    cache = { enabled = true, },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "bugreport",
        "compiler",
        "ftplugin",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "matchit",
        "netrw",
        "netrwFileHandlers",
        "netrwPlugin",
        "netrwSettings",
        "optwin",
        "rplugin",
        "rrhelper",
        "spellfile_plugin",
        "synmenu",
        "syntax",
        "tar",
        "tarPlugin",
        "tohtml",
        "tutor",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
      },
    },
  },

  ui = {
    size = { width = 0.75, height = 0.75 },
    border = "rounded",
    title = "lazy.nvim",
  },
})

-- ------------------------------------------------------------------------- }}}
-- {{{ Mason and Mason-lspConfig Setup

require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = { "clangd", "solargraph", "lua_ls", "sqls" },
  automatic_installation = true,
}

-- ------------------------------------------------------------------------- }}}
-- {{{ Default LSP on attach

local lspconfig = require('lspconfig')

local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  -- Keybindings for LSP features
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
end

-- ------------------------------------------------------------------------- }}}
-- {{{ Setup LSP servers

local capabilities = vim.lsp.protocol.make_client_capabilities()
require('mason-lspconfig').setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end,

  ["lua_ls"] = function()
    lspconfig.lua_ls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { 'vim' } },
          workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        },
      },
    }
  end,

  ["sqls"] = function()
    lspconfig.sqls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        sqls = {
          connections = {
            {
              driver = "mysql",
              dataSourceName = "root:password@tcp(127.0.0.1:3306)/dbname",
            },
          },
        },
      },
    }
  end,
}

-- ------------------------------------------------------------------------- }}}
-- {{{ Utility Functions

local function create_dap_adapter(language)
  if language == "cpp" then
    return {
      adapter = {
        type = 'executable',
        command = 'lldb-vscode', -- Ensure LLDB is installed
        name = 'lldb',
      },
      configuration = {
        {
          name = "Launch file",
          type = "cpp",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      },
    }
  elseif language == "lua" then
    return {
      adapter = function(callback, _)
        callback({ type = 'server', host = "127.0.0.1", port = 8086 })
      end,
      configuration = {
        {
          type = 'nlua',
          request = 'attach',
          name = "Attach to running Neovim instance",
          host = "127.0.0.1",
          port = 8086,
        },
      },
    }
  end
end

-- ------------------------------------------------------------------------- }}}
-- {{{ Dynamic Setup on File Type Detection

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "ruby", "lua", "sql" },
  callback = function(event)
    local ft = event.match

    -- DAP Setup
    if ft == "cpp" or ft == "lua" then
      local dap = require('dap')
      local dap_data = create_dap_adapter(ft)
      if dap_data then
        dap.adapters[ft] = dap_data.adapter
        dap.configurations[ft] = dap_data.configuration
      end
    end
  end,
})

-- ------------------------------------------------------------------------- }}}
