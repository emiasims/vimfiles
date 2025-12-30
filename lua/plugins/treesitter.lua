---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy',
  branch = 'main',
  build = ':TSUpdate',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
    {
      'nvim-treesitter/nvim-treesitter-context',
      lazy = true,
      opts = { enable = false, mode = 'topline' }, -- used in winbar
    },
  },
  config = function()
    local ts = require('nvim-treesitter')
    ts.install({ 'bash', 'c', 'cpp', 'javascript', 'lua', 'python', 'regex', 'luap' })

    mia.augroup('treesitter', {
      FileType = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
        if vim.tbl_contains(ts.get_available(), lang) then
          local ok = pcall(vim.treesitter.start, ev.buf, lang)
          if not ok then
            ts.install(lang):await(function()
              vim.treesitter.start(ev.buf, lang)
            end)
          end
        end
      end,
    })
  end,
}
