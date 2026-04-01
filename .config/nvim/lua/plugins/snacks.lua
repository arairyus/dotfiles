return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      hidden = true,   -- Show hidden files by default
      ignored = true,  -- Show gitignored files by default
    },
    picker = {
      sources = {
        explorer = {
          hidden = true,
        },
      },
    },
  },
}
