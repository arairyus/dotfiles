-- Disable all LazyVim default plugins
-- Uncomment the ones you want to enable

return {
  -- Core/UI
  { "folke/noice.nvim", enabled = false },
  { "folke/snacks.nvim", enabled = false },
  { "folke/which-key.nvim", enabled = false },
  { "folke/flash.nvim", enabled = false },
  { "folke/trouble.nvim", enabled = false },
  { "folke/todo-comments.nvim", enabled = false },
  { "folke/persistence.nvim", enabled = false },
  { "folke/lazydev.nvim", enabled = false },
  { "folke/ts-comments.nvim", enabled = false },

  -- UI Components
  { "akinsho/bufferline.nvim", enabled = false },
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "MunifTanjim/nui.nvim", enabled = false },

  -- Colorschemes
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },

  -- Completion
  { "saghen/blink.cmp", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false },

  -- LSP
  { "neovim/nvim-lspconfig", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },

  -- Linting/Formatting
  { "mfussenegger/nvim-lint", enabled = false },
  { "stevearc/conform.nvim", enabled = false },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", enabled = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
  { "windwp/nvim-ts-autotag", enabled = false },

  -- Git
  { "lewis6991/gitsigns.nvim", enabled = false },

  -- Search/Replace
  { "MagicDuck/grug-far.nvim", enabled = false },

  -- Mini plugins
  { "echasnovski/mini.ai", enabled = false },
  { "echasnovski/mini.icons", enabled = false },
  { "echasnovski/mini.pairs", enabled = false },

  -- Utilities
  { "nvim-lua/plenary.nvim", enabled = false },
}
