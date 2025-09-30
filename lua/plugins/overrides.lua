if not pcall(require, "lazyvim") then
  return {}
else
  -- Yep.  I disable plugins I don't want from LazyVim
  return {
    { "RRethy/vim-illuminate", enabled = false },
    { "akinsho/bufferline.nvim", enabled = false },
    { "nvim-treesitter/nvim-treesitter-context", enabled = false },
    { "rcarriga/nvim-notify", enabled = false },
    {
      "folke/snacks.nvim",
      enabled = true,
      opts = {
        indent = { enabled = false },
        scroll = { enabled = false },
        picker = { sources = { explorer = { layout = { layout = { position = "right" } } } } },
      },
    },
    { "folke/which-key.nvim", enabled = true, opts = { plugins = { spelling = true }, preset = "modern" } },
  }
end
