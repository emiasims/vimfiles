vim.g.targets_aiAI = 'aIAi'
vim.g.filebeagle_suppress_keymaps = 1
vim.keymap.set('n', '\\-', '<Plug>FileBeagleOpenCurrentBufferDir', { silent = true })
vim.g.loaded_netrwPlugin = 'v9999'
vim.g.undotree_DiffAutoOpen = 0
vim.g.undotree_HighlightChangedText = 0

vim.g.gutentags_cache_dir = vim.fn.stdpath 'data' .. '/tags'
vim.g.gutentags_ctags_exclude = { 'data' }

vim.keymap.set('n', '<F6>', '<cmd>UndotreeToggle<Cr>')

return {
  'tpope/vim-repeat',
  -- 'tpope/vim-speeddating',
  {
    'tpope/vim-speeddating',
    event = 'VeryLazy',
    -- makes sure these are properly set, if a map for <C-a> or <C-x> is made ahead of loading
    keys = { { '<Plug>SpeedDatingFallbackUp', '<C-a>' }, { '<Plug>SpeedDatingFallbackDown', '<C-x>' } },
  },
  {
    'tpope/vim-commentary',
    config = function()
      local nmap, omap, xmap = require 'mapfun' ('nox', { remap = true })
      xmap('gc', '<Plug>Commentary')
      nmap('gc', '<Plug>Commentary')
      omap('gc', '<Plug>Commentary')
      nmap('gcc', '<Plug>CommentaryLine')
      nmap('cgc', '<Plug>ChangeCommentary')
      nmap('gcu', '<Plug>Commentary<Plug>Commentary')
    end,
  },
  'tpope/vim-obsession',
  'tpope/vim-scriptease',
  { 'tommcdo/vim-exchange', keys = { 'cx', 'cxx', 'cxc', { 'X', mode = 'x' } } },
  { 'wellle/targets.vim', event = 'ModeChanged *:*o*' },
  { 'tommcdo/vim-lion', keys = { 'gl', 'gL' } },
  { 'echasnovski/mini.cursorword', event = 'VeryLazy', config = true },
  'jeetsukumaran/vim-filebeagle',
  'mbbill/undotree',

  'nvim-lua/popup.nvim',
  'nvim-lua/plenary.nvim',
  'ludovicchabant/vim-gutentags',

  'JuliaEditorSupport/julia-vim',
  { 'rktjmp/lush.nvim', lazy = true, cmd = 'Lushify' },
}
