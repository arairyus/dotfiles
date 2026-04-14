return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          -- blink.cmpのTabと競合しないようにCtrl+Yで受け入れ
          accept = "<C-y>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = {
        enabled = false,
      },
    },
  },
  -- blink-copilotのsource補完は無効化（インライン表示を優先）
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      -- blink経由のcopilot sourceを除外
      if opts.sources and opts.sources.default then
        opts.sources.default = vim.tbl_filter(function(s)
          return s ~= "copilot"
        end, opts.sources.default)
      end
    end,
  },
}
