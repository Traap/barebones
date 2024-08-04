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
		{ "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      -- tag="v11.11.00"
    },
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
