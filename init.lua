-- {{{ Take control of my leader keys.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ------------------------------------------------------------------------- }}}
-- {{{ Quality of Life

vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "+1"
vim.opt.cursorline = false
vim.opt.expandtab = true
vim.opt.fillchars = { foldclose = " ", fold = " ", eob = " " }
vim.opt.foldlevel = 0
vim.opt.foldmethod = "marker"
vim.opt.listchars = { eol = "↲", tab = "▸ ", trail = "·" }
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.showbreak = "↪"
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 2
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.textwidth = 80
vim.opt.timeout = true
vim.opt.timeoutlen = 270
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 5
vim.opt.updatetime = 500
vim.opt.virtualedit = { "block" }
vim.opt.wrap = false

-- ------------------------------------------------------------------------- }}}
-- {{{ Bootstraap lazy.nvim when needed.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyrepo = "https://github.com/folke/lazy.nvim.git"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end

end

vim.opt.rtp:prepend(lazypath)

-- ------------------------------------------------------------------------- }}}
-- {{{ Setup lazy.nvim

--     https://lazy.folke.io/spec

local file_types = {"c", "cpp", "rb", "sql", "lua"}

require("lazy").setup({
  spec = {
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      ft = file_types,
      opts = { highlight = { enable = true } },
    },
    {
      'williamboman/mason.nvim',
      build = ':MasonUpdate',
      ft = file_types,
      config = true,
    },
    {
      'williamboman/mason-lspconfig.nvim',
      dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
      ft = file_types,
      config = true,
    },
    {
      'neovim/nvim-lspconfig',
      ft = file_types,
    },
    {
      'mfussenegger/nvim-dap',
      ft = file_types,
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
				"gzip",
        "matchit",
        "matchparen",
				"tarPlugin",
				"tohtml",
				"tutor",
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
-- {{{ Source file or lines

vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>")
vim.keymap.set("v", "<leader>x", "<cmd>lua<CR>")
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<CR>")

-- ------------------------------------------------------------------------- }}}
-- {{{ Fold movements

-- Author: Karl Yngve Lervåg
--    See: https://github.com/lervag/dotnvim

-- Close all fold except the current one.
vim.keymap.set("n", "zv", "zMzvzz", {desc='Close all folds except current'})

-- Close current fold when open. Always open next fold.
vim.keymap.set("n", "zj", "zcjzOzz", {desc='Close fold & open next one'})

-- Close current fold when open. Always open previous fold.
vim.keymap.set("n", "zk", "zckzOzz", {desc='Close fold & open previous one'})

-- ------------------------------------------------------------------------- }}}
-- {{{ Highlight when yanking (copying) text

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('traap-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
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
