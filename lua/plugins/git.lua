---@type LazySpec
return {
  { 'tpope/vim-fugitive', event = 'VeryLazy' },
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    ctxmap = {
      { 'lg', 'LazyGit',
      mode = 'ca',
      ctx = 'cmd.start',
    },
  },
},

  {
    'lewis6991/gitsigns.nvim',
    event = { 'TextChanged', 'SafeState' },
    opts = {},
  },
}
