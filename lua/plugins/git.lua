---@type LazySpec
return {
  {
    'tpope/vim-fugitive',
    lazy = false,
    cmd = 'G',
    ctxmap = {
      {
        ctx = 'cmd.start(lhs, map) and abbr.trigger(" ")',
        mode = 'ca',
        { 'gau', 'G add --update' },
        { 'gst', 'G status' },
        { 'gco', 'G checkout' },
        { 'gad', 'G add' },
        { 'gau', 'G add --update' },
        { 'gaup', 'G add --update --patch' },
      },
      {
        ctx = 'cmd.start',
        mode = 'ca',
        { 'gau', 'G add --update %' },
        { 'gst', 'G status <C-r>=expand("%:h")<Cr>' },
        { 'gpl', 'G pull' },
        { 'gps', 'G push' },
        { 'gcim', "G commit -m ''<Left>", eat = '%s' },
        { 'gco', 'G checkout %' },
        { 'gad', 'G add %' },
        { 'gau', 'G add --update %' },
        { 'gaup', 'G add --update --patch %' },
        -- TODO cfg files
        clear = false,
      },
    },
  },
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
      { 'lg', 'LazyGit', mode = 'ca', ctx = 'cmd.start' },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'TextChanged', 'SafeState' },
    opts = { attach_to_untracked = true },
    keys = {
      { ']c', '<Cmd>Gitsigns next_hunk<Cr>' },
      { '[c', '<Cmd>Gitsigns prev_hunk<Cr>' },
      { 'gsh', '<Cmd>Gitsigns stage_hunk<Cr>' },
    },
  },
}
