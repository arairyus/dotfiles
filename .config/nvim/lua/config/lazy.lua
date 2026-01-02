-- 1. lazy.nvim本体を自動インストールする（すでにあるコードとほぼ同じ）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
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

-- 2. キー設定（重要：プラグインを入れる前に設定する必要がある）
vim.g.mapleader = " " -- スペースキーをリーダーキー（ショートカットの起点）にする
vim.g.maplocalleader = "\\"

-- 3. lazy.nvimの起動
require("lazy").setup({
  spec = {
    -- lua/plugins フォルダの中身をすべて自動的に読み込む
    { import = "plugins" },
  },
  -- インストール中に使うカラースキーム（デフォルトで入っているもの）
  install = { colorscheme = { "habamax" } },
  -- アップデートを自動チェックする
  checker = { enabled = true },
})
