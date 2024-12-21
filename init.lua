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

require("lazy").setup({
	-- Setup lazy
	spec = {
		-- { "LazyVim/LazyVim",
		--     import = "lazyvim.plugins",
		--     -- tag="v11.11.00"
		--   },
    { import = "plugins"}
	},

	defaults = {
    lazy = true,
    version = false,
    autocmds = true,
    keymaps = false
  },

	checker = { enabled = true, },

  change_detection = {
    enable = false,
    notify = false,
  },

	install = {
    missing = true,
    colorscheme = { "tokyonight", "habamax" }
  },

  ui = {
    size = { width = 0.75, height = 0.75 },
    border = "rounded",
    title = "lazy.nvim",
  },

	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
        "matchit",
        "matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},

})

-- ------------------------------------------------------------------------- }}}
-- {{{ Source file or lines 

vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>")
vim.keymap.set("v", "<leader>x", "<cmd>lua<CR>")
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<CR>")

-- ------------------------------------------------------------------------- }}}
-- {{{ Fole movements

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
-- {{{ Colorschmes 

vim.cmd.colorscheme("tokyonight-night")

-- ------------------------------------------------------------------------- }}}
-- {{{ Automagically close command-line window.

vim.api.nvim_create_autocmd("CmdWinEnter", {
  desc = "Automagically close command-line window",
  group = vim.api.nvim_create_augroup("traap_cwe", { clear = true }),
  callback = function()
    vim.cmd "quit"
  end,
})

-- -------------------------------------------------------------------------- }}}
-- {{{ Color tweeks when entering a buffer or when colorscheme change.
--
--     https://image-color-picker.com/rgb-color-picker

vim.api.nvim_create_autocmd({"BufWinEnter", "ColorScheme" }, {
  desc = "Customize colors to blend with Tokonight-Night",
  group = vim.api.nvim_create_augroup("traap_colors", { clear = true }),
  pattern = {"*"},
  callback = function()

    -- NOTE: RGB values found in Tokyonight-night colors.
    -- Better Quick Fix
    vim.api.nvim_set_hl(0, "BqfPreviewBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "BqfPrevieTitle", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "BqfPrevieThumb", { fg="#3b4261"})
    vim.cmd([[ hi link BqfPreviewRange Search ]])

    -- Cmp
    vim.api.nvim_set_hl(0, "CmpDocumentationBorder", { fg="#3b4261"})

    -- Harpoon
    vim.api.nvim_set_hl(0, "HarpoonBorder", { fg="#3b4261"})

    -- LspSaga
    vim.api.nvim_set_hl(0, "LspSagaSignatureHelpBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "LspSagaCodeActionBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "LspSagaDefPreviewBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "LspSagaRenameBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "LspSagaHoverBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "LspSagaBorderTitle", { fg="#3b4261"})

    -- NeoTest
    vim.api.nvim_set_hl(0, "NeoTestBorder", { fg="#3b4261"})

    -- Folds
    vim.api.nvim_set_hl(0, "Folded", {fg="#6a79b3"})

    -- Line numbers
    vim.api.nvim_set_hl(0, "LineNr",      {fg="#e0af68"})
    vim.api.nvim_set_hl(0, "ColorColumn", {bg="#3b4261"})
    vim.api.nvim_set_hl(0, "LineNrAbove", {fg="#3b4261"})
    vim.api.nvim_set_hl(0, "LineNrBelow", {fg="#3b4261"})

    -- Telescope
    vim.api.nvim_set_hl(0, "TelescopeBorder",        { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "TelescopePromptBorder",  { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg="#3b4261"})

    -- Lsp
    vim.api.nvim_set_hl(0, "LspInfoBorder",     { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "LspFloatWinBorder", { fg="#3b4261"})

    -- Neovim
    vim.api.nvim_set_hl(0, "FloatBorder", { fg="#3b4261"})

    -- Noice
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup",                 { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder",           { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCalculator", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCmdline",    { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderFilter",     { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderHelp",       { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderLua",        { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderInput",      { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderIncRename",  { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceConfirmBorder",                { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoicePopupBorder",                  { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoicePopupmenuBorder",              { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NoiceSplitBorder",                  { fg="#3b4261"})

    -- Notify
    vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg="#ff0000"})
    vim.api.nvim_set_hl(0, "NotifyINFOBorder",  { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg="#3b4261"})
    vim.api.nvim_set_hl(0, "NotifyWARNBorder",  { fg="#e0af68"})

    -- Pmenu
    vim.api.nvim_set_hl(0, "Pmenu", { blend=100 } )
    vim.api.nvim_set_hl(0, "PmenuSel",      { fg="#e0af68", bg="#3b4261" } )
    vim.api.nvim_set_hl(0, "PmenuKindSel",  { fg="#e0af68", bg="#3b4261" } )
    vim.api.nvim_set_hl(0, "PmenuEstraSel", { fg="#e0af68", bg="#3b4261" } )

    -- WhichKey
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg="#3b4261"})
  end,
})

-- ------------------------------------------------------------------------- }}}
