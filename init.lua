-- {{{ Take control of my leader keys.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ------------------------------------------------------------------------- }}}
-- {{{ Quality of Life

vim.opt.clipboard = 'unnamedplus'
vim.opt.colorcolumn = '+1'
vim.opt.cursorline = false
vim.opt.expandtab = true
vim.opt.fillchars = { foldclose = ' ', fold = ' ', eob = ' ' }
vim.opt.foldlevel = 0
vim.opt.foldmethod = 'marker'
vim.opt.listchars = { eol = '↲', tab = '▸ ', trail = '·' }
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.showbreak = '↪'
vim.opt.signcolumn = 'yes'
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
vim.opt.virtualedit = { 'block' }
vim.opt.wrap = false

-- ------------------------------------------------------------------------- }}}
-- {{{ Keymaps: Source file, lines, and clear search.

vim.keymap.set('n', '<leader><leader>xf',
[[<cmd>source %<cr><cmd>echo 'Sourced ' . @%<cr>]]
)

vim.keymap.set('n', '<leader><leader>xl',
[[<cmd>.lua<cr><cmd>echo 'Current line executed.']]
)

vim.keymap.set('v', '<leader><leader>xs',
[[:lua<cr><cmd>echo 'Visual selection executed.']]
)

vim.keymap.set('n', '<leader>l', '<cmd>Lazy<CR>')

vim.keymap.set('n', '<leader><space>', '<cmd>nohlsearch<cr>')

-- ------------------------------------------------------------------------- }}}
-- {{{ Fold movements

-- Author: Karl Yngve Lervåg
--    See: https://github.com/lervag/dotnvim

-- Close all fold except the current one.
vim.keymap.set('n', 'zv', 'zMzvzz', {desc='Close all folds except current'})

-- Close current fold when open. Always open next fold.
vim.keymap.set('n', 'zj', 'zcjzOzz', {desc='Close fold & open next one'})

-- Close current fold when open. Always open previous fold.
vim.keymap.set('n', 'zk', 'zckzOzz', {desc='Close fold & open previous one'})

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
-- {{{ Resize splits after window resize.

vim.api.nvim_create_autocmd({ 'VimResized' }, {
  desc = 'Resize window when size changes.',
  group = vim.api.nvim_create_augroup('traap-resize-window', { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
  pattern = '*',
})

-- ------------------------------------------------------------------------- }}}
-- {{{ Remove trailing WhiteSpace

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Remove trailing white spaces when buffer is saved.',
  command = [[%s/\s\+$//e]],
  group = vim.api.nvim_create_augroup('traap--whitespace', { clear = true }),
})

-- ------------------------------------------------------------------------- }}}
-- {{{ file types and lsp servers

local dap_file_types = {'cpp', 'lua'}
local lsp_file_types = {'cpp', 'ruby', 'sql', 'lua'}
local lsp_servers = { 'clangd', 'solargraph', 'lua_ls', 'sqls' }

-- ------------------------------------------------------------------------- }}}
-- {{{ Bootstraap lazy.nvim when needed.

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local lazyrepo = 'https://github.com/folke/lazy.nvim.git'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end

end

vim.opt.rtp:prepend(lazypath)

-- ------------------------------------------------------------------------- }}}
-- {{{ lazy.nvim setup.

require('lazy').setup({
  spec = {
    -- Minimal folds.
    {
      'vim-utils/vim-most-minimal-folds',
      ft = lsp_file_types,
    },

    -- TMUX Navigator
    {
      'christoomey/vim-tmux-navigator',
      enabled = true,
      event =  'VeryLazy',

      keys = {
        {'<c-h>', '<cmd>TmuxNavigateLeft<cr>', desc = 'Navigate Window Left'},
        {'<c-j>', '<cmd>TmuxNavigateDown<cr>', desc = 'Navigate Window Down'},
        {'<c-k>', '<cmd>TmuxNavigateUp<cr>', desc = 'Navigate Window Up'},
        {'<c-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate Window Right'},
      },
    },

    -- Treesitter.
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      ft = lsp_file_types,
      opts = {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      },

      config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)

        for _, parser in ipairs(lsp_file_types) do
          vim.api.nvim_create_autocmd("FileType", {
            pattern = parser,
            callback = function()
              if not require("nvim-treesitter.parsers").has_parser(parser) then
                require("nvim-treesitter.install").ensure_installed(parser)
              end
            end,
          })
        end
      end
    },

    -- Fidget
    {
      'j-hui/fidget.nvim',
      ft = 'lua',
      hopts = {}
    },

    -- LSP
    {
      'neovim/nvim-lspconfig',
      ft = lsp_file_types,
      lazy = true,
      dependencies = {
        {
          'folke/lazydev.nvim',
          ft = 'lua',
          opts = {
            library = {
              { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
          },
        },
        {
          'williamboman/mason.nvim',
          config = true,
          opts = { ui = { border = 'rounded' }, },
        },
        {
          'williamboman/mason-lspconfig.nvim',
          config = true,
        },
      },
    },

    -- DAP
    {
      'mfussenegger/nvim-dap',
      ft = dap_file_types,
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
    colorscheme = { 'tokyonight', 'darkplus', 'default' }
  },

  performance = {
    cache = { enabled = true, },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },

  ui = {
    size = { width = 0.75, height = 0.75 },
    border = 'rounded',
    title = 'lazy.nvim',
  },
})

-- ------------------------------------------------------------------------- }}}
-- {{{ LSP capabilities

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- ------------------------------------------------------------------------- }}}
-- {{{ LSP on attach

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
-- {{{ LSP dynamic setup on File Type Detection

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('traap-lsp-file-types', { clear = true }),
  pattern = lsp_file_types,
  callback = function(event)
    local filetype_to_server = {
      cpp = 'clangd',
      ruby = 'solargraph',
      sql = 'sqls',
      lua = 'lua_ls',
    }

    local  server_name = filetype_to_server[event.match]
    if not server_name then return end

    -- Setup Mason and install required LSP servers
    require('mason').setup()
    require('mason-lspconfig').setup {
      ensure_installed = { server_name},
      automatic_installation = true,
    }

    require('mason-lspconfig').setup_handlers {
      [server_name] = function()
        require('lspconfig')[server_name].setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end,
    }
  end,
})

-- ------------------------------------------------------------------------- }}}
-- {{{ DAP Utility Functions

local function create_dap_adapter(language)
  if language == 'cpp' then
    return {
      adapter = {
        type = 'executable',
        command = 'lldb-vscode', -- Ensure LLDB is installed
        name = 'lldb',
      },
      configuration = {
        {
          name = 'Launch file',
          type = 'cpp',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      },
    }
  elseif language == 'lua' then
    return {
      adapter = function(callback, _)
        callback({ type = 'server', host = '127.0.0.1', port = 8086 })
      end,
      configuration = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
          host = '127.0.0.1',
          port = 8086,
        },
      },
    }
  end
end

-- ------------------------------------------------------------------------- }}}
-- {{{ DAP dynamic setup on File Type Detection

vim.api.nvim_create_autocmd('FileType', {
  desc = 'DAP dynamic set up on file type detection.',
  group = vim.api.nvim_create_augroup('traap-dap-file-types', { clear = true }),
  pattern = dap_file_types,
  callback = function(event)
    local ft = event.match

    -- DAP Setup
    if ft == 'cpp' or ft == 'lua' then
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
