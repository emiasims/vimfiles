vim.g.targets_aiAI = 'aIAi'
vim.g.filebeagle_suppress_keymaps = 1
vim.keymap.set('n', '\\-', '<Plug>FileBeagleOpenCurrentBufferDir', { silent = true })
vim.g.loaded_netrwPlugin = 'v9999'
vim.g.undotree_DiffAutoOpen = 0
vim.g.undotree_HighlightChangedText = 0
vim.g.undotree_StatusLine = 0

vim.g.gutentags_cache_dir = vim.fn.stdpath('data') .. '/tags'
vim.g.gutentags_ctags_exclude = { 'data' }

---@type LazySpec
return {
  'tpope/vim-repeat',
  'gregorias/coop.nvim',
  'tpope/vim-speeddating',
  { 'tommcdo/vim-exchange', keys = { 'cx', 'cxx', 'cxc', { 'X', mode = 'x' } } },
  { 'wellle/targets.vim', event = 'ModeChanged *:*o*' },
  { 'tommcdo/vim-lion', keys = { 'gl', 'gL' } },
  { 'lewis6991/nvim-test', lazy = true },
  'mbbill/undotree',

  'nvim-lua/popup.nvim',
  'nvim-lua/plenary.nvim',
  'ludovicchabant/vim-gutentags',

  'JuliaEditorSupport/julia-vim',
  'lewis6991/async.nvim',

  { 'nvim-mini/mini.cursorword', event = 'VeryLazy', config = true },
}
