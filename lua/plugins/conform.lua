---@type LazySpec
return {
  'stevearc/conform.nvim',
  dependencies = { 'mason.nvim' },
  keys = { 'gq' },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua', lsp_format = 'never' },
      python = { 'isort', 'black' },
      markdown = { 'prettier', 'inject' },
    },
  },
  ---@param c {opts: conform.setupOpts}
  config = function(c)
    require('conform').setup(c.opts)
    mia.fmtexpr = mia.restore_opt( --
      { eventignore = 'all' },
      function()
        require('conform').formatexpr()
        vim.schedule_wrap(vim.cmd.doautocmd)('TextChanged')
      end
    )

    vim.o.formatexpr = 'v:lua.mia.fmtexpr()'
  end,
}
