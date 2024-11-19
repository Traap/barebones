return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      preset = {
        header = [[ Configured by Traap! Powered by lazy.nvim and LazyVim! ]],
        keys = function(keys)
          for k, key in ipairs(keys) do
            if key.action == ":Lazy" then
              key.key = "l"
              table.insert(keys, k,
                { icon = " ", desc = "Lazy Extras", action = ":LazyExtras", key = "x" }
              )
              break
            end
          end
        end,
      },
    },
  },
}
