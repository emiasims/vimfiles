stimpack.add({ 'https://github.com/stevearc/conform.nvim' })

require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua', lsp_format = 'never' },
    python = { lsp_format = 'prefer' },
    markdown = { 'prettier', 'inject' },
  },
})

mia.fmtexpr = mia.restore_opt(
  { eventignore = 'all' },
  function()
    require('conform').formatexpr()
    vim.schedule_wrap(vim.cmd.doautocmd)('TextChanged')
  end
)

vim.o.formatexpr = 'v:lua.mia.fmtexpr()'
