return {
  "iamcco/markdown-preview.nvim",
  init = function()
    vim.g.mkdp_browserfunc = "CmuxOpen"
    vim.cmd([[
      function! CmuxOpen(url) abort
        call jobstart(['/Applications/cmux.app/Contents/Resources/bin/cmux', 'browser', 'open', a:url])
      endfunction
    ]])
  end,
}
