local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Bootstrap lazy.nvim
if not vim.loop.fs_stat(lazypath) then
  -- stylua: ignore
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
	-- Setup lazy
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
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
