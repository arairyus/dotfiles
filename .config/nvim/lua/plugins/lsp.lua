return {
  -- LSP設定
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ansiblels = {},
        terraformls = {},
      },
    },
  },

  -- フォーマッター設定
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
      },
    },
  },

  -- リンター設定
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ansible = { "ansible_lint" },
        terraform = { "tflint" },
        tf = { "tflint" },
        -- yaml.github-actionsはGitHub Actionsファイル専用のfiletype
        ["yaml.github-actions"] = { "actionlint" },
      },
    },
  },
}
