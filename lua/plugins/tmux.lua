return {
  {
    "alexghergh/nvim-tmux-navigation",
    enabled = true,
    event = "VeryLazy",

    opts = function(_, opts)
      opts.disable_when_zoomed = true
      opts.keybindings = {
        left = '<c-h>',
        down = '<c-j>',
        up = '<c-k>',
        right = '<c-l>',
        last_active = '<c-\\>',
        next='<c-]>',
      }
    end,

    config = function(_, opts)
      require("nvim-tmux-navigation").setup(opts)
    end,
  },

  {
    "Traap/vim-tmux-runner",
    enabled = true and os.getenv("TMUX") ~= nil,
    event = "VeryLazy",

    config = function()
      _G.VtrOrientation = "h"
      _G.VtrPercentage = 50
      _G.VtrClearSequence = ""
      _G.VtrClearBeforeSend = 1
    end,

    -- NOTE: These keybindings are not the defaults vim-tmux-runner defines.
    -- They are set here to minimize and or override LazyVim defaults.
    keys = {
      {"<leader>tC", "<cmd>VtrClearRunner<cr>", "Clear Tmux Runner"},
      {"<leader>tF", "<cmd>VtrFocusRunner<cr>", "Focus Tmux Runner"},
      {"<leader>tR", "<cmd>VtrReorientRunner<cr>", "Reorient Tmux Runner"},
      {"<leader>ta", "<cmd>VtrReattachRunner<cr>", "Reattach Tmux Runner"},
      {"<leader>tc", "<cmd>VtrFlushCommand<cr>", "Flush Tmux Runner Command"},
      {"<leader>tf", "<cmd>VtrSendFile<cr>", "Send File to Tmux Runner"},
      {"<leader>tk", "<cmd>VtrKillRunner<cr>", "Kill Tmux Runner"},
      {"<leader>tl", "<cmd>VtrSendLinesToRunner<cr>", "Send Lines to Tmux Runner"},
      {"<leader>to", "<cmd>VtrOpenRunner {'orientation': 'h', 'percentage': 50}<cr>", "Open Tmux Runner"},
      {"<leader>tr", "<cmd>VtrResizeRunner<cr>", "Resize Tmux Runner"},
      {"<leader>ts", "<cmd>VtrSendCommandToRunner<cr>", "Send Command to Tmux Runner"},
    }
  },
}
