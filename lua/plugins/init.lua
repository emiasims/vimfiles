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
  { 'tpope/vim-abolish', cmd = { 'Subvert', 'Abolish' }, keys = 'cr' },
  {
    'tpope/vim-commentary',
    lazy = false,
    keys = { { 'cgc', '<Plug>ChangeCommentary' } },
  },
  {
    'tpope/vim-speeddating',
    event = 'VeryLazy',
    -- makes sure these are properly set, if a map for <C-a> or <C-x> is made ahead of loading
    keys = {
      { '<Plug>SpeedDatingFallbackUp', '<C-a>' },
      { '<Plug>SpeedDatingFallbackDown', '<C-x>' },
    },
    config = function()
      vim.cmd.delcommand('SpeedDatingFormat')  -- want :S ➜ Subvert
    end,
  },
  { 'tommcdo/vim-exchange', keys = { 'cx', 'cxx', 'cxc', { 'X', mode = 'x' } } },
  { 'wellle/targets.vim', event = 'ModeChanged *:*o*' },
  { 'tommcdo/vim-lion', keys = { 'gl', 'gL' } },
  'mbbill/undotree',

  'nvim-lua/popup.nvim',
  'nvim-lua/plenary.nvim',
  'ludovicchabant/vim-gutentags',

  'JuliaEditorSupport/julia-vim',
  'lewis6991/async.nvim',
}
