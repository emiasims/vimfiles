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
    ctx = {
      {
        mode = 'ca',
        ctx = 'builtin.cmd_start',
        each = { lg = 'LazyGit' },
      },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'TextChanged', 'SafeState' },
    opts = {},
  },
}
