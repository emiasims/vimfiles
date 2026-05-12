vim.g.targets_aiAI = 'aIAi'
vim.g.undotree_DiffAutoOpen = 0
vim.g.undotree_HighlightChangedText = 0
vim.g.undotree_StatusLine = 0

vim.g.gutentags_cache_dir = vim.fn.stdpath('data') .. '/tags'
vim.g.gutentags_ctags_exclude = { 'data' }

vim.pack.add({
  'https://github.com/tpope/vim-repeat',
  'https://github.com/tpope/vim-speeddating',
  'https://github.com/tommcdo/vim-exchange',
  'https://github.com/tommcdo/vim-lion',
  'https://github.com/lewis6991/nvim-test',
  'https://github.com/nvim-lua/popup.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/JuliaEditorSupport/julia-vim',
  'https://github.com/lewis6991/async.nvim',
  'https://github.com/wellle/targets.vim',
  'https://github.com/mbbill/undotree',
  'https://github.com/ludovicchabant/vim-gutentags',
  'https://github.com/kdheepak/lazygit.nvim',
  'https://github.com/nvim-mini/mini.cursorword',
  'https://github.com/brenoprata10/nvim-highlight-colors',
}, { load = true })

local ctx = require('ctxmap.keymap')
ctx.set('ca', 'lg', { 'cmd.start', 'LazyGit' })

require('mini.cursorword').setup()

require('nvim-highlight-colors').setup({
  enable_named_colors = false,
  exclude_filetypes = { 'lazy', 'help' },
})
