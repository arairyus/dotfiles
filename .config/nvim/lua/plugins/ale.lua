-- ALE (Asynchronous Lint Engine) configuration
-- Based on VSCode settings.json

return {
  "dense-analysis/ale",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "ALEEnable", "ALEInfo", "ALEFix", "ALELint" },
  config = function()
    -- Linters configuration (based on VSCode extensions)
    vim.g.ale_linters = {
      go = { "golint", "govet" },
      python = { "flake8", "pylint" },
      javascript = { "eslint" },
      typescript = { "eslint" },
      typescriptreact = { "eslint" },
      javascriptreact = { "eslint" },
      terraform = { "terraform", "tflint" },
      yaml = { "yamllint" },
      cs = { "OmniSharp" },
    }

    -- Fixers configuration (based on VSCode formatOnSave settings)
    vim.g.ale_fixers = {
      ["*"] = { "remove_trailing_lines", "trim_whitespace" },
      go = { "gofmt", "goimports" },
      python = { "autopep8" },
      javascript = { "eslint", "prettier" },
      typescript = { "eslint", "prettier" },
      typescriptreact = { "eslint", "prettier" },
      javascriptreact = { "eslint", "prettier" },
      terraform = { "terraform" },
      yaml = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      html = {}, -- formatOnSave: false in VSCode
      cs = { "dotnet-format" },
    }

    -- Fix on save (matching VSCode's editor.formatOnSave: true)
    vim.g.ale_fix_on_save = 1

    -- Lint on save and insert leave
    vim.g.ale_lint_on_save = 1
    vim.g.ale_lint_on_insert_leave = 1

    -- Sign column symbols
    vim.g.ale_sign_error = "✘"
    vim.g.ale_sign_warning = "⚠"

    -- Virtual text for errors
    vim.g.ale_virtualtext_cursor = 1

    -- Go settings (tabSize: 4, insertSpaces: false from VSCode)
    vim.g.ale_go_gofmt_options = "-s"
  end,
}
