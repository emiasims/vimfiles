vim.g.targets_aiAI = 'aIAi'
vim.g.undotree_DiffAutoOpen = 0
vim.g.undotree_HighlightChangedText = 0
vim.g.undotree_StatusLine = 0

vim.g.gutentags_cache_dir = vim.fn.stdpath('data') .. '/tags'
vim.g.gutentags_ctags_exclude = { 'data' }

stimpack.add({
  'tpope/vim-repeat',
  'tpope/vim-speeddating',
  'tommcdo/vim-exchange',
  'tommcdo/vim-lion',
  'lewis6991/nvim-test',
  'nvim-lua/popup.nvim',
  'nvim-lua/plenary.nvim',
  'JuliaEditorSupport/julia-vim',
  'lewis6991/async.nvim',
  'wellle/targets.vim',
  'mbbill/undotree',
  'ludovicchabant/vim-gutentags',
  'kdheepak/lazygit.nvim',
  'nvim-mini/mini.cursorword',
  'brenoprata10/nvim-highlight-colors',
})

local ctx = require('ctxmap')
ctx.keymap.set('ca', 'lg', { 'cmd.start', 'LazyGit' })

require('mini.cursorword').setup()

require('nvim-highlight-colors').setup({
  enable_named_colors = false,
  exclude_filetypes = { 'lazy', 'help' },
})
